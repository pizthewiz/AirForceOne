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
}

- (void)stop {
}

@end
