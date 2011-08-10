//
//  AirForceOnePlugIn.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "AirForceOnePlugIn.h"
#import "AirForceOne.h"
#import "AFOAppleTV.h"

static NSString* const AFOExampleCompositionName = @"Display On Apple TV";

@interface AirForceOnePlugIn()
@property (nonatomic, retain) AFOAppleTV* appleTV;
@property (nonatomic, retain) NSString* host;
@property (nonatomic, retain) NSURL* imageURL;
- (void)_sendToAppleTV;
@end

@implementation AirForceOnePlugIn

@dynamic inputHost, inputImageLocation;
@synthesize appleTV = _appleTV, host = _host, imageURL = _imageURL;

+ (NSDictionary*)attributes {
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
       CCLocalizedString(@"kQCPlugIn_Name", NULL), QCPlugInAttributeNameKey, 
       CCLocalizedString(@"kQCPlugIn_Description", NULL), QCPlugInAttributeDescriptionKey, 
       nil];

#if defined(MAC_OS_X_VERSION_10_7) && (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7)
    if (&QCPlugInAttributeCategoriesKey != NULL) {
        // array with category strings
        NSArray* categories = [NSArray arrayWithObjects:@"Render", @"Destination", nil];
        [attributes setObject:categories forKey:QCPlugInAttributeCategoriesKey];
    }
    if (&QCPlugInAttributeExamplesKey != NULL) {
        // array of file paths or urls relative to plugin resources
        NSArray* examples = [NSArray arrayWithObjects:[[NSBundle bundleForClass:[self class]] URLForResource:AFOExampleCompositionName withExtension:@"qtz"], nil];
        [attributes setObject:examples forKey:QCPlugInAttributeExamplesKey];
    }
#endif

    return (NSDictionary*)attributes;
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"inputHost"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Host", QCPortAttributeNameKey, nil];
    else if ([key isEqualToString:@"inputImageLocation"])
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
    [_appleTV release];
    [_host release];
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
    // quick bail
    if (![self didValueForInputKeyChange:@"inputHost"] && ![self didValueForInputKeyChange:@"inputImageLocation"])
        return YES;

    CCDebugLogSelector();

    if ([self didValueForInputKeyChange:@"inputHost"] && ![self.inputHost isEqualToString:@""]) {
        AFOAppleTV* appleTV = [[AFOAppleTV alloc] initWithHost:self.inputHost];
        self.appleTV = appleTV;
        [appleTV release];
    }
    if ([self didValueForInputKeyChange:@"inputImageLocation"]) {
        NSURL* url = [NSURL URLWithString:self.inputImageLocation];
        // scheme-less would suggest a relative file url
        if (![url scheme]) {
            NSURL* baseDirectoryURL = [[context compositionURL] URLByDeletingLastPathComponent];
//            NSString* cleanFilePath = [[[baseDirectoryURL path] stringByAppendingPathComponent:self.inputImageLocation] stringByStandardizingPath];
//            CCDebugLog(@"cleaned file path: %@", cleanFilePath);
            url = [baseDirectoryURL URLByAppendingPathComponent:self.inputImageLocation];

            // TODO - may be better to just let it fail later?
            if (![url checkResourceIsReachableAndReturnError:NULL]) {
                return YES;
            }
        }

        self.imageURL = url;

        // TODO - some sort of file validation?
    }

    if (!self.appleTV || !self.imageURL)
        return YES;

    CCDebugLog(@"will display image at location: %@", self.imageURL);

    [self _sendToAppleTV];

    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/

    CCDebugLogSelector();

    // TODO - [self.appleTV stop] ?
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/

    CCDebugLogSelector();

    // TODO - [self.appleTV stop] ?
}

#pragma mark - PRIVATE

- (void)_sendToAppleTV {
    CCDebugLogSelector();

    if (!self.appleTV) {
        CCWarningLog(@"WARNING - Apple TV not configured, cannot display image");
        return;
    }

// #define AFOVideoURLDefault @"http://www.808.dk/pics/video/gizmo.mp4"
//     NSURL* contentURL = [[NSURL alloc] initWithString:AFOVideoURLDefault];
//     [self.appleTV playVideoAtURL:contentURL];
//     [contentURL release];

    [self.appleTV showImageAtURL:_imageURL];
}

@end
