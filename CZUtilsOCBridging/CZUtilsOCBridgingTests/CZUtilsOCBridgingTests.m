#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CZUtilsOCBridging/CZUtilsOCBridging.h>

@interface CZUtilsOCBridgingTests : XCTestCase

@end

@implementation CZUtilsOCBridgingTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testOverlayOnSuperview {
  UIView *testView = [[UIView alloc] init];
  UIView *parentView = [[UIView alloc] init];
  [testView overlayOnSuperview:parentView];
  [testView overlayOnSuperview:parentView insets:NSDirectionalEdgeInsetsZero];

}


@end
