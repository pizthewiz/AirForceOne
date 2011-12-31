//
//  NSURL+CCExtensions.m
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 12/31/11.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "NSURL+CCExtensions.h"

@implementation NSURL (CCExtensions)

- (id)initFileURLWithPossiblyRelativePath:(NSString*)filePath relativeTo:(NSString*)base isDirectory:(BOOL)isDir {
    if (![filePath hasPrefix:@"/"]) {
        filePath = [base stringByAppendingPathComponent:[filePath stringByStandardizingPath]];
    }
    filePath = [filePath stringByStandardizingPath];
    
    self = [self initFileURLWithPath:filePath isDirectory:isDir];
    if (self) {
    }
    return self;
}

@end
