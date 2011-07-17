//
//  AFOAppleTV.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 16 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "AFOAppleTV.h"
#import "AirForceOne.h"

@interface AFOAppleTV()
@property (nonatomic, copy, readwrite) NSString* host;
@end

@implementation AFOAppleTV

@synthesize host = _host;

- (id)initWithHost:(NSString*)host {
    self = [super init];
    if (self) {
        _host = [host copy];
    }
    return self;
}

- (void)dealloc {
    [_host release];

    [super dealloc];
}

#pragma mark -

- (void)showImageAtURL:(NSURL*)imageURL {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/photo", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];

#define AFOPhotoTransitionSlideLeft @"SlideLeft"
#define AFOPhotoTransitionDissolve @"Dissolve"
//    [request setValue:AFOPhotoTransitionDissolve forHTTPHeaderField:@"X-Apple-Transition"];

    NSError* error;
    // TODO - could use non-blocking read via NSURLConnection instead
    NSData* bodyData = [[NSData alloc]initWithContentsOfURL:imageURL options:0 error:&error];
    if (!bodyData) {
        CCErrorLog(@"ERROR - failed to read image %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    }
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:bodyData];
    [bodyData release];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

// - (void)playVideoAtURL:(NSURL*)videoURL {
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/play", self.host]];
//     NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
//     [request setHTTPMethod:@"POST"];
//     NSString* bodyString = [NSString stringWithFormat:@"Content-Location: %@\nStart-Position: 0.0000\n", [videoURL absoluteURL]];
//     NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//     [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-length"];
//     [request setHTTPBody:bodyData];
// 
//     NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//     [request release];
// 
//     // NB - the connection is released in the failed/finished delegate methods
//     [connection description];
// }
// 
// - (void)play {
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/rate", self.host]];
//     NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
//     [request setHTTPMethod:@"POST"];
// 
//     NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//     [request release];
// 
//     // NB - the connection is released in the failed/finished delegate methods
//     [connection description];
// }
// 
// - (void)pause {
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/rate", self.host]];
//     NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
//     [request setHTTPMethod:@"POST"];
// 
//     NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//     [request release];
// 
//     // NB - the connection is released in the failed/finished delegate methods
//     [connection description];    
// }

- (void)stop {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/stop", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

#pragma mark - CONNECTION DELEGATE

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CCDebugLogSelector();

    float fractionComplete = MIN(((float)totalBytesWritten/(float)totalBytesExpectedToWrite), 1.);
    CCDebugLog(@"%.2f%% (%.2fKB of %.2fKB)", fractionComplete * 100., totalBytesWritten/1024., totalBytesExpectedToWrite/1024.);
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    CCDebugLogSelector();

    CCDebugLog(@"response status: %lu", (long unsigned)[(NSHTTPURLResponse*)response statusCode]);
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    CCDebugLogSelector();
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    CCDebugLogSelector();

    [connection release];
    CCErrorLog(@"ERROR - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    CCDebugLogSelector();

    [connection release];
}

@end
