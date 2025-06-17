//
//  FFmpegCommon.h
//  FFmpegxrosKit
//
//  Created by MuMuY on 2024-06-09.
//

#pragma once

#import <Foundation/Foundation.h>

#define FFMPEGXROSKIT_EXPORT __attribute__((visibility("default")))

typedef NS_ENUM(NSUInteger, FFmpegCmdStatus) {
	FFmpegCmdStatusIdle,
    FFmpegCmdStatusReady,
    FFmpegCmdStatusRunning,
    FFmpegCmdStatusCancel,
    FFmpegCmdStatusDone
};

typedef void(^EmptyHandler)(void);

typedef void(^CompletionHandler)(FFmpegCmdStatus status);

typedef void(^CompletionInfoHandler)(int status, NSMutableDictionary *meta, BOOL isPCM);

typedef void(^ProgressHandler)(float progress);
