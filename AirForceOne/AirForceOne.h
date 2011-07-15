//
//  AirForceOne.h
//  AirForceOne
//
//  Created by Jean-Pierre Mouilleseaux on 15 July 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#ifdef DEBUG
    #define CCDebugLogSelector() NSLog(@"-[%@ %@]", /*NSStringFromClass([self class])*/self, NSStringFromSelector(_cmd))
    #define CCDebugLog(a...) NSLog(a)
    #define CCWarningLog(a...) NSLog(a)
    #define CCErrorLog(a...) NSLog(a)
#else
    #define CCDebugLogSelector()
    #define CCDebugLog(a...)
    #define CCWarningLog(a...) NSLog(a)
    #define CCErrorLog(a...) NSLog(a)
#endif

#define CCLocalizedString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:(nil)]
