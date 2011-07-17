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

- (void)playVideoAtURL:(NSURL*)videoURL {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/play", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString* bodyString = [NSString stringWithFormat:@"Content-Location: %@\nStart-Position: 0.0000\n", [videoURL absoluteURL]];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:bodyData];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

- (void)stop {
}

#pragma mark - CONNECTION DELEGATE

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CCDebugLogSelector();    
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
