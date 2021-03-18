import Foundation

/**
 Type safe pointer array that maintains weak reference of underlying elements.
 
 ### Usage
 
 ```
 let pointerArray = CZPointerArray<NSString>()
 
 let testObject = "testObject" as NSString
 pointerArray.addObject(testObject)
 pointerArray.removeObject(testObject)
 ``` 
 */
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
    guard let object = object,
          let index = self.index(of: object) else {
      return
    }
    pointerArray.removePointer(at: index)
  }
  
  public override var description: String {
    var description = "Count = \(pointerArray.count), allObjects.count = \(pointerArray.allObjects.count)\n"
    for pointer in pointerArray.allObjects {
      description += "\(pointer)\n"
    }
    return description
  }
}

// MARK: - Private methods

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
  
  // MARK: - Helper methods
  
  func pointer(for object: Element) -> UnsafeMutableRawPointer {
    let pointer = Unmanaged.passUnretained(object).toOpaque()
    return pointer
  }
  
  func index(of object: Element?) -> Int? {
    guard let object = object else {
      return nil
    }
    // Should check `pointerArray.count` here, as pointerArray may contain nil.
    // If check pointerArray.allObjects.count, it possibly makes index incorrect, because nil
    // index is also counted in `pointerArray.allObjects`.
    let objectPointer = self.pointer(for: object)
    for i in 0..<self.pointerArray.count {
      let currObject = pointerArray.pointer(at: i)
      if currObject == objectPointer {
        return i
      }
    }
    return nil
  }
  
  func contains(_ object: Element?) -> Bool {
    return index(of: object) != nil
  }
}

