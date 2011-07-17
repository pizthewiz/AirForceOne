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
@property (nonatomic, retain, readwrite) NSString* host;
@end

@implementation AFOAppleTV

@synthesize host = _host;

- (id)initWithHost:(NSString*)host {
    self = [super init];
    if (self) {
        _host = [host retain];
    }
    return self;
}

- (void)dealloc {
    [_host release];

    [super dealloc];
}

#pragma mark -

- (void)showImageAtURL:(NSURL*)imageURL {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/photo", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];

#define AFOPhotoTransitionSlideLeft @"SlideLeft"
#define AFOPhotoTransitionDissolve @"Dissolve" // apparently the default
//    [request setValue:AFOPhotoTransitionSlideLeft forHTTPHeaderField:@"X-Apple-Transition"];

    NSError* error;
    // TODO - could use non-blocking read via NSURLConnection instead
    NSData* imageData = [[NSData alloc]initWithContentsOfURL:imageURL options:0 error:&error];
    if (!imageData) {
        CCErrorLog(@"ERROR - failed to read image %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        [request release];
        return;
    }

#define AFODisplayWidth 1280
#define AFODisplayHeight 720
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    if (!imageSource) {
        CCErrorLog(@"ERROR - failed to crate image source");
    }
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    if (!image) {
        CCErrorLog(@"ERROR - failed to crate image from source");
    }
    if (imageSource)
        CFRelease(imageSource);

    if (CGImageGetWidth(image) >= AFODisplayWidth*1.5 || CGImageGetHeight(image) >= AFODisplayHeight*1.5) {
        CCDebugLog(@"should reisze image from %lux%lu", CGImageGetWidth(image), CGImageGetHeight(image));
        // TODO - resize
    }
#define AFOFileSizeMax 400 * 1024
    else if ([imageData length] > AFOFileSizeMax) {
        CCDebugLog(@"should recompress image from %.2fKB", [imageData length]/1024.);
    }
    CGImageRelease(image);

    [request setValue:[NSString stringWithFormat:@"%d", [imageData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:imageData];
    [imageData release];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

// - (void)playVideoAtURL:(NSURL*)videoURL {
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/play", self.host]];
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
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/rate", self.host]];
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
//     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/rate", self.host]];
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
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/stop", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

#pragma mark - CONNECTION DELEGATE

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    CCDebugLogSelector();

    float fractionComplete = MIN(((float)totalBytesWritten/(float)totalBytesExpectedToWrite), 1.);
    CCDebugLog(@"%.2f%% (%.2fKB of %.2fKB)", fractionComplete * 100., totalBytesWritten/1024., totalBytesExpectedToWrite/1024.);
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    CCDebugLogSelector();

    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200) {
        // TODO - do something
    }
    CCDebugLog(@"response status: %lu", (long unsigned)[httpResponse statusCode]);
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
