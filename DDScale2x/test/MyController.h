//
//  MyController.h
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyController : NSObject
{
    IBOutlet NSImageView * mImageView;
}

- (IBAction) toggleScale: (id) sender;

@end
