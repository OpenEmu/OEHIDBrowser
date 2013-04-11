//
//  DDScale2xView.h
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface DDScale2xView : NSView {
    CIImage * inputImage;
    CIFilter * filter;
}

@end
