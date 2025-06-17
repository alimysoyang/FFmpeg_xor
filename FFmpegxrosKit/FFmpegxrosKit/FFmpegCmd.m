//
//  FFmpegCmd.m
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#import "FFmpegCmd.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AudioToolbox/AudioToolbox.h>
#include "libavcodec/avcodec.h"
#include "libavdevice/avdevice.h"
#include "libavfilter/avfilter.h"
#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "ffmpeg.h"
#import "NSString+FFmpeg.h"

/** Forward declaration for function defined in ffprobe.c */
int ffprobe_execute(int argc, char **argv);

@interface FFmpegCmd()

@property (assign, nonatomic) FFmpegCmdStatus status;

@property (copy, nonatomic, nullable) ProgressHandler progressHandler;

@property (assign, nonatomic) float oldProgressValue;

@end

@implementation FFmpegCmd

#pragma mark lifecycle
+ (instancetype)share {
    static FFmpegCmd *staticInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticInstance = [[self alloc] init];
    });
    return staticInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _duration = 0;
        _currentTime = 0;
        _oldProgressValue = 0;
        _status = FFmpegCmdStatusIdle;
        _meta = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark public methods
- (void)getCurrentTime:(const char *)info {
//    NSLog(@"测试信息:%@", [NSString stringWithUTF8String:info]);
    NSString *temp = @"";
    BOOL isBegin = NO;
    int j = 5;
    for (int i = 0; i < 1024; i++) {
        /// 获取时间开始标记t
        if (info[i] == 't') {
            isBegin = YES;
        }
        
        if (isBegin) {
            /// 获取结束标志，空格
            if (info[i] == ' ') {
                break;
            }
            if (j > 0) {
                j--;
                continue;
            } else {
                temp = [temp stringByAppendingFormat:@"%c", info[i]];
            }
        }
    }
    
    int hour, min, second;
    hour = [[temp substringWithRange:NSMakeRange(0, 2)] intValue];
    min = [[temp substringWithRange:NSMakeRange(3, 2)] intValue];
    second = [[temp substringWithRange:NSMakeRange(6, 2)] intValue];
    second = hour * 3600 + min * 60 + second + 1;
    _currentTime = second;
    
    /// Update progress, show progress on UI
    if (self.progressHandler && _duration > 0) {
        float value = (float)_currentTime / (float)_duration;
        value = MIN(value, 1.0);
        if (_oldProgressValue != value) {
            _oldProgressValue = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressHandler(value);
            });
        }
    }
}

- (void)metaBasicInfo:(const char *)filename nbstreams:(int)nbstreams nbprograms:(unsigned int)nbprograms formatname:(const char *)formatname formatlongname:(const char *)formatlongname duration:(long long)duration size:(long long)size bitrate:(long long)bitrate {
    _meta = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"filename": [NSString stringWithUTF8String:filename],
        @"nb_streams": @(nbstreams),
        @"nb_programs": @(nbprograms),
        @"format_name": [NSString stringWithUTF8String:formatname],
        @"format_long_name": [NSString stringWithUTF8String: formatlongname],
        @"duration": @(duration),
        @"size": @(size),
        @"bit_rate": @(bitrate)
    }];
}

- (void)metaInfo:(const char *)key value:(const char *)value {
    _meta[[NSString stringWithUTF8String:key]] = [NSString stringWithUTF8String:value];
}

- (void)runCommand:(FFmpegCmdFormat *)cmd progress:(ProgressHandler)progress completion:(CompletionHandler)completion {
    if (_status == FFmpegCmdStatusRunning) {
        #if DEBUG
        NSLog(@"FFmpeg task is running, return");
        #endif
        return;
    }
    
    _status = FFmpegCmdStatusReady;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.progressHandler = progress;
        [self run:cmd.fullCommand];
        dispatch_semaphore_signal(sema);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            long result = dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            if (result == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.status == FFmpegCmdStatusRunning) {
                        self.status = FFmpegCmdStatusDone;
                    }
                    completion(self.status);
                    [self resetValues];
                });
            }
        });
    });
}

- (NSString *)version {
    [self run:@"ffmpeg -version"];
	_status = FFmpegCmdStatusIdle;
    return @"v4.3.6";
}

#pragma mark ffprobe
- (NSInteger)probeRun:(NSString *)command {
	_isPCM = NO;
    NSArray<NSString *> *parts = [command componentsSeparatedByString:@" "];
    NSMutableArray<NSString *> *argvs = [[NSMutableArray<NSString *> alloc] init];
    for (NSString *item in parts) {
        if (!item.isEmpty) {
            [argvs addObject:item];
        }
    }
    
    NSUInteger count = argvs.count;
    char **argv = (char **)malloc(sizeof(char *) * count);
    for (NSUInteger i = 0;i < count;i++) {
        argv[i] = (char *)malloc(sizeof(char) * 1024);
        strcpy(argv[i], [argvs[i] UTF8String]);
    }
    
    int code = ffprobe_execute((int)count, argv);
    
    for (NSUInteger i = 0;i < count;i++) {
        free(argv[i]);
    }
    free(argv);
    #if DEBUG
    NSLog(@"FFprobe command done: %d - %@", code, _meta);
    #endif
	return code;
}

#pragma mark private methods
- (void)run:(NSString *)command {
    NSArray<NSString *> *parts = [command componentsSeparatedByString:@" "];
    NSMutableArray<NSString *> *argvs = [[NSMutableArray<NSString *> alloc] init];
    for (NSString *item in parts) {
        if (!item.isEmpty) {
            [argvs addObject:item];
        }
    }
    
    NSUInteger count = argvs.count;
    char **argv = (char **)malloc(sizeof(char *) * count);
    for (NSUInteger i = 0;i < count;i++) {
        argv[i] = (char *)malloc(sizeof(char) * 1024);
        strcpy(argv[i], [argvs[i] UTF8String]);
    }
    
    _status = FFmpegCmdStatusRunning;
    int code = ffmpeg_main((int)count, argv);
    
    for (NSUInteger i = 0;i < count;i++) {
        free(argv[i]);
    }
    free(argv);
    #if DEBUG
    NSLog(@"FFmpeg command done: %d", code);
    #endif
}

- (void)cancel {
    if (_status == FFmpegCmdStatusRunning) {
        cancel_operation();
        _status = FFmpegCmdStatusCancel;
        [self resetValues];
    }
}

- (void)resetValues {
    _duration = 0;
    _currentTime = 0;
    _oldProgressValue = 0;
}
@end
