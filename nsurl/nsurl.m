#import <Foundation/Foundation.h>
#import "NSUrlCliApp.h"
#import "JRLog.h"
#include <getopt.h>
#include <libgen.h>

enum
{
    UsernameOption = 'u',
    PasswordOption = 'p',
    HeaderOption = 'H',
    AddHeaderOption = 'A',
    HelpOption = 'h',
    RedirectOption = 'r',
    FormOption = 'F',
    MethodOption = 'm',
   
    LastCharOption = 255,
    VersionOption,
    DebugOption,
};

static void usage(FILE * stream)
{
    fprintf(stream, "Usage: %s [OPTIONS] <url>\n", COMMAND);
}

static void print_help(void)
{
    usage(stdout);
    printf("\n");
    printf("  -u, --username USERNAME       Use USERNAME for authentication\n");
    printf("  -p, --password PASSWORD       Use PASSWORD for authentication\n");
    printf("  -H, --header HEADER           "
           "Set HTTP header, e.g. \"Accept: application/xml\"\n");
    printf("  -A, --add-header HEADER       "
           "Add HTTP header, e.g. \"Accept: application/xml\"\n");
    printf("  -r, --redirect                Follow redirects\n");
    printf("  -F, --form FIELD              Multipart form field\n");
    printf("  -m, --method METHOD           HTTP method to use\n");
    printf("  -h, --help                    Display this help and exit\n");
    printf("      --debug                   Dispaly debugging information\n");
    printf("      --version                 Display version and exit\n");
    printf("\n");
}

static void print_version(void)
{
    printf("%s version %s\n", COMMAND, CURRENT_MARKETING_VERSION);
}

static void set_debug_level(NSString * level)
{
    [NSObject setDefaultJRLogLevel: JRLogLevel_Debug];
}

static int run_app(int argc, char * const * argv)
{
    NSUrlCliApp * app = nil;
    int result = 0;
    
    @try
    {
        COMMAND = basename(argv[0]);
        app = [[NSUrlCliApp alloc] init];

        /* options descriptor */
        static struct option longopts[] = {
            { "username",   required_argument,      NULL,   UsernameOption },
            { "password",   required_argument,      NULL,   PasswordOption },
            { "header",     required_argument,      NULL,   HeaderOption },
            { "add-header", required_argument,      NULL,   AddHeaderOption },
            { "form",       required_argument,      NULL,   FormOption },
            { "method",     required_argument,      NULL,   MethodOption },
            { "redirect",   no_argument,            NULL,   RedirectOption },
            { "help",       no_argument,            NULL,   HelpOption },
            { "version",    no_argument,            NULL,   VersionOption },
            { "debug",      optional_argument,      NULL,   DebugOption },
            { NULL,         0,                      NULL,   0 }
        };
        
        int ch;
        while ((ch = getopt_long(argc, argv, "u:p:H:A:F:m:rh", longopts, NULL)) != -1)
        {
            NSString * nsoptarg = nil;
            if (optarg != NULL)
                nsoptarg = [NSString stringWithUTF8String: optarg];
            switch (ch) {
                case UsernameOption:
                    [app setUsername: nsoptarg];
                    break;
                    
                case PasswordOption:
                    [app setPassword: nsoptarg];
                    break;
                    
                case HeaderOption:
                    [app setHeaderValue: nsoptarg];
                    break;
                    
                case AddHeaderOption:
                    [app addHeaderValue: nsoptarg];
                    break;
                    
                case RedirectOption:
                    [app setAllowRedirects: YES];
                    break;
                    
                case FormOption:
                    [app addFormField: nsoptarg];
                    break;
                    
                case MethodOption:
                    [app setHttpMethod: nsoptarg];
                    break;
                    
                case HelpOption:
                    print_help();
                    return 0;
                    break;
                    
                case DebugOption:
                    set_debug_level(nsoptarg);
                    break;
                    
                case VersionOption:
                    print_version();
                    return 0;
                    break;
                    
                default:
                    fprintf(stderr, "Try `%s --help` for more information.\n", COMMAND);
                    return 1;
            }
        }
        argc -= optind;
        argv += optind;
        
        if (argc != 1)
        {
            fprintf(stderr, "%s: missing url argument\n", COMMAND);
            fprintf(stderr, "Try `%s --help` for more information.\n", COMMAND);
            return 1;
        }
        
        [app setUrl: [NSString stringWithCString: argv[0] encoding: NSUTF8StringEncoding]];
        result = [app run] ? 0 : 1;
    }
    @finally
    {
        if (app != nil)
        {
            [app release];
            app = nil;
        }
    }

    return result;
}

int main (int argc, char * const * argv)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    [NSObject setDefaultJRLogLevel: JRLogLevel_Error];
    int result = run_app(argc, argv);

    [pool release];
    return result;
}
