//
//  MyController.m
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MyController.h"


@implementation MyController

- (IBAction) toggleScale: (id) sender;
{
    if ([sender state] == NSOnState)
        [mImageView setImageScaling: NSScaleToFit];
    else
        [mImageView setImageScaling: NSScaleNone];
}

@end
