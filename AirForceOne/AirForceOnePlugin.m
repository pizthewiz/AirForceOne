//
//  AirForceOnePlugIn.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011-2013 Chorded Constructions. All rights reserved.
//

#import "AirForceOnePlugIn.h"
#import "AirForceOne.h"
#import "AFOAirPlayReceiver.h"
#import "NSURL+CCExtensions.h"

static NSString* const AFOExampleCompositionName = @"Display On Apple TV";

@interface AirForceOnePlugIn()
@property (nonatomic, strong) AFOAirPlayReceiver* receiver;
@property (nonatomic, strong) NSString* host;
@property (nonatomic, strong) NSURL* imageURL;
@property (nonatomic) CGSize maximumSize;
@end

@implementation AirForceOnePlugIn

@dynamic inputHost, inputImageLocation, inputMaximumWidth, inputMaximumHeight, inputSendSignal;

+ (NSDictionary*)attributes {
    return @{
        QCPlugInAttributeNameKey: CCLocalizedString(@"kQCPlugIn_Name", NULL),
        QCPlugInAttributeDescriptionKey: CCLocalizedString(@"kQCPlugIn_Description", NULL),
        QCPlugInAttributeCategoriesKey: @[@"Render", @"Destination"],
        QCPlugInAttributeExamplesKey: @[[[NSBundle bundleForClass:[self class]] URLForResource:AFOExampleCompositionName withExtension:@"qtz"]]
    };
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"inputHost"]) {
        return @{QCPortAttributeNameKey: @"Host"};
    } else if ([key isEqualToString:@"inputImageLocation"]) {
        return @{QCPortAttributeNameKey: @"Image Location"};
    } else if ([key isEqualToString:@"inputMaximumWidth"]) {
        return @{
            QCPortAttributeNameKey: @"Maximum Width Pixels",
            QCPortAttributeMinimumValueKey: @1,
            QCPortAttributeMaximumValueKey: @10000,
            QCPortAttributeDefaultValueKey: @1280
        };
    } else if ([key isEqualToString:@"inputMaximumHeight"]) {
        return @{
            QCPortAttributeNameKey: @"Maximum Height Pixels",
            QCPortAttributeMinimumValueKey: @1,
            QCPortAttributeMaximumValueKey: @10000,
            QCPortAttributeDefaultValueKey: @720
        };
    } else if ([key isEqualToString:@"inputSendSignal"]) {
        return @{QCPortAttributeNameKey: @"Send Signal"};
    }
	return nil;
}

+ (QCPlugInExecutionMode)executionMode {
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode)timeMode {
	return kQCPlugInTimeModeNone;
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
    if (!([self didValueForInputKeyChange:@"inputHost"] || [self didValueForInputKeyChange:@"inputImageLocation"] || [self didValueForInputKeyChange:@"inputMaximumWidth"] || [self didValueForInputKeyChange:@"inputMaximumHeight"] || ([self didValueForInputKeyChange:@"inputSendSignal"] && self.inputSendSignal))) {
        return YES;
    }

//    CCDebugLogSelector();

    if ([self didValueForInputKeyChange:@"inputHost"] && ![self.inputHost isEqualToString:@""]) {
        self.receiver = [[AFOAirPlayReceiver alloc] initWithHost:self.inputHost];
    }
    if ([self didValueForInputKeyChange:@"inputImageLocation"]) {
        NSURL* url = nil;
        if (![self.inputImageLocation hasPrefix:@"http://"]) {
            NSString* baseDirectory = [[[context compositionURL] URLByDeletingLastPathComponent] path];
            url = [[NSURL alloc] initFileURLWithPossiblyRelativeString:self.inputImageLocation relativeTo:baseDirectory isDirectory:NO];
            // TODO - may be better to just let it fail later?
            if (![url isFileURL]) {
                CCErrorLog(@"ERROR - filed to create URL for path '%@'", self.inputImageLocation);
            }
            NSError* error;
            if (![url checkResourceIsReachableAndReturnError:&error]) {
                CCErrorLog(@"ERROR - bad image URL: %@", [error localizedDescription]);
                return YES;
            }
        } else {
            url = [NSURL URLWithString:self.inputImageLocation];
        }

        self.imageURL = url;

        // TODO - some sort of file validation?
    }

    if ([self didValueForInputKeyChange:@"inputMaximumWidth"]) {
        self.maximumSize = CGSizeMake(self.inputMaximumWidth, self.maximumSize.height);
    }
    if ([self didValueForInputKeyChange:@"inputMaximumHeight"]) {
        self.maximumSize = CGSizeMake(self.maximumSize.width, self.inputMaximumHeight);
    }

    if (!self.receiver || !self.imageURL) {
        return YES;
    }

    CCDebugLog(@"will display image at location: %@", self.imageURL);

    [self _sendToReceiver];

    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/

    CCDebugLogSelector();


    [self.receiver stop];
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/

    CCDebugLogSelector();

    // TODO - [self.receiver stop] ?
}

#pragma mark - PRIVATE

- (void)_sendToReceiver {
    CCDebugLogSelector();

    if (!self.receiver) {
        CCWarningLog(@"WARNING - Apple TV not configured, cannot display image");
        return;
    }

// #define AFOVideoURLDefault @"http://www.808.dk/pics/video/gizmo.mp4"
//     NSURL* contentURL = [[NSURL alloc] initWithString:AFOVideoURLDefault];
//     [self.appleTV playVideoAtURL:contentURL];

    [self.receiver showImageAtURL:self.imageURL maximumSize:self.maximumSize];
}

@end
