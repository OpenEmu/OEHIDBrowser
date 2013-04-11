//
//  DLDWidgetRunner.m
//  WidgetRunner
//
//  Created by Dave Dribin on 7/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DLDWidgetRunner.h"

@interface WidgetInstallerController : NSObject

- (void) run: (id) target;
- (void) ok: (id) target;

@end

@implementation DLDWidgetRunner

+ (void) load
{
    WidgetInstallerController * controller = [NSApp targetForAction: @selector(run:)];
    [controller performSelectorOnMainThread: @selector(run:) withObject: nil waitUntilDone: NO];
}

@end
