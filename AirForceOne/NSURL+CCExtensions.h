//
//  NSURL+CCExtensions.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 31 Dec 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (CCExtensions)
- (id)initFileURLWithPossiblyRelativeString:(NSString*)path relativeTo:(NSString*)base isDirectory:(BOOL)isDir;
@end
