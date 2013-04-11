#include <stdio.h>
#import <Foundation/Foundation.h>
#import "RagelStateMachine.h"
 
@interface MTExport : RagelStateMachine
{
    int curline;
    NSMutableString * key;
    NSMutableString * value;
    int charsToDelete;
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
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

    action key { [key appendFormat: @"%c", fc]; }
    action value {
        // printf("ch: %c (0x%02X)\n", isprint(fc) ? fc : '.' , fc);
        [value appendFormat: @"%c", fc];
    }
    action onMetadata {
        ddprintf(@"<%@> = <%@>\n", key, value);
        [key deleteCharactersInRange: NSMakeRange(0, [key length])];
        [value deleteCharactersInRange: NSMakeRange(0, [value length])];
    }
    
    action onBody {
        // ddprintf(@"Chars to delete: %d\n", charsToDelete);
        [value deleteCharactersInRange: NSMakeRange([value length] - charsToDelete, charsToDelete)];
        charsToDelete = 0;
        ddprintf(@"<%@> = <%@>\n\n", key, value);
        [key deleteCharactersInRange: NSMakeRange(0, [key length])];
        [value deleteCharactersInRange: NSMakeRange(0, [value length])];
    }
    
    action ch {
        // printf("ch: %c (0x%02X)\n", isprint(fc) ? fc : '.' , fc);
        charsToDelete++;
    }
    action reset {
        // printf("reset\n");
        charsToDelete = 0;
    }
   
    newline = '\r'? '\n' @{ curline += 1; };
    EOF = 0;
    default = ^0;
    
    key = ([a-zA-Z] | ' ')+;
    value = [^\n\r]*;
    
    metadata = (key $key ':' ' '+ value $value newline) @onMetadata
        | newline;
    
    end_metadata = "-"{5} newline;
    
    end_entry = "-"{8} newline;
    
    end_multiline = "-"{5} newline;
   
# multiline_start = [^'-'\n\r];

# multiline_line = (multiline_start multiline_ch*)? newline;
# multiline_line = ((!multiline_start+ $ch) (multiline_ch* $ch))? newline;

    multiline_ch = [^\n\r];
    content_line = multiline_ch* newline >reset $ch;
    multiline_line = (content_line - end_multiline $ch);
    multiline_value = (multiline_line* $value end_multiline);
#    multiline_value = (any* :>> (newline end_multiline) >reset $ch) $value;
    
    body = "BODY" $key ":" newline multiline_value @onBody;
    
    extended_body = "EXTENDED BODY" $key ":" newline multiline_value @onBody;
    
    excerpt = "EXCERPT" $key ":" newline multiline_value @onBody;

    keywords = "KEYWORDS" $key ":" newline multiline_value @onBody;

    multiline_field = body | extended_body | excerpt | keywords ;
    
    entry = metadata* end_metadata multiline_field* newline* end_entry;
    
    main := entry* EOF;
}%%

%% write data noprefix;

@implementation MTExport

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    key = [[NSMutableString alloc] init];
    value = [[NSMutableString alloc] init];
    charsToDelete = 0;
    
    return self;
}

- (void) ragelInit;
{
    %% write init;
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
{
    const unsigned char * p = bytes;
    const unsigned char * pe = p + length;
    
    %% write exec;
	if ( cs == error )
		return -1;
	if ( cs >= first_final )
		return 1;
	return 0;
}

- (int) finish;
{
	%% write eof;
	if ( cs == error )
		return -1;
	if ( cs >= first_final )
		return 1;
	return 0;
}

@end


int main(int argc, char **argv) 
{ 
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int result = 0;
    
    MTExport * scanner = [[MTExport alloc] init];
    
    NSFileHandle * handle = [NSFileHandle fileHandleWithStandardInput];
    int rc = [scanner parseWithFileHandle: handle];
    ddprintf(@"Scanner result: %d\n", rc);
    
    [pool release];
    return result;
}
