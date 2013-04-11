#import <Foundation/Foundation.h>


int stop_agent(void)
{
    NSArray * arguments = [NSArray arrayWithObjects: @"stop",
                           @"org.openbsd.ssh-agent", nil];
    
    NSTask * stopAgent = [NSTask launchedTaskWithLaunchPath: @"/bin/launchctl"
                                                  arguments: arguments];
    [stopAgent waitUntilExit];
    return [stopAgent terminationStatus];
}

OSStatus keychain_locked(SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context)
{
#if 1
    stop_agent();
#else
    NSLog(@"Exit: %d", stop_agent());
#endif
    
	return 0;
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	SecKeychainAddCallback(&keychain_locked, kSecLockEventMask, nil);

    [[NSRunLoop currentRunLoop] run];

    [pool drain];
    return 0;
}
