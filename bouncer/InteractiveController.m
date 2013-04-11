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

#import "InteractiveController.h"
#import "BouncerController.h"
#import "BouncerVictim.h"
#import "BouncerView.h"
#import "BouncerSprite.h"
#import "BouncerConstants.h"
#import "DDHidLib.h"
#import <QTKit/QTKit.h>
#include <IOKit/hid/IOHIDUsageTables.h>
#import <notify.h>


@implementation InteractiveController

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mPlaybackQueue = [[NSMutableArray alloc] init];
    mCurrentPlaybackIndex = 0;
    NSString * file = [@"~/Music/Blue Danube.mov" stringByExpandingTildeInPath];
    mMovie = [[QTMovie alloc] initWithFile: file error: nil];
    
    return self;
}

- (void) awakeFromNib;
{
    [[self window] setFrameAutosaveName: @"Interactive"];
    mKeyboards = [DDHidKeyboard allKeyboards];
    [mKeyboards retain];
    for (int i = 0; i < [mKeyboards count]; i++)
    {
        DDHidKeyboard * keyboard = [mKeyboards objectAtIndex: i];
        [keyboard setDelegate: self];
        [keyboard startListening];
    }

    
    mach_port_t notify_port;
    int token_mach_port = -1;
    int status = notify_register_mach_port(BouncerRemoteStartNotification,
                                           &notify_port, 0, &token_mach_port);
    if (status != NOTIFY_STATUS_OK)
    {
        perror("notify_register_mach_port");
    }
    mNotificationPort = [[NSMachPort alloc] initWithMachPort: notify_port];
    [mNotificationPort setDelegate: self];
    [mNotificationPort scheduleInRunLoop: [NSRunLoop currentRunLoop]
                                 forMode: NSDefaultRunLoopMode];
}

- (void) handleMachMessage: (void *) machMessage
{
    NSLog(@"remoteStart");
    [NSApp activateIgnoringOtherApps: YES];
    [self showWindow: self];
    [self openPlayback: self];
    [self startPlayback: self];
}

- (unsigned) indexForUsageId: (unsigned) usageId;
{
    static const int usages[] = {
        kHIDUsage_KeyboardA,
        kHIDUsage_KeyboardS,
        kHIDUsage_KeyboardD,
        kHIDUsage_KeyboardF,
        kHIDUsage_KeyboardG,
        kHIDUsage_KeyboardH,
        kHIDUsage_KeyboardJ,
        kHIDUsage_KeyboardK,
        kHIDUsage_KeyboardL,
        kHIDUsage_KeyboardY,
        kHIDUsage_KeyboardU,
        kHIDUsage_KeyboardI,
        kHIDUsage_KeyboardO,
        kHIDUsage_KeyboardP,
        kHIDUsage_KeyboardQ,
        kHIDUsage_KeyboardW,
        kHIDUsage_KeyboardE,
        kHIDUsage_KeyboardR,
        kHIDUsage_KeyboardT,
    };
    
    unsigned index = NSNotFound;
    int keyCount = sizeof(usages)/sizeof(usages[0]);
    for (int i = 0; i < keyCount; i++)
    {
        if (usageId == usages[i])
        {
            index = i;
            break;
        }
    }
    
    return index;
}

- (void) addSpriteForIndex: (unsigned) index;
{
    NSArray * victims = [mController victims];
    BouncerVictim * victim = [victims objectAtIndex: index];
    [victim bounce];
    [victim setEffect: YES];
    NSImage * image = [victim icon];
    BouncerSprite * sprite = [[BouncerSprite alloc] initWithImage: image
                                                          atPoint: NSZeroPoint];
    [sprite setVelocity: NSMakePoint(0, 150)];
    [sprite setIndex: index];
    [sprite autorelease];
    [mBouncerView addSprite: sprite];
}

- (void) ddhidKeyboard: (DDHidKeyboard *) keyboard
               keyDown: (unsigned) usageId;
{
    if (![[self window] isVisible])
        return;
    
    unsigned index = [self indexForUsageId: usageId];
    NSArray * victims = [mController victims];
    if ((index == NSNotFound) || (index >= [victims count]))
        return;
    
    QTMovie * movie = mMovie;
    BOOL isPlaying = (movie != nil) && ([movie rate] != 0);
    if (isPlaying)
    {
        QTTime time = [movie currentTime];
        NSTimeInterval interval;
        QTGetTimeInterval(time, &interval);
        NSArray * playbackItem = [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt: index],
            [NSNumber numberWithDouble: interval],
            nil];
        [mPlaybackQueue addObject: playbackItem];
    }
    [self addSpriteForIndex: index];
}

- (NSString *) applicationSupportFolder;
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent: @"TheBouncer"];
}

- (IBAction) savePlayback: (id) sender;
{
    NSString * file = [self applicationSupportFolder];
    file = [file stringByAppendingPathExtension: @"playback.bouncer"];
    [mPlaybackQueue writeToFile: file atomically: YES];
}

- (IBAction) openPlayback: (id) sender;
{
    NSString * file = [self applicationSupportFolder];
    file = [file stringByAppendingPathExtension: @"playback.bouncer"];
    NSArray * newItems = [[[NSArray alloc] initWithContentsOfFile: file] autorelease];
    [mPlaybackQueue removeAllObjects];
    [mPlaybackQueue addObjectsFromArray: newItems];
}

- (IBAction) clearPlaybackQueue: (id) sender;
{
    [mPlaybackQueue removeAllObjects];
}

- (IBAction) recordPlayback: (id) sender;
{
    [self stopPlayback: nil];
    [mPlaybackQueue removeAllObjects];
    [mBouncerView stopAnimation];
    [mMovie gotoBeginning];
    [mMovie play];
}

- (IBAction) startPlayback: (id) sender;
{
    [self stopPlayback: nil];
    mCurrentPlaybackIndex = 0;
    mPlaybackTimer = 
        [NSTimer scheduledTimerWithTimeInterval: 1.0/120.0
                                         target: self 
                                       selector: @selector(movieTimer:)
                                       userInfo: nil
                                        repeats: YES];
    [mPlaybackTimer retain];
    [mMovie gotoBeginning];
    [mMovie play];
}

- (IBAction) stopPlayback: (id) sender;
{
    [mPlaybackTimer invalidate];
    [mPlaybackTimer release];
    mPlaybackTimer = nil;
    
    [mMovie stop];
    [mBouncerView startAnimation];
}

- (void) movieTimer: (NSTimer *) timer;
{
    QTMovie * movie = mMovie;
    if ((movie == nil) || ([movie rate] == 0))
        return;
    
    QTTime qtTime = [movie currentTime];
    NSTimeInterval currentTime;
    QTGetTimeInterval(qtTime, &currentTime);

    BOOL needsDisplay = NO;
    while (mCurrentPlaybackIndex < [mPlaybackQueue count])
    {
        NSArray * playbackItem = [mPlaybackQueue objectAtIndex: mCurrentPlaybackIndex];
        unsigned index = [[playbackItem objectAtIndex: 0] unsignedIntValue];
        double time = [[playbackItem objectAtIndex: 1] doubleValue];
        if (time <= currentTime)
        {
            [self addSpriteForIndex: index];
            mCurrentPlaybackIndex++;
            needsDisplay = YES;
        }
        else
            break;
    }
}

@end
