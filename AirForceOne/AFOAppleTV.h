//
//  AFOAppleTV.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 16 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFOAppleTV : NSObject {
@private
    NSString* _host;
}
- (id)initWithHost:(NSString*)host;
// @property (nonatomic, readonly) NSString* host;

- (void)playVideoAtURL:(NSURL*)videoURL;
- (void)stopVideo;
@end
