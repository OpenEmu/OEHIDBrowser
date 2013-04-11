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

#import "ByteSizeFormatter.h"

@implementation ByteSizeFormatter

+ (ByteSizeUnits) unitsForSize: (unsigned long long) bytes;
{
    if (bytes < 1024)
        return ByteSizeBytes;
    float floatBytes = bytes/1024.0;
    if (floatBytes < 1024)
        return ByteSizeKilobytes;
    
    floatBytes /= 1024.0;
    if (floatBytes < 1024)
        return ByteSizeMegabytes;
    
    return ByteSizeGigabytes;
}

+ (NSString *) format: (unsigned long long) bytes
            withUnits: (ByteSizeUnits) units;
{
    float floatBytes = bytes;
    switch(units)
    {
        case ByteSizeKilobytes:
            floatBytes /= 1024.0;
            return [NSString stringWithFormat: @"%.1f KB", floatBytes];
            break;
            
        case ByteSizeMegabytes:
            floatBytes /= 1024.0*1024.0;
            return [NSString stringWithFormat: @"%.1f MB", floatBytes];
            break;
            
        case ByteSizeGigabytes:
            floatBytes /= 1024.0*1024.0*1024.0;
            return [NSString stringWithFormat: @"%.1f GB", floatBytes];
            break;
            
        default:
            return [NSString stringWithFormat: @"%llu bytes", bytes];
    }
}

+ (NSString *) format: (unsigned long long) bytes;
{
    return [self format: bytes
              withUnits: [self unitsForSize: bytes]];
}

- (NSString *) stringForObjectValue: (id) object
{
    return [ByteSizeFormatter format: [object unsignedLongLongValue]];
}

- (BOOL) getObjectValue: (id *) object forString: (NSString *)
       errorDescription: (NSString **) error
{
    return NO;
}

- (NSAttributedString *) attributedStringForObjectValue: (id) object
                                  withDefaultAttributes: (NSDictionary *) attributes;
{
    return [[[NSAttributedString alloc] initWithString: [self stringForObjectValue: object]
                                            attributes: attributes] autorelease];
}

@end
