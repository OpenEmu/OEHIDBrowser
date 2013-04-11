/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <unistd.h>
#import <QuickTime/QuickTime.h>
#import <unistd.h>
#import "BouncerController.h"
#import "BouncerVictim.h"
#import "BouncerConstants.h"

@interface BouncerController (Private)

- (void) findExistingVictims;

@end

@implementation BouncerController

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mVictims = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) awakeFromNib;
{
    [mVictimsTable setDoubleAction: @selector(bounceSelectedVictims:)];
    [self findExistingVictims];
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification;
{
    [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(bouncerDOAvailable:)
               name: BouncerDOAvailableNotification
             object: nil];

    [[NSDistributedNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(bouncerDOGone:)
               name: BouncerDOGoneNotification
             object: nil];
}

- (void) bouncerDOAvailable: (NSNotification *) notification;
{
    NSDictionary * userInfo = [notification userInfo];
    NSLog(@"bouncerDOAvailable: %@", userInfo);
    
    BouncerVictim * victim = [[BouncerVictim alloc] initWithNoficationInfo: userInfo];
    [victim autorelease];
    [self willChangeValueForKey: @"victims"];
    [mVictims addObject: victim];
    [self didChangeValueForKey: @"victims"];
}

- (void) bouncerDOGone: (NSNotification *) notification;
{
    NSDictionary * userInfo = [notification userInfo];
    NSLog(@"bouncerDOGone: %@", userInfo);
    NSString * name = [userInfo valueForKey: @"Name"];
    NSMutableIndexSet * indexes = [NSMutableIndexSet indexSet];
    for (int i = 0; i < [mVictims count]; i++)
    {
        BouncerVictim * victim = [mVictims objectAtIndex: i];
        if ([[victim name] isEqualToString: name])
        {
            [indexes addIndex: i];
        }
    }
    [self willChangeValueForKey: @"victims"];
    [mVictims removeObjectsAtIndexes: indexes];
    [self didChangeValueForKey: @"victims"];

}

- (NSArray *) victims;
{
    return mVictims;
}

- (IBAction) bounceSelectedVictims: (id) sender;
{
    if ((sender == mVictimsTable) && ([mVictimsTable clickedRow] == -1))
        return;
    
    NSArray * selectedVictims = [mVictimsController selectedObjects];
    [selectedVictims makeObjectsPerformSelector: @selector(bounce)];
}

- (IBAction) bounceInPattern: (id) sender;
{
    useconds_t intervals[] =
    {
        500000,
        500000,
        500000,
        500000,
        750000,

        0,
        500000,

        0,
        750000,

        0,
        500000,

        0,
        0,
    };
    
    int count = sizeof(intervals)/sizeof(useconds_t);
    
    int i;
    for (i = 0; i < count; i++)
    {
        if (i == [mVictims count])
            break;
        
        BouncerVictim * victim = [mVictims objectAtIndex: i];
        [victim bounce];
        if (intervals[i] > 0)
            usleep(intervals[i]);
    }
    
}

@end


@implementation BouncerController (Private)

- (void) findExistingVictims;
{
    NSArray * applications = [[NSWorkspace sharedWorkspace] launchedApplications];
    [self willChangeValueForKey: @"victims"];
    for (int i = 0; i < [applications count]; i++)
    {
        NSDictionary * application = [applications objectAtIndex: i];
        BouncerVictim * victim = [[BouncerVictim alloc] initWithWorkspaceApplication:
            application];
        if (victim == nil)
        {
            NSLog(@"Skipping %@", [application valueForKey: @"NSApplicationName"]);
        }
        else
        {
            [mVictims addObject: victim];
        }
    }
    [self didChangeValueForKey: @"victims"];
}

@end

