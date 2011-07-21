//
//  AFOAppleTV.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 16 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "AFOAppleTV.h"
#import "AirForceOne.h"

CGImageRef CreateScaledImageAtFactor(CGImageRef sourceImage, CGFloat scaleFactor);
CFDataRef CreateCompressedJPEGDataFromImage(CGImageRef image, CGFloat compressionFactor);

CGImageRef CreateScaledImageAtFactor(CGImageRef sourceImage, CGFloat scaleFactor) {
    CGFloat sourceWidth = CGImageGetWidth(sourceImage);
    CGFloat sourceHeight = CGImageGetHeight(sourceImage);
    CGFloat scaledWidth = floorf(sourceWidth * scaleFactor);
    CGFloat scaledHeight = floorf(sourceHeight * scaleFactor);

    size_t bytesPerRow = scaledWidth * 4;
    if (bytesPerRow % 16)
        bytesPerRow = ((bytesPerRow / 16) + 1) * 16;

    void* baseAddress = valloc(scaledHeight * bytesPerRow);
    if (baseAddress == NULL) {
        CCErrorLog(@"ERROR - failed to valloc memory for bitmap");
        return NULL;
    }

    CGContextRef bitmapContext = CGBitmapContextCreate(baseAddress, scaledWidth, scaledHeight, 8, bytesPerRow, CGImageGetColorSpace(sourceImage), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    if (bitmapContext == NULL) {
        free(baseAddress);
        return NULL;
    }

    CGContextScaleCTM(bitmapContext, scaleFactor, scaleFactor);

    CGRect bounds = CGRectMake(0., 0., sourceWidth, sourceHeight);
    CGContextClearRect(bitmapContext, bounds);
    CGContextDrawImage(bitmapContext, bounds, sourceImage);

    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);

    return scaledImage;
}

CFDataRef CreateCompressedJPEGDataFromImage(CGImageRef image, CGFloat compressionFactor) {
    CFMutableDataRef imageData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(imageData, kUTTypeJPEG, 1, NULL);
    if (!destination) {
        CCErrorLog(@"ERROR - failed to create in-memory image destination");
        return NULL;
    }
    // set JPEG compression to 50%
    NSDictionary* properties = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:compressionFactor], kCGImageDestinationLossyCompressionQuality, nil];
    CGImageDestinationAddImage(destination, image, (CFDictionaryRef)properties);
    [properties release];
    BOOL status = CGImageDestinationFinalize(destination);
    if (!status) {
        CCErrorLog(@"ERROR - failed to write scaled image to in-memory buffer");
        CFRelease(destination);
        return NULL;
    }
    CFRelease(destination);

    return (CFDataRef)imageData;
}

#pragma mark -

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
    NSError* error;
    // TODO - could use non-blocking read via NSURLConnection instead
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:imageURL options:0 error:&error];
    if (!imageData) {
        CCErrorLog(@"ERROR - failed to read image %@", [error localizedDescription]);
        return;
    }


#define AFODisplayWidth 1280.
#define AFODisplayHeight 720.
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

        // resize
        CGFloat scaleFactor = MAX(AFODisplayWidth/CGImageGetWidth(image), AFODisplayHeight/CGImageGetHeight(image));
        CGImageRef scaledImage = CreateScaledImageAtFactor(image, scaleFactor);
        CCDebugLog(@"resized image %lux%lu", CGImageGetWidth(scaledImage), CGImageGetHeight(scaledImage));

        // grab JPEG compressed data from image
        CFDataRef compressedImage = CreateCompressedJPEGDataFromImage(scaledImage, 0.5);
        CGImageRelease(scaledImage);

        [imageData release];
        imageData = (NSData*)compressedImage;

#define SHOULD_WRITE_TEMP_IMAGE_TO_DISK 0
#if SHOULD_WRITE_TEMP_IMAGE_TO_DISK
        [imageData writeToFile:[@"~/Desktop/AirForceOne-ResizedImage.jpg" stringByExpandingTildeInPath] atomically:YES];
#endif
    }
//#define AFOFileSizeMax 600 * 1024
//    else if ([imageData length] > AFOFileSizeMax) {
//        CCDebugLog(@"should recompress image from %.2fKB", [imageData length]/1024.);
//    }
    CGImageRelease(image);

    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:7000/photo", self.host]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
#define AFOPhotoTransitionSlideLeft @"SlideLeft"
#define AFOPhotoTransitionDissolve @"Dissolve" // apparently the default
    //    [request setValue:AFOPhotoTransitionSlideLeft forHTTPHeaderField:@"X-Apple-Transition"];


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
    CCErrorLog(@"ERROR - %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    CCDebugLogSelector();

    [connection release];
}

@end
