/*
 * Copyright (c) 2006 Dave Dribin
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

#import "BasicOpenGLView.h"

static const int FULL_SCREEN_WIDTH = 640;
static const int FULL_SCREEN_HEIGHT = 480;

#define USE_CV_PIXEL_BUFFER 1
#define DOUBLE_BUFFERED 1

@interface BasicOpenGLView (Private)

- (CGImageRef) createImage;
- (void) loadTexture;
- (void) createTexture: (CGImageRef) image;
- (void) createTextureWithCoreVideo: (CGImageRef) image;
- (void) drawImage: (CGImageRef) image toBuffer: (void *) buffer
             width: (size_t) width height: (size_t) height
       bytesPerRow: (size_t) bytesPerRow;

@end

@implementation BasicOpenGLView

-(id) initWithFrame: (NSRect) frameRect
{
    NSOpenGLPixelFormatAttribute colorSize = 32;
    NSOpenGLPixelFormatAttribute depthSize = 32;
    
    // pixel format attributes for the view based (non-fullscreen) NSOpenGLContext
    NSOpenGLPixelFormatAttribute windowedAttributes[] =
    {
        // specifying "NoRecovery" gives us a context that cannot fall back to the software renderer
        // this makes the view-based context a compatible with the fullscreen context,
        // enabling us to use the "shareContext" feature to share textures, display lists, and other OpenGL objects between the two
        NSOpenGLPFANoRecovery,
        // attributes common to fullscreen and window modes
        NSOpenGLPFAColorSize, colorSize,
        NSOpenGLPFADepthSize, depthSize,
#if DOUBLE_BUFFERED
        NSOpenGLPFADoubleBuffer,
#endif
        NSOpenGLPFAAccelerated,
        0
    };
    NSOpenGLPixelFormat * windowedPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: windowedAttributes];
    [windowedPixelFormat autorelease];
    
    self = [super initWithFrame: frameRect pixelFormat: windowedPixelFormat];
    if (self == nil)
        return nil;
    
    [self setSyncToRefresh: YES];
    
    // pixel format attributes for the full screen NSOpenGLContext
    NSOpenGLPixelFormatAttribute fullScreenAttributes[] =
    {
        // specify that we want a fullscreen OpenGL context
        NSOpenGLPFAFullScreen,
        // we may be on a multi-display system (and each screen may be driven
        // by a different renderer), so we need to specify which screen we want
        // to take over. 
        // in this case, we'll specify the main screen.
        NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
        // attributes common to fullscreen and window modes
        NSOpenGLPFAColorSize, colorSize,
        NSOpenGLPFADepthSize, depthSize,
#if DOUBLE_BUFFERED
        NSOpenGLPFADoubleBuffer,
#endif
        NSOpenGLPFAAccelerated,
        0
    };
    NSOpenGLPixelFormat * fullScreenPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: fullScreenAttributes];
    [fullScreenPixelFormat autorelease];
    [self setFullScreenPixelFormat: fullScreenPixelFormat];
    
    [self setFullScreenWidth: FULL_SCREEN_WIDTH height: FULL_SCREEN_HEIGHT];
    
    mRect = NSMakeRect(0, 0, 160, 120);
    mDirX = mDirY = 1;
    mLastTime = 0.0f;
    [self loadTexture];
    
    return self;
}

- (void) dealloc
{
    CVOpenGLTextureRelease(mTexture);
    [super dealloc];
}

- (void) prepareOpenGL: (NSOpenGLContext *) context;
{
    // init GL stuff here
    glEnable(GL_DEPTH_TEST);
    
    glShadeModel(GL_SMOOTH);    
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
    glPolygonOffset(1.0f, 1.0f);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void) update
{
    [super update];
}

- (void) resize: (NSRect) bounds
{
    glViewport(bounds.origin.x, bounds.origin.y, bounds.size.width,
               bounds.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, bounds.size.width, 0, bounds.size.height, 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (void) didEnterFullScreen;
{
    NSLog(@"Enter full screen");
}

- (void) didExitFullScreen;
{
    NSLog(@"Exit full screen");
}

- (void) updateAnimation;
{
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    
    if (mLastTime == 0.0f)
    {
        mRect.origin = NSMakePoint(0.0f, 0.0f);
        mLastTime = currentTime;
        return;
    }
    
    CFAbsoluteTime diff = currentTime - mLastTime;
    mRect.origin.x += 250 * mDirX * diff;
    mRect.origin.y += 300 * mDirY * diff;
    
    if (mRect.origin.x < 0)
    {
        mDirX = 1;
        mRect.origin.x = 0;
    }
    if (NSMaxX(mRect) > FULL_SCREEN_WIDTH)
    {
        mDirX = -1;
        mRect.origin.x = FULL_SCREEN_WIDTH - mRect.size.width;
    }
    if (mRect.origin.y < 0)
    {
        mDirY = 1;
        mRect.origin.y = 0;
    }
    if (NSMaxY(mRect) > FULL_SCREEN_HEIGHT)
    {
        mDirY = -1;
        mRect.origin.y = FULL_SCREEN_HEIGHT - mRect.size.height;
    }
    
    mLastTime = currentTime;
    return;
}

- (void) drawFrame
{
    NSRect bounds = [self activeBounds];
    [self resize: bounds];
    
    // clear our drawable
    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    NSRect rect;
    float z;
    
    z = 0.0f;
    rect = NSMakeRect(0.0f, 0.0f, FULL_SCREEN_WIDTH - 1, FULL_SCREEN_HEIGHT - 1);
    
    if ([self syncToRefresh])
        glColor3f(1.0f, 0.0f, 0.0f);
    else
        glColor3f(0.0f, 1.0f, 0.0f);
    glBegin(GL_LINES);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);

    glVertex3f(NSMaxX(rect),        rect.origin.y,      z);
    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);

    glVertex3f(NSMaxX(rect),        NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);

    glVertex3f(rect.origin.x,       NSMaxY(rect),       z);
    glVertex3f(rect.origin.x,       rect.origin.y,      z);
    glEnd();

    GLfloat vertices[4][2];
    GLfloat texCoords[4][2];
    
    glColor3f(1.0f, 1.0f, 1.0f);
    // Configure OpenGL to get vertex and texture coordinates from our two arrays
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    
    rect = mRect;
    // Top left
    vertices[0][0] = rect.origin.x;
    vertices[0][1] = rect.origin.y;
    // Bottom left
    vertices[1][0] = NSMaxX(rect);
    vertices[1][1] = rect.origin.y;
    // Bottom right
    vertices[2][0] = NSMaxX(rect);
    vertices[2][1] = NSMaxY(rect);
    // Top right
    vertices[3][0] = rect.origin.x;
    vertices[3][1] = NSMaxY(rect);
    
    
    // Get the current texture's coordinates, bind the texture,and draw our
    // rectangle
    rect.origin = NSMakePoint(0, 0);
    texCoords[0][0] = rect.origin.x;
    texCoords[0][1] = rect.origin.y;
    texCoords[1][0] = NSMaxX(rect);
    texCoords[1][1] = rect.origin.y;
    texCoords[2][0] = NSMaxX(rect);
    texCoords[2][1] = NSMaxY(rect);
    texCoords[3][0] = rect.origin.x;
    texCoords[3][1] = NSMaxY(rect);

    glEnable(mTextureTarget);
    glTexParameteri(mTextureTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(mTextureTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glBindTexture(mTextureTarget, mTextureName);
    glDrawArrays(GL_QUADS, 0, 4);
    glDisable(mTextureTarget);
}

@end

@implementation BasicOpenGLView (Private)

- (CGImageRef) createImage;
{
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * path = [myBundle pathForImageResource: @"image"];
    NSURL * url = [NSURL fileURLWithPath: path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef) url, nil);
    CGImageRef image = CGImageSourceCreateImageAtIndex (imageSource, 0, nil);
    CFRelease(imageSource);
    
    return image;
}

- (void) loadTexture;
{
    mTexture = NULL;
    
    CGImageRef image = [self createImage];

    if (!USE_CV_PIXEL_BUFFER)
    {
        NSLog(@"Create texture directly");
        [self createTexture: image];
    }
    else
    {
        NSLog(@"Create texture with Core Video");
        [self createTextureWithCoreVideo: image];
    }
    
    CFRelease(image);
}

- (void) createTexture: (CGImageRef) image;
{    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    void * pixelBuffer = calloc(width*4, height);
    [self drawImage: image toBuffer: pixelBuffer
              width: width height: height
        bytesPerRow: width*4];

    [[self openGLContext] makeCurrentContext];
    glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &mTextureName);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, mTextureName);
    glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, 
                    GL_TEXTURE_MIN_FILTER, GL_LINEAR);
#if __BIG_ENDIAN__
    GLenum type = GL_UNSIGNED_INT_8_8_8_8_REV;
#else
    GLenum type = GL_UNSIGNED_INT_8_8_8_8;
#endif
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height,
                 0, GL_BGRA_EXT, type, pixelBuffer);
    free(pixelBuffer);

    mTextureTarget = GL_TEXTURE_RECTANGLE_ARB;
    mRect.size.width = width;
    mRect.size.height = height;
}

- (void) createTextureWithCoreVideo: (CGImageRef) image;
{
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    CVReturn rc;
    CVPixelBufferRef pixelBuffer;
    rc = CVPixelBufferCreate(NULL,
                             width,
                             height,
                             k32ARGBPixelFormat,
                             NULL, // pixelBufferAttributes
                             &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void * baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    [self drawImage: image toBuffer: baseAddress
              width: width height: height
        bytesPerRow: bytesPerRow];

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    // It is rather wasteful to create the cache, and delete it right away,
    // but the only way to create a CVOpenGLTexture is with a cache.
    CVOpenGLTextureCacheRef textureCache;
    rc = CVOpenGLTextureCacheCreate(NULL, NULL,
                                    [[self openGLContext] CGLContextObj],
                                    [[self pixelFormat] CGLPixelFormatObj],
                                    NULL,
                                    &textureCache);
    
    rc = CVOpenGLTextureCacheCreateTextureFromImage(NULL,
                                                    textureCache,
                                                    pixelBuffer,
                                                    NULL,
                                                    &mTexture);
    CVOpenGLTextureCacheRelease(textureCache);
    CVPixelBufferRelease(pixelBuffer);

    mTextureName = CVOpenGLTextureGetName(mTexture);
    mTextureTarget = CVOpenGLTextureGetTarget(mTexture);
    mRect.size.width = width;
    mRect.size.height = height;
}

- (void) drawImage: (CGImageRef) image toBuffer: (void *) buffer
             width: (size_t) width height: (size_t) height
       bytesPerRow: (size_t) bytesPerRow;
{
    CGRect rect = {{0, 0}, {width, height}};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(buffer, 
                                                       width, height, 8,
                                                       bytesPerRow, space, 
                                                       kCGImageAlphaPremultipliedFirst);

    
    // Flip the axis, as per:
    // http://developer.apple.com/qa/qa2001/qa1009.html
   
    //  Move the CG origin to the upper left of the port
    CGContextTranslateCTM(bitmapContext, 0,
                         (float)(height));
    
    //  Flip the y axis so that positive Y points down
    CGContextScaleCTM(bitmapContext, 1.0, -1.0);
    
    CGContextDrawImage(bitmapContext, rect, image);
    CGContextRelease(bitmapContext);
}

@end

