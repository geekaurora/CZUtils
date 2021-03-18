import Foundation

class GMOPointerArray: NSObject {
  private lazy var pointerArray = NSPointerArray.weakObjects()
  
  var count: Int {
    return pointerArray.count
  }
  
  func addObject(_ object: AnyObject?) {
    guard let strongObject = object else { return }
    
    let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
    pointerArray.addPointer(pointer)
  }
  
  func insertObject(_ object: AnyObject?, at index: Int) {
    guard index < count, let strongObject = object else { return }
    
    let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
    pointerArray.insertPointer(pointer, at: index)
  }
  
  func replaceObject(at index: Int, withObject object: AnyObject?) {
    guard index < count, let strongObject = object else { return }
    
    let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
    pointerArray.replacePointer(at: index, withPointer: pointer)
  }
  
  func object(at index: Int) -> AnyObject? {
    guard index < count, let pointer = pointerArray.pointer(at: index) else { return nil }
    return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
  }
  
  func removeObject(at index: Int) {
    guard index < count else { return }
    
    pointerArray.removePointer(at: index)
  }
}
