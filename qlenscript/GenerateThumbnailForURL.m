/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */
#include "HTMLFromSourceCode.h"

//The minimum aspect ratio (width / height) of a thumbnail.
#define MINIMUM_ASPECT_RATIO (1.0/2.0)

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSData *data = [(NSData *) createHTMLDataFromSourceCodeFile(url) autorelease];
    if (data)
    {
        CGImageRef image = NULL;

        //Render the HTML into an attributed string, for easy sizing as well as drawing.
#if 0
        NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithHTML:data baseURL:(NSURL *) url documentAttributes:NULL] autorelease];

        NSSize webViewFrameSize = [attrStr size];
        //Adjust the frame size, in order to avoid a large source file being thumbnailed as a very tall image of unreadable text.
        CGFloat aspectRatio = webViewFrameSize.width / webViewFrameSize.height;
        if (aspectRatio < MINIMUM_ASPECT_RATIO)
        {
            //We simply crop it.
            //If the minimum aspect ratio is less than 1, this division will result in the height being longer than the width; if it's greater than 1, it will result in the height being shorter than the width.
            //Room for improvement: Currently, it's possible for all the lines of text that are above the crop line to not completely use the horizontal space (caused by a longer line of text below the crop line). For this reason, it would be better to cut off the original source code somehow, to avoid the risk of wasted horizontal space.
            webViewFrameSize.height = webViewFrameSize.width / MINIMUM_ASPECT_RATIO;
        }
#else
        NSSize webViewFrameSize = NSMakeSize(800, 800);
#endif

        //Create a WebView to render the HTML.
        WebView *webView = [[[WebView alloc] initWithFrame:NSMakeRect(0.0, 0.0, webViewFrameSize.width, webViewFrameSize.height)] autorelease];
        //We don't want scroll-bars.
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
        [[webView mainFrame] loadData: data
                             MIMEType: @"text/html"
                     textEncodingName: @"utf-8"
                              baseURL: nil];

        while ([webView isLoading])
        {
#if 0
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
#else
            [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                                     beforeDate: [NSDate date]];
#endif
        }
        [webView display];

        //Generate a PDF document from the HTML.
        CFDataRef pdfData = (CFDataRef) [webView dataWithPDFInsideRect:[webView bounds]];
        if (pdfData)
        {
            //Create a CGImageSource to turn our PDF document into a CGImage.
            CGImageSourceRef source = CGImageSourceCreateWithData(pdfData, /*options*/ NULL);
            if (source) {
                NSDictionary *sourceOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                    //CGImageSource creates square thumbnails, so our maximum size should be either the max width or max height, whichever is less.
                    [NSNumber numberWithDouble:(maxSize.width < maxSize.height) ? maxSize.width : maxSize.height], kCGImageSourceThumbnailMaxPixelSize,
                    //PDF documents don't ordinaily have thumbnails, so we need to tell CGImageSource to create one.
                    (id) kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageIfAbsent,
                    nil];
                image = CGImageSourceCreateThumbnailAtIndex(source, /*index*/ 0, (CFDictionaryRef) sourceOptions);
                if (image)
                    QLThumbnailRequestSetImage(thumbnail, image, /*properties*/ NULL);
                
                CFRelease(source);
            }
        }

    }
    [pool release];
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
