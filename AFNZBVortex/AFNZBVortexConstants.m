//
//  AFNZBVortexConstants.m
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "AFNZBVortexConstants.h"

@implementation AFNZBVortexConstants


#pragma mark - Auth Functions
NSString * const kAFNZBVortexAuthNonce =             @"api/auth/nonce";
NSString * const kAFNZBVortexAuthLogin =             @"api/auth/login";

#pragma mark - App Functions
NSString * const kAFNZBVortexAppAPILevel =           @"api/app/apilevel";
NSString * const kAFNZBVortexAppVersion =            @"api/app/appversion";
NSString * const kAFNZBVortexAppDownloadSpeed =      @"api/app/downloadspeed";
NSString * const kAFNZBVortexAppWebUpdate =          @"api/app/webUpdate";

#pragma mark - NZB Functions
NSString * const kAFNZBVortexAllNZBDetails =         @"api/nzb";
NSString * const kAFNZBVortexNZBDetails =            @"api/nzb/:nzbid";
NSString * const kAFNZBVortexNZBAdd =                @"api/nzb/add";
NSString * const kAFNZBVortexNZBPause =              @"api/nzb/:nzbid/pause";
NSString * const kAFNZBVortexNZBResume =             @"api/nzb/:nzbid/resume";
NSString * const kAFNZBVortexNZBCancelDelete =       @"api/nzb/:nzbid/cancelDelete";
NSString * const kAFNZBVortexNZBPauseAll =           @"api/nzb/pause";
NSString * const kAFNZBVortexNZBResumeAll =          @"api/nzb/resume";
NSString * const kAFNZBVortexNZBCancelAll =          @"api/nzb/cancel";
NSString * const kAFNZBVortexNZBDeleteAll =          @"api/nzb/cancelDelete";
NSString * const kAFNZBVortexNZBClearFinished =      @"api/nzb/clearFinished";
NSString * const kAFNZBVortexNZBMoveUp =             @"api/nzb/:nzbid/moveup";
NSString * const kAFNZBVortexNZBMoveDown =           @"api/nzb/:nzbid/movedown";
NSString * const kAFNZBVortexNZBMoveTop =            @"api/nzb/:nzbid/movetop";
NSString * const kAFNZBVortexNZBMoveBottom =         @"api/nzb/:nzbid/movebottom";
NSString * const kAFNZBVortexNZBDownloadNext =       @"api/nzb/:nzbid/downloadnext";
NSString * const kAFNZBVortexNZBMoveToIndex =        @"api/nzb/:nzbid/moveToIndex";

#pragma mark - Speed Limit Functions
NSString * const kAFNZBVortexSpeedLimit =            @"api/speedlimit";
NSString * const kAFNZBVortexSpeedLimitEnable =      @"api/speedlimit/enable";
NSString * const kAFNZBVortexSpeedLimitDisable =     @"api/speedlimit/disable";

#pragma mark - Sleep Functions
NSString * const kAFNZBVortexSleepWhenDone =         @"api/sleepwhendone";
NSString * const kAFNZBVortexSleepWhenDoneEnable =   @"api/sleepwhendone/enable";
NSString * const kAFNZBVortexSleepWhenDoneDisable =  @"api/sleepwhendone/disable";

#pragma mark - Files Functions
NSString * const kAFNZBVortexFiles =                 @"api/file/:nzbid";

#pragma mark - NZB States
+ (NSString *)NZBState:(int)state {
    NSArray *states = @[@"Waiting",@"Downloading",@"Waiting for save",@"Saving",@"Saved",@"Password request",@"Queued for processing",@"User wait for processing",@"Checking",@"Repairing",@"Joining",@"Wait for further processing",@"Joining",@"Wait for uncompress",@"Uncompressing",@"Wait for cleanup",@"Cleaning up",@"Cleaned up",@"Moving to completed",@"Move completed",@"Done",@"Uncompress failed",@"Check failed, data corrupt",@"Move failed",@"Badly encoded download (uuencoded)"];
    if (state >= states.count) {
        return @"Unknown";
    }
    return [states objectAtIndex:state];
}

#pragma mark - File States
+ (NSString *)FileState:(int)state {
    NSArray *states = @[@"Waiting",@"Downloading",@"Downloaded",@"Saving",@"Saved",@"Skipped"];
    if (state >= states.count) {
        return @"Unknown";
    }
    return [states objectAtIndex:state];
}


@end
