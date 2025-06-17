//
//  FFmpegCmdFormat.m
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#import "FFmpegCmdFormat.h"
#import "NSString+FFmpeg.h"

@implementation FFmpegCmdFormat

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputFile = @"";
        _outputFile = [NSString stringWithFormat:@"%@/tmp.mp4", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    }
    return self;
}


- (NSString *)fullCommand {
//    return [NSString stringWithFormat:@"ffmpeg -i %@ %@", _inputFile, _outputFile];
    NSMutableString *tmp = [[NSMutableString alloc] initWithString:@"ffmpeg"];
    [tmp appendFormat:@" -i %@", _inputFile];
    if (_expand && !_expand.isEmpty) {
        [tmp appendFormat:@" %@ ", _expand.trim];
    }
	if (!_outputFile.isEmpty) {
		[tmp appendFormat:@"-y %@", _outputFile];
	}
    return tmp;
}
@end
