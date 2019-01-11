//
//  ViewController.m
//  NZBVortex Example
//
//  Created by Andrew Farquharson on 11/01/19.
//  Copyright © 2019 Andrew Farquharson. All rights reserved.
//

#import "ViewController.h"
#import "AFNZBVortex.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up NZBVortex Host
    [[AFNZBVortex sharedInstance] setNewHostWithURL:@"192.168.1.1"
                                               port:@"4321"
                                             APIKey:@"DVE-TRE"
                                          customURL:@""
                                         SSLEnabled:YES];
    
    // get all NZB detals
    [[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexAllNZBDetails
                                  parameters:nil
                                 withSuccess:^(NSDictionary * _Nonnull responce) {
                                     NSLog(@"ALL NZB Details: %@", responce);
                                 } failure:^(NSError * _Nonnull error) {
                                     NSLog(@"Error: %@", error);
                                 }];
    
    
    
    // Delete a NZB
    NSDictionary *params = @{@"nzbid":@"yourNZBID"};
    [[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexNZBCancelDelete
                                  parameters:params
                                 withSuccess:^(NSDictionary * _Nonnull responce) {
        NSLog(@"Success: %@", responce);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
    
    // add NZB via url
    NSDictionary *url = @{@"url":@"http://example.com/test.nzb"};
    [[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexNZBAdd
                                  parameters:url
                                 withSuccess:^(NSDictionary * _Nonnull responce) {
                                     NSLog(@"Success: %@", responce);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
    
    NSData *nzb = [NSData dataWithContentsOfFile:@""];
    
    [[AFNZBVortex sharedInstance] uploadNZB:nzb
                                   fileName:@"test.nzb"
                                       name:@"test"
                                  groupName:@""
                        uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
    } withSuccess:^(NSDictionary * _Nonnull responce) {
        NSLog(@"Success: %@", responce);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}


@end
