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

#import "BouncerSprite.h"


@implementation BouncerSprite

- (id) initWithImage: (NSImage *) image atPoint: (NSPoint) point;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mImage = [image retain];
    mCurrentPoint = point;
    mVelocity = NSZeroPoint;
    
    return self;
}

- (NSPoint) currentPoint;
{
    return mCurrentPoint;
}

- (void) setVelocity: (NSPoint) velocity;
{
    mVelocity = velocity;
}

- (void) updateForElapsedTime: (NSTimeInterval) elapsedTime;
{
    mCurrentPoint.x += mVelocity.x * elapsedTime;
    mCurrentPoint.y += mVelocity.y * elapsedTime;
}

- (void) update: (float) width x: (float) x;
{
}

- (void) setIndex: (int) index;
{
    mIndex = index;
}

- (void) drawWithWidth: (float) width;
{
    [mImage setSize: NSMakeSize(width, width)];
    mCurrentPoint.x = mIndex * width;;
    [mImage drawAtPoint: mCurrentPoint
               fromRect: NSZeroRect
              operation: NSCompositeSourceAtop
               fraction: 1.0 - (mCurrentPoint.y / 200)];
}

@end

