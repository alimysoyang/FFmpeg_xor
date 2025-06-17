//
//  FFmpegCmd.h
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#import <Foundation/Foundation.h>
#import <FFmpegxrosKit/FFmpegCommon.h>
#import <FFmpegxrosKit/FFmpegCmdFormat.h>

NS_ASSUME_NONNULL_BEGIN

FFMPEGXROSKIT_EXPORT

@interface FFmpegCmd : NSObject

/// 总时长，单位秒(s)
@property (assign, nonatomic) long long duration;
/// 当前时间，单位秒(s)
@property (assign, nonatomic) long long currentTime;

@property (strong, nonatomic, nonnull) NSMutableDictionary *meta;

@property (assign, nonatomic) BOOL isPCM;

+ (instancetype)share;

- (void)getCurrentTime:(const char *)info;

- (nonnull NSString *)version;

- (void)metaBasicInfo:(const char *)filename
			nbstreams:(int)nbstreams
		   nbprograms:(unsigned int)nbprograms
		   formatname:(const char *)formatname
	   formatlongname:(const char *)formatlongname
			 duration:(long long)duration
				 size:(long long)size
			  bitrate:(long long)bitrate;

- (void)metaInfo:(const char *)key value:(const char *)value;

/// FFmpeg执行命令
/// - Parameters:
///   - cmd: 命令参数
///   - progress: 执行进度
///   - completion: 完成回调
- (void)runCommand:(nonnull FFmpegCmdFormat *)cmd progress:(nullable ProgressHandler)progress completion:(nullable CompletionHandler)completion;

/// FFmpeg取消命令
- (void)cancel;

/// ffprobe命令
/// - Parameter command: 命令
- (NSInteger)probeRun:(NSString *)command;

//- (void)test:(const char *)info;

@end

NS_ASSUME_NONNULL_END
