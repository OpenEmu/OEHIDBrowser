#import <Foundation/Foundation.h>
#import "DDCurlCliApp.h"
#import "DDCommandLineInterface.h"

int main (int argc, char * const * argv)
{
    return DDCliAppRunWithClass([DDCurlCliApp class]);
}
