//
//  NSURL+CCExtensions.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 12/31/11.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CCExtensions)
- (id)initFileURLWithPossiblyRelativePath:(NSString*)path relativeTo:(NSString*)base isDirectory:(BOOL)isDir;
@end
