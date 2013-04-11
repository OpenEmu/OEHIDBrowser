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

#import "BouncerVictim.h"


@implementation BouncerVictim

- (id) initWithNoficationInfo: (NSDictionary *) userInfo;
{
    self = [super init];
    if (self == nil)
        return nil;
    

    mName = [[userInfo valueForKey: @"Name"] retain];

    NSString * fullPath = [userInfo valueForKey: @"BundlePath"];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    mIcon = [[workspace iconForFile: fullPath] retain];
    [mIcon setScalesWhenResized: YES];
    [mIcon setSize: NSMakeSize(16.0, 16.0)];
    
    NSString * connectionName = [userInfo valueForKey: @"ConnectionName"];
    mVictim = [[NSConnection rootProxyForConnectionWithRegisteredName: connectionName
                                                                 host: nil] retain];

    return self;
}

- (id) initWithWorkspaceApplication: (NSDictionary *) application;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    NSString * name = [application valueForKey: @"NSApplicationName"];
    NSString * connectionName = [NSString stringWithFormat:
        @"DDBouncerVictimDO %@", name];
        
    mVictim = [[NSConnection rootProxyForConnectionWithRegisteredName: connectionName
                                                                 host: nil] retain];
    if (mVictim == nil)
    {
        [self release];
        return nil;
    }
    
    mName = [name retain];
    
    NSString * fullPath = [application valueForKey: @"NSApplicationPath"];
    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    mIcon = [[workspace iconForFile: fullPath] retain];
    [mIcon setScalesWhenResized: YES];
    [mIcon setSize: NSMakeSize(16.0, 16.0)];
    
    return self;
}

- (NSString *) name;
{
    return mName;
}

- (NSImage *) icon;
{
    return mIcon;
}

- (void) bounce;
{
    [mVictim bounce];
}

//=========================================================== 
// - effect
//=========================================================== 
- (BOOL) effect
{
    return mEffect;
}

//=========================================================== 
// - setEffect:
//=========================================================== 
- (void) setEffect: (BOOL) flag
{
    mEffect = flag;
}

@end
