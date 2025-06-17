//
//  FFmpegCmdFormat.h
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#import <Foundation/Foundation.h>
#import <FFmpegxrosKit/FFmpegCommon.h>

NS_ASSUME_NONNULL_BEGIN

FFMPEGXROSKIT_EXPORT
@interface FFmpegCmdFormat : NSObject

@property (copy, nonatomic, nonnull) NSString *inputFile;

@property (copy, nonatomic, nonnull) NSString *outputFile;

@property (copy, nonatomic, nullable) NSString *expand;

/// 生成最终的执行命令
- (nonnull NSString *)fullCommand;

@end

NS_ASSUME_NONNULL_END
