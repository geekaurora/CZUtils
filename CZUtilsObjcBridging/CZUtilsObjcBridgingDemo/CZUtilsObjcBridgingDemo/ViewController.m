#import <CZUtilsObjcBridging/CZUtilsObjcBridging.h>

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self test];
}

- (void)test {
  [self.view overlayOnSuperview:self.view];
  [self.view overlayOnSuperview:self.view insets:UIEdgeInsetsZero];
}


@end
