//
//  NSString+FFmpeg.m
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#import "NSString+FFmpeg.h"

@implementation NSString (FFmpeg)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isEmpty {
    if ([self.trim isEqualToString:@""] || self.trim.length == 0) {
        return YES;
    }
    return NO;
}

@end
