#import "UnifiedSDK.h"
#import <React/RCTBridge.h>

static RCTBridge * bridge;

@implementation UnifiedSDK
+ (void)setup
{
    NSBundle *bundle = [NSBundle bundleForClass: [UnifiedSDK class]];
    NSURL *jsCodeLocation = [bundle URLForResource:@"unifiedsdk" withExtension:@"bundle"];
    bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                   moduleProvider:nil
                                    launchOptions:nil];
}

+ (void)helloWorld
{
    [bridge enqueueJSCall:@"CommonInterface" method:@"helloworld" args:@[@"From UnifiedSDK js"] completion:nil];
}

@end
