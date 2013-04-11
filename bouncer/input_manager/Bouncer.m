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

#import "Bouncer.h"
#import "BouncerConstants.h"

@implementation Bouncer

+ (void) load
{
    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(applicationWillFinishLaunching:)
               name: NSApplicationWillFinishLaunchingNotification
             object: nil];
}

+ (void) applicationWillFinishLaunching: (NSNotification *) notification
{
    BOOL disabled = [[NSUserDefaults standardUserDefaults] boolForKey:
        BouncerDisableKey];
    if (disabled)
        return;
    
    static Bouncer * bouncer = nil;
    if (bouncer != nil)
        return;
    
    bouncer = [[self alloc] init];
    [bouncer installDO];
}

- (void) installDO;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSString * processName = [processInfo processName];
    
    NSString * connectionName = [NSString stringWithFormat:
        BouncerConnectionFormat, processName];
    NSLog(@"Registering %@", connectionName);
    mConnection = [[NSConnection defaultConnection] retain];
    [mConnection setRootObject: self];
    [mConnection registerName: connectionName];
        
    NSLog(@"Sending BouncerDOAvailable");
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        processName, @"Name",
        [mainBundle bundlePath], @"BundlePath",
        connectionName, @"ConnectionName",
        nil];

    [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName: BouncerDOAvailableNotification
                  object: nil
                userInfo: userInfo];
    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(removeDO:)
               name: NSApplicationWillTerminateNotification
             object: nil];
    
}

- (void) removeDO: (NSNotification *) notification;
{
    NSProcessInfo * processInfo = [NSProcessInfo processInfo];
    NSString * processName = [processInfo processName];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        processName, @"Name",
        nil];
    
    NSLog(@"Sending BouncerDOGone");
    [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName: BouncerDOGoneNotification
                  object: nil
                userInfo: userInfo];
}

- (void) bounce;
{
    [NSApp requestUserAttention: NSInformationalRequest];
    [NSApp cancelUserAttentionRequest: NSCriticalRequest];
}

@end
