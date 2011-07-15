//
//  AirForceOnePlugin.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface AirForceOnePlugIn : QCPlugIn {
@private
    NSURL* _imageURL;
}
@property (nonatomic, assign) NSString* inputImageLocation;
@end
