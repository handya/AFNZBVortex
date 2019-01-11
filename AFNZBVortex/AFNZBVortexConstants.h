//
//  AFNZBVortexConstants.h
//  Total NZB
//
//  Created by Andrew Farquharson on 8/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFNZBVortexConstants : NSObject

#pragma mark - Auth Functions
extern NSString * const kAFNZBVortexAuthNonce;
extern NSString * const kAFNZBVortexAuthLogin;

#pragma mark - App Functions
extern NSString * const kAFNZBVortexAppAPILevel;
extern NSString * const kAFNZBVortexAppVersion;
extern NSString * const kAFNZBVortexAppDownloadSpeed;
extern NSString * const kAFNZBVortexAppWebUpdate;

#pragma mark - NZB Functions
extern NSString * const kAFNZBVortexAllNZBDetails;
extern NSString * const kAFNZBVortexNZBDetails;
// when adding via URL use param "url" (url encoded url)
// when adding via http file upload use params "name" and "groupname" after api 2.2
extern NSString * const kAFNZBVortexNZBAdd;
extern NSString * const kAFNZBVortexNZBPause;
extern NSString * const kAFNZBVortexNZBResume;
extern NSString * const kAFNZBVortexNZBCancel;
extern NSString * const kAFNZBVortexNZBCancelDelete;
extern NSString * const kAFNZBVortexNZBPauseAll;
extern NSString * const kAFNZBVortexNZBResumeAll;
extern NSString * const kAFNZBVortexNZBCancelAll;
extern NSString * const kAFNZBVortexNZBDeleteAll;
extern NSString * const kAFNZBVortexNZBClearFinished;
extern NSString * const kAFNZBVortexNZBMoveUp;
extern NSString * const kAFNZBVortexNZBMoveDown;
extern NSString * const kAFNZBVortexNZBMoveTop;
extern NSString * const kAFNZBVortexNZBMoveBottom;
extern NSString * const kAFNZBVortexNZBDownloadNext;
// also send param "index"
extern NSString * const kAFNZBVortexNZBMoveToIndex;


#pragma mark - Speed Limit Functions
extern NSString * const kAFNZBVortexSpeedLimit;
// also send params "speed" in KB/s and (optional) "minutes"
extern NSString * const kAFNZBVortexSpeedLimitEnable;
extern NSString * const kAFNZBVortexSpeedLimitDisable;

#pragma mark - Sleep Functions
extern NSString * const kAFNZBVortexSleepWhenDone;
extern NSString * const kAFNZBVortexSleepWhenDoneEnable;
extern NSString * const kAFNZBVortexSleepWhenDoneDisable;

#pragma mark - Files Functions
extern NSString * const kAFNZBVortexFiles;

#pragma mark - NZB States
+ (NSString *)NZBState:(int)state;

#pragma mark - File States
+ (NSString *)FileState:(int)state;

@end

NS_ASSUME_NONNULL_END
