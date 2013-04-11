//
//  DDDelegateHelper.m
//  delegate
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDDelegateHelper.h"

#define USE_CPP_MAP 0

#if USE_CPP_MAP == 1
#include <map>

typedef std::map<SEL, BOOL> SelectorMap;
SelectorMap sSelectors;
#endif

@implementation DDDelegateHelper

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mSelectors = [[NSMutableDictionary alloc] init];
    
    return self;
}

//=========================================================== 
// - delegate
//=========================================================== 
- (id) delegate
{
    return mDelegate; 
}

//=========================================================== 
// - setDelegate:
//=========================================================== 
- (void) setDelegate: (id) theDelegate
{
    mDelegate = theDelegate;
#if USE_CPP_MAP == 1
    sSelectors.clear();
#else
    [mSelectors removeAllObjects];
#endif
}

- (BOOL) shouldCallSelector: (SEL) selector;
{
#if USE_CPP_MAP == 1
    SelectorMap::const_iterator i = sSelectors.find(selector);
    if (i != sSelectors.end())
    {
        return i->second;
    }
    BOOL shouldCallSelector;
    if ([mDelegate respondsToSelector: selector])
        shouldCallSelector = YES;
    else
        shouldCallSelector = NO;
    sSelectors[selector] = shouldCallSelector;
    return shouldCallSelector;
    
#else
    NSValue * selectorValue = [NSValue valueWithPointer: selector];
    NSNumber * shouldCallSelector = [mSelectors objectForKey: selectorValue];
    if (shouldCallSelector == nil)
    {
        if ([mDelegate respondsToSelector: selector])
            shouldCallSelector = [NSNumber numberWithBool: YES];
        else
            shouldCallSelector = [NSNumber numberWithBool: NO];
        [mSelectors setObject: shouldCallSelector
                       forKey: selectorValue];
    }
    return [shouldCallSelector boolValue];
#endif
}

- (BOOL) willCallSelector: (SEL) selector;
{
    BOOL shouldCallSelector = [self shouldCallSelector: selector];
    BOOL calledDelegate = NO;
    if (shouldCallSelector)
        calledDelegate = YES;
    mCalledDelegate = calledDelegate;
    return shouldCallSelector;
}

- (BOOL) calledDelegate;
{
    return mCalledDelegate;
}

@end
