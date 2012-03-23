//
//  AirForceOnePlugin.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>

@class AFOAppleTV;

@interface AirForceOnePlugIn : QCPlugIn {
@private
    AFOAppleTV* _appleTV;
    NSString* _host;
    NSURL* _imageURL;
}
@property (nonatomic, weak) NSString* inputHost;
@property (nonatomic, weak) NSString* inputImageLocation;
@property (nonatomic) BOOL inputSendSignal;
@end
