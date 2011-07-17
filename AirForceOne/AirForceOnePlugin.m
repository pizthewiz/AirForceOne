//
//  AirForceOnePlugIn.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "AirForceOnePlugIn.h"
#import "AirForceOne.h"

@implementation NSWorkspace(CCAdditions)

- (BOOL)isRunningApplicationWithBundleIdentifier:(NSString*)bundleIdentifier {
    __block BOOL status = NO;
    
    NSArray* runningApplications = [self runningApplications];
    [runningApplications enumerateObjectsUsingBlock:^(id application, NSUInteger idx, BOOL *stop) {
        if ([[[application bundleIdentifier] lowercaseString] isEqualToString:bundleIdentifier]) {
            status = YES;
            *stop = YES;
        }
    }];
    
    return status;
}

@end

#pragma mark - PLUGIN

static NSString* const AFOExampleCompositionName = @"Display On Apple TV";

@interface AirForceOnePlugIn()
@property (nonatomic, retain) NSURL* imageURL;
- (void)_sendToAppleTV;
- (void)_sendImageToAirFlick;
@end

@implementation AirForceOnePlugIn

@dynamic inputImageLocation;
@synthesize imageURL = _imageURL;

+ (NSDictionary*)attributes {
    NSMutableDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
       CCLocalizedString(@"kQCPlugIn_Name", NULL), QCPlugInAttributeNameKey, 
       CCLocalizedString(@"kQCPlugIn_Description", NULL), QCPlugInAttributeDescriptionKey, 
       nil];

#if defined(MAC_OS_X_VERSION_10_7) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7)
    if (&QCPlugInAttributeCategoriesKey != NULL) {
        // array with category strings
        NSArray* categories = [NSArray arrayWithObjects:@"Render", nil];
        [attributes setObject:categories forKey:QCPlugInAttributeCategoriesKey];
    }
    if (&QCPlugInAttributeExamplesKey != NULL) {
        // array of file paths or urls relative to plugin resources
        NSArray* examples = [NSArray arrayWithObjects:[[NSBundle mainBundle] URLForResource:AFOExampleCompositionName withExtension:@"qtz"], nil];
        [attributes setObject:examples forKey:QCPlugInAttributeExamplesKey];
    }
#endif

    return (NSDictionary*)attributes;
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"inputImageLocation"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Image Location", QCPortAttributeNameKey, nil];
	return nil;
}

+ (QCPlugInExecutionMode)executionMode {
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode {
	return kQCPlugInTimeModeNone;
}

#pragma mark -

- (void)dealloc {
    [_imageURL release];

	[super dealloc];
}

#pragma mark - EXECUTION

- (BOOL)startExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/

    CCDebugLogSelector();

	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/

    CCDebugLogSelector();
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/

    // quick bail
    if (![self didValueForInputKeyChange:@"inputImageLocation"] || [self.inputImageLocation isEqualToString:@""])
        return YES;

    CCDebugLogSelector();

    NSURL* url = [NSURL URLWithString:self.inputImageLocation];
    // scheme-less would suggest a relative file url
    if (![url scheme]) {
        NSURL* baseDirectoryURL = [[context compositionURL] URLByDeletingLastPathComponent];
//        NSString* cleanFilePath = [[[baseDirectoryURL path] stringByAppendingPathComponent:self.inputImageLocation] stringByStandardizingPath];
//        CCDebugLog(@"cleaned file path: %@", cleanFilePath);
        url = [baseDirectoryURL URLByAppendingPathComponent:self.inputImageLocation];

        // TODO - may be better to just let it fail later?
        if (![url checkResourceIsReachableAndReturnError:NULL]) {
            return YES;
        }
    }

    self.imageURL = url;

    // TODO - some sort of file validation?

    CCDebugLog(@"should display image at location: %@", self.imageURL);

//    [self _sendImageToAirFlick];
    [self _sendToAppleTV];

    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/

    CCDebugLogSelector();
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/

    CCDebugLogSelector();
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

#pragma mark - PRIVATE

- (void)_sendToAppleTV {
    CCDebugLogSelector();

#define AFOAppleTVHost @"http://10.0.1.22"
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:7000/play", AFOAppleTVHost]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
#define AFOContentLocation @"http://www.808.dk/pics/video/gizmo.mp4"
    NSString* bodyString = [NSString stringWithFormat:@"Content-Location: %@\nStart-Position: 0.0000\n", AFOContentLocation];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:bodyData];

    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];

    // NB - the connection is released in the failed/finished delegate methods
    [connection description];
}

- (void)_sendImageToAirFlick {
    CCDebugLogSelector();

    // check AirFlick is present and running
#define AirFlickBundleIdentifier @"com.sadun.airplayismybitch"
    if (![[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:AirFlickBundleIdentifier]) {
        CCErrorLog(@"ERROR - AirFlick.app is not found");
        return;
    }
    if (![[NSWorkspace sharedWorkspace] isRunningApplicationWithBundleIdentifier:AirFlickBundleIdentifier]) {
        CCErrorLog(@"ERROR - AirFlick.app is not running");
        return;
    }

    // via https://gist.github.com/755600
    NSDictionary* slideDescription = [NSDictionary dictionaryWithObjectsAndKeys:
        @"show-photo", @"RequestType",
        [self.imageURL absoluteString], @"MediaLocation",
//        @"1", @"Rotation",
//        @"Dissolve", @"Transition",
        nil];

    CCDebugLog(@"sending: %@", slideDescription);

#define AirFlickNotificationName @"com.sadun.airflick"
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:AirFlickNotificationName object:nil userInfo:slideDescription deliverImmediately:YES];
}

@end
