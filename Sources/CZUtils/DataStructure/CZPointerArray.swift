import Foundation

public class CZPointerArray<Element: NSObjectProtocol>: NSObject {
  private lazy var pointerArray = NSPointerArray.weakObjects()
  
  public var count: Int {
    return pointerArray.count
  }
  
  public func addObject(_ object: Element?) {
    guard let object = object else { return }
    let pointer = self.pointer(for: object)
    pointerArray.addPointer(pointer)
  }
  
  public func removeObject(_ object: Element?) {
    guard let object = object else { return }
    
    // Should check `pointerArray.count` here, as pointerArray may contain nil.
    // If check pointerArray.allObjects.count, it possibly makes index incorrect, because nil
    // index is also counted in `pointerArray.allObjects`.
    let objectPointer = self.pointer(for: object)
    for i in 0..<self.pointerArray.count {
      let currObject = pointerArray.pointer(at: i)
      if currObject == objectPointer {
        pointerArray.removePointer(at: i)
        break;
      }
    }
  }
}

// MARK: - Private method

extension CZPointerArray {
  func insertObject(_ object: Element?, at index: Int) {
    guard index < count, let strongObject = object else { return }
    
    let pointer = self.pointer(for: strongObject)
    pointerArray.insertPointer(pointer, at: index)
  }
  
  func replaceObject(at index: Int, withObject object: Element?) {
    guard index < count, let strongObject = object else { return }
    
    let pointer = self.pointer(for: strongObject)
    pointerArray.replacePointer(at: index, withPointer: pointer)
  }
  
  func object(at index: Int) -> Element? {
    guard index < count, let pointer = pointerArray.pointer(at: index) else { return nil }
    return Unmanaged<Element>.fromOpaque(pointer).takeUnretainedValue()
  }
  
  func removeObject(at index: Int) {
    guard index < count else { return }
    pointerArray.removePointer(at: index)
  }
  
  func pointer(for object: Element) -> UnsafeMutableRawPointer {
    let pointer = Unmanaged.passUnretained(object).toOpaque()
    return pointer
  }
}

