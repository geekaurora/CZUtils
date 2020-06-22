import Foundation

/**
 An abstract class that makes subclassing ConcurrentOperation easier. Updates KVO props `isReady`/`isExecuting`/`isFinished` automatically.
 
 ### Usage
 1. Subclass `ConcurrentBlockOperation`.
 2. Override `execute()` with custom execution.
 3. Invoke `finish()` when concurrent execution completes.
 
 - Note: If customize `cancel()` in subclass, should call `super.cancel()` instead of `super.finish()`.
 */
@objc
open class ConcurrentBlockOperation: BlockOperation {
  private let semaphore = DispatchSemaphore(value: 0)
  private var _isBlockFinished = false
  public var props = [String: Any]()
  
  public init(block: @escaping () -> Void) {
    fatalError("Must call designated intialize init().")
  }
  
  public override init() {
    super.init()
    
    let awaitBlock = {
      self.execute()
      
      if (!self._isBlockFinished) {
        self.semaphore.wait()
      }
      dbgPrint("executeBlock finished. Class = \(type(of: self)); props = \(self.props)")
    }
    addExecutionBlock(awaitBlock)
  }
  
  open func execute() {
    fatalError("\(#function) must be overriden in subclass.")
  }
  
  open func finish() {
    _isBlockFinished = true
    signalFinished()
  }
  
  open override func cancel() {
    super.cancel()
    signalFinished()
    dbgPrint("executeBlock cancelled. Class = \(type(of: self)); props = \(props)")
  }
  
  private func signalFinished() {
    semaphore.signal()
  }
}
