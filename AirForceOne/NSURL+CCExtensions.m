//
//  NSURL+CCExtensions.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 31 Dec 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "NSURL+CCExtensions.h"

@implementation NSURL (CCExtensions)

- (id)initFileURLWithPossiblyRelativeString:(NSString*)filePath relativeTo:(NSString*)base isDirectory:(BOOL)isDir {
    if ([filePath hasPrefix:@"file://"]) {
        self = [self initWithString:filePath];
    } else {
        if (![filePath hasPrefix:@"/"] && ![filePath hasPrefix:@"~"]) {
            filePath = [base stringByAppendingPathComponent:[filePath stringByStandardizingPath]];
        }
        filePath = [filePath stringByStandardizingPath];
        self = [self initFileURLWithPath:filePath isDirectory:isDir];
    }

    return self;
}

@end
