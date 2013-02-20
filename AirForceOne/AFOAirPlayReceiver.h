//
//  AFOAirPlayReceiver.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 16 July 2011.
//  Copyright 2011, 2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFOAirPlayReceiver : NSObject
- (id)initWithHost:(NSString*)host;
// @property (nonatomic, readonly) NSString* host;

- (void)showImageAtURL:(NSURL*)imageURL;
// - (void)playVideoAtURL:(NSURL*)videoURL;
// - (void)play;
// - (void)pause;
- (void)stop;
@end
