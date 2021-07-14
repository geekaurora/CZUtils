import UIKit

/**
 Helper that compares two images with `tolerance`.
 
 TODO: Comparison doesn't work - memory compare. (Objc version works)
 
 https://stackoverflow.com/questions/11342897/how-to-compare-two-uiimage-objects
 https://github.com/facebookarchive/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage%2BCompare.m
 */
class CZImageDiffHelper {
  
  static func compare(expected: Data,
                      actual: Data,
                      tolerance: Float = 0) throws -> Bool {
    guard let expectedUIImage = UIImage(data: expected), let actualUIImage = UIImage(data: actual) else {
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    guard let expectedCGImage = expectedUIImage.cgImage, let actualCGImage = actualUIImage.cgImage else {
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    guard let expectedColorSpace = expectedCGImage.colorSpace, let actualColorSpace = actualCGImage.colorSpace else {
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    
    // 1. Compare width / height.
    if expectedCGImage.width != actualCGImage.width || expectedCGImage.height != actualCGImage.height {
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    let imageSize = CGSize(width: expectedCGImage.width, height: expectedCGImage.height)
    let numberOfPixels = Int(imageSize.width * imageSize.height)
    
    // Checking that our `UInt32` buffer has same number of bytes as image has.
    let bytesPerRow = min(expectedCGImage.bytesPerRow, actualCGImage.bytesPerRow)
        
    // let val1 = MemoryLayout<UInt32>.stride              // Element size: 4
    // let val2 = bytesPerRow / Int(imageSize.width)       // bytesPerPixel: 2
    // assert(val1 == val2)
    
    let expectedPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
    let actualPixels = UnsafeMutablePointer<UInt32>.allocate(capacity: numberOfPixels)
    
    let expectedPixelsRaw = UnsafeMutableRawPointer(expectedPixels)
    let actualPixelsRaw = UnsafeMutableRawPointer(actualPixels)
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    // 2-0. Create CGContext for rendering.
    guard let expectedContext = CGContext(
            data: expectedPixelsRaw,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: expectedCGImage.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: expectedColorSpace,
            bitmapInfo: bitmapInfo.rawValue) else {
      expectedPixels.deallocate()
      actualPixels.deallocate()
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    guard let actualContext = CGContext(
            data: actualPixelsRaw,
            width: Int(imageSize.width),
            height: Int(imageSize.height),
            bitsPerComponent: actualCGImage.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: actualColorSpace,
            bitmapInfo: bitmapInfo.rawValue) else {
      expectedPixels.deallocate()
      actualPixels.deallocate()
      throw CZError(domain: "unableToGetUIImageFromData")
    }
    
    // 2-1. Draw cgImage to CGContext.
    expectedContext.draw(expectedCGImage, in: CGRect(origin: .zero, size: imageSize))
    actualContext.draw(actualCGImage, in: CGRect(origin: .zero, size: imageSize))
    
    // 2-2. Convert pixels to buffer. expectedPixels..<expectedPixels + numberOfPixels
    let expectedBuffer = UnsafeBufferPointer(start: expectedPixels, count: numberOfPixels)
    let actualBuffer = UnsafeBufferPointer(start: actualPixels, count: numberOfPixels)
    
    // 2-3. Compare pixels of two images with `tolerance`.
    var isEqual = true
    if tolerance == 0 {
      isEqual = expectedBuffer.elementsEqual(actualBuffer)
    } else {
      // Go through each pixel in turn and see if it is different
      var numDiffPixels = 0

      // for pixel in 0 ..< numberOfPixels where expectedBuffer[pixel] != actualBuffer[pixel] {
      for pixel in 0 ..< numberOfPixels {
       let expectedBufferByte = expectedBuffer[pixel]
        let actualBufferByte = actualBuffer[pixel]
        if expectedBufferByte == actualBufferByte {
          continue
        }
        
        // If this pixel is different, increment the pixel diff count and see if we have hit our limit.
        numDiffPixels += 1
        let percentage = Float(numDiffPixels) / Float(numberOfPixels)
        if percentage > tolerance {
          isEqual = false
          break
        }
      }
    }
    
    expectedPixels.deallocate()
    actualPixels.deallocate()
    
    return isEqual
  }
}
