//
//  MyObject.h
//  DDDelegateHelper
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RUN_BENCHMARK 0
#define BENCHMARK_AUTORELEASE_COUNT 0

#if RUN_BENCHMARK
#define NSLog(...)
#endif

#define DELEGATE_OPTION 5

@class MyObjectDelegate;
@class MDelegateManager;
@class DDDelegateManager;


#if DELEGATE_OPTION == 7
#include <map>

typedef std::map<SEL, BOOL> SelectorMap;
#endif


@interface MyObject : NSObject
{
#if (DELEGATE_OPTION == 1) || (DELEGATE_OPTION == 2) || (DELEGATE_OPTION == 4) || (DELEGATE_OPTION == 7)
    id mDelegate;
#endif
#if DELEGATE_OPTION == 3
    MyObjectDelegate * mDelegateHelper;
#elif DELEGATE_OPTION == 4
    BOOL mHasDidDoSomethingDelegate;
    BOOL mHasShouldResetCountDelegate;
#elif DELEGATE_OPTION == 5
    MDelegateManager * mDelegateManager;
#elif DELEGATE_OPTION == 6
    DDDelegateManager * mDelegateManager;
#elif DELEGATE_OPTION == 7
    SelectorMap mSelectorMap;
#endif
    int mCount;
}

- (void) setDelegate: (id) delegate;
- (void) doSomething;
- (void) incrementCount;

@end

@interface NSObject (MyObjectDelegate)

- (void) myObjectDidDoSomething: (MyObject *) myObject;
- (BOOL) myObjectShouldResetCount: (MyObject *) myObject count: (int) count;

@end
