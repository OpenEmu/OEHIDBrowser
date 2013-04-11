//
//  DDDelegateHelper.h
//  delegate
//
//  Created by Dave Dribin on 1/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDDelegateHelper : NSObject
{
    @public
    id mDelegate;
    NSMutableDictionary * mSelectors;
    BOOL mCalledDelegate;
}

- (id) delegate;
- (void) setDelegate: (id) theDelegate;

- (BOOL) shouldCallSelector: (SEL) selector;
- (BOOL) willCallSelector: (SEL) selector;
- (BOOL) calledDelegate;

@end
