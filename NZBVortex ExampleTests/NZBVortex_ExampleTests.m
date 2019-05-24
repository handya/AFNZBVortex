//
//  NZBVortex_ExampleTests.m
//  NZBVortex ExampleTests
//
//  Created by Andrew Farquharson on 24/05/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFNZBVortex.h"

@interface NZBVortex_ExampleTests : XCTestCase

@end

@implementation NZBVortex_ExampleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[AFNZBVortex sharedInstance] setNewHostWithURL:@"10.1.0.10"
                                               port:@"4321"
                                             APIKey:@"43A2-D43A"
                                          customURL:@""
                                         SSLEnabled:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testConnection {
    __block BOOL done = NO;
    
    [[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexAllNZBDetails
                                  parameters:nil
                                 withSuccess:^(NSDictionary * _Nonnull responce) {
                                     XCTAssert([[responce objectForKey:@"result"] isEqualToString:@"ok"]);
                                     done = YES;
                                 } failure:^(NSError * _Nonnull error) {
                                     XCTAssert(NO);
                                     done = YES;
                                 }];
    
    while(!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
    
- (void)testParamError {
    __block BOOL done = NO;
    
    [[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexNZBPause
                                  parameters:@{}
                                 withSuccess:^(NSDictionary * _Nonnull responce) {
                                     XCTAssert(NO);
                                     done = YES;
                                 } failure:^(NSError * _Nonnull error) {
                                     XCTAssert(YES);
                                     done = YES;
                                 }];
    while(!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end
