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
    
    
}


@end
