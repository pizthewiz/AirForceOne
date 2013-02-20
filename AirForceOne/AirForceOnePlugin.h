//
//  AirForceOnePlugin.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011-2013 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface AirForceOnePlugIn : QCPlugIn
@property (nonatomic, weak) NSString* inputHost;
@property (nonatomic, weak) NSString* inputImageLocation;
@property (nonatomic) NSUInteger inputMaximumWidth;
@property (nonatomic) NSUInteger inputMaximumHeight;
@property (nonatomic) BOOL inputSendSignal;
@end
