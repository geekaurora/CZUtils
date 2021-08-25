import Foundation

public class CZTestHelper {
  /**
   Returns whether is currently under unit tests or UI tests.
   */
  public static var isInUnitTest = (NSClassFromString("XCTest") != nil)  
}
