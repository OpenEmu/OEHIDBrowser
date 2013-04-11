#include <stdio.h>
#import <Foundation/Foundation.h>

@interface NSFileHandle (ReadInto)

- (int) readIntoBuffer: (void *) buffer
                length: (unsigned) length;
- (int) readIntoData: (NSMutableData *) data;

@end

@implementation NSFileHandle (ReadInto)

- (int) readIntoBuffer: (void *) buffer
                length: (unsigned) length;
{
    int fd = [self fileDescriptor];
    int result = read(fd, buffer, length);
    return result;
}


- (int) readIntoData: (NSMutableData *) data;
{
    return [self readIntoBuffer: [data mutableBytes]
                         length: [data length]];
}

@end
 
@interface MTExport : NSObject
{
    int cs, top, stack[100], act;
    int curline;
    const char * start;
    NSMutableString * key;
    NSMutableString * value;
    const char *tokstart, *tokend;
    int marker;
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
- (int) execute: (NSData *) data;
- (int) finish;

@end

void ddprintf(NSString * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString * string = [[NSString alloc] initWithFormat: format
                                               arguments: arguments];
    va_end(arguments);
    
    printf("%s", [string UTF8String]);
    [string release];
}

%%{
    machine MTExportScanner;
    alphtype unsigned char;
    
    action onNewline { curline += 1; }
    action onChar { ddprintf(@"%c", isprint(fc)? fc : '.'); }
    action countMarker { marker += 1; }
    action onSection { ddprintf(@": <%d>\n", marker); marker = 0;}
    
# newline = '\r'? '\n' @onNewline;
#newline = '\n' @ onNewline;
#    any_count_line = any | newline;
    
#    line = ^[\r\n]* newline;
    
#    section_end = "--\n";
#    content_line = [^\n]* '\n';
    
#    section_line = (content_line - section_end);
#section = section_line* $onChar section_end @onSection;
    
    newline = '\r'? '\n' @onNewline;
    any_line = [^\r\n]* newline; 
    marker_line = '--' newline;
    section_line = any_line - marker_line;
    section_body = section_line*;
    
    section = (section_body marker_line $countMarker) $onChar @onSection; 
    
#ch = any - 0;
#section = (any* $onChar '\n')? :>> "--\n" @onSection;
    main := section*;
#    main := |*
#        marker_line => { printf("\n"); };
#        any => {
#            printf("%c", isprint(*tokstart)? *tokstart : '.');
#        };
#        *|;
    
#main := line*;
#main := any_count_line*;
#main := '0x' xdigit+ | digit+ | alpha alnum*;
    hex = '0x' xdigit+;
    decimal = digit+;
    identifier = alpha alnum*;
#main := hex $onHex | decimal | identifier;
#main := |*
#    hex {
#        ddprintf(@"onHex\n");
#        // fwrite( tokstart, 1, tokend-tokstart, stdout );
#        ddprintf(@"\n");
#    };
#    decimal;
#    (space | newline);
#    0;
#        *|;
}%%

%% write data;

@implementation MTExport

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    key = [[NSMutableString alloc] init];
    value = [[NSMutableString alloc] init];
    tokstart = tokend = 0;    
    marker = 0;
    %% write init;
    
    return self;
}

- (int) execute: (NSData *) data;
{
    return [self executeWithBytes: [data bytes]
                           length: [data length]];
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
{
    const char * p = bytes;
    const char *pe = p + length;
    
    %% write exec;
    
    ddprintf(@"tokstart: %p, %d\n", tokstart, pe - tokstart);
    
	if ( cs == MTExportScanner_error )
		return -1;
	if ( cs >= MTExportScanner_first_final )
		return 1;
	return 0;
}

- (int) finish;
{
	%% write eof;
	if ( cs == MTExportScanner_error )
		return -1;
	if ( cs >= MTExportScanner_first_final )
		return 1;
	return 0;
}

- (void) printSummary;
{
    ddprintf(@"Lines: %d\n", curline);
}

@end


int main(int argc, char **argv) 
{ 
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int result = 0;
    
    MTExport * scanner = [[MTExport alloc] init];
    
    NSFileHandle * handle = [NSFileHandle fileHandleWithStandardInput];

    unsigned length = 500;
    NSMutableData * buffer = [NSMutableData dataWithLength: length];
    
    bool done = NO;
    while (!done)
    {
#if 0
        NSData * data = [handle readDataOfLength: length];
        if ([data length] != 0)
        {
            int rc = [scanner execute: data];
            if (rc < 0)
            {
                ddprintf(@"Scanner result: %d\n", rc);
                break;
            }
        }
        if ([data length] != length)
            break;
#else
        int result = [handle readIntoData: buffer];
        if (result >= 0)
        {
            const void * p = [buffer bytes];
            unsigned l = result;
            char null = '\0';
            if (result == 0)
            {
#if 0
                p = &null;
                l = 1;
#endif
                done = YES;
            }
            
            int rc = [scanner executeWithBytes: p
                                        length: l];
            if (rc < 0)
            {
                ddprintf(@"Scanner result: %d\n", rc);
                break;
            }
        }
        else
            done = YES;
#endif
    }
    
    int rc = [scanner finish];
    ddprintf(@"Scanner result: %d\n", rc);
    [scanner printSummary];
    
    [pool release];
    return result;
}
