#import "ViewController.h"
#import <FancyLib/UnifiedSDK.h>
@interface ViewController ()
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [UnifiedSDK setup];
}
- (IBAction)helloWorld:(id)sender {
    [UnifiedSDK helloWorld];
}
@end
