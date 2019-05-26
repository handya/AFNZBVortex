# AFNZBVortex
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fappsupport.handya.net%2Fshield%2Fget%3Fapp%3Dnzbvortex)]()

Objective-c API Wrapper for [NZBVortex API](https://www.nzbvortex.com/developerconnect/Network_API_Documentation_1.6.pdf)

## Requirements 

[AFNetworking](https://github.com/AFNetworking/AFNetworking)

## Usage:

### Installation
Copy AFNZBVortex and AFCryptography into project then import AFNZBVortex.h

```Objective-c

#import "AFNZBVortex.h"

```

### Setup
First setup up with setNewHostWithURL:
Unless using customURL: leave blank 

```Objective-c
[[AFNZBVortex sharedInstance] setNewHostWithURL:@"192.168.1.1"
                                           port:@"4321"
                                         APIKey:@"DVE-TRE"
                                      customURL:@""
                                     SSLEnabled:YES];
```

### Requests
Make a get request with GETRequest:

```Objective-c
[[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexAllNZBDetails
                              parameters:nil
                             withSuccess:^(NSDictionary * _Nonnull responce) {
                                 NSLog(@"ALL NZB Details: %@", responce);
                             } failure:^(NSError * _Nonnull error) {
                                 NSLog(@"Error: %@", error);
                             }];
```

### Delete a NZB

When editing single NZB send the NZBID via params with "nzbid" as the dictionary key

```Objective-c
NSDictionary *params = @{@"nzbid":@"yourNZBID"};
[[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexNZBCancelDelete
                              parameters:params
                             withSuccess:^(NSDictionary * _Nonnull responce) {
    NSLog(@"resp: %@", responce);
} failure:^(NSError * _Nonnull error) {
    NSLog(@"Error: %@", error);
}];
```

### Add NZB via HTTP File Upload

```Objective-c
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
```


### Add a NZB via URL

When adding NZB via url, send the nzb url in params with "url" as the dictionary key

```Objective-c
NSDictionary *url = @{@"url":@"http://example.com/test.nzb"};
[[AFNZBVortex sharedInstance] GETRequest:kAFNZBVortexNZBAdd
                              parameters:url
                             withSuccess:^(NSDictionary * _Nonnull responce) {
                                 NSLog(@"Success: %@", responce);
} failure:^(NSError * _Nonnull error) {
    NSLog(@"Error: %@", error);
}];
```
