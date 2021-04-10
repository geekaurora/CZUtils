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
  public var props = [String: Any]()

  private typealias ExecutionBlock = () -> Void
  private var executionBlock: ExecutionBlock!
  private var _isBlockFinished = false

  public init(block: @escaping () -> Void) {
    fatalError("Must call designated intialize init().")
  }
  
  public override init() {
    super.init()
    
    executionBlock = { [weak self] in
      guard let `self` = self else { return }
      self.execute()
      
      // Wait for `semaphore` to finish the block execution - operation will be `isFinished`.
      if !self._isBlockFinished {
        self.semaphore.wait()
      }
    }
    addExecutionBlock(executionBlock)
  }
  
  // MARK: - Override methods
  
  public final override func start() {
    guard !_isBlockFinished else {
      return
    }
    // Invoke super.start() to execute `self.executionBlock`.
    super.start()
  }
  
  private func execute() {
    guard !isCancelled else {
      dbgPrintWithFunc(self, "Skip execute() because the operation has been cancelled!")
      return
    }
    _execute()
  }
  
  open func _execute() {
    fatalError("\(#function) must be overriden in subclass.")
  }
  
  open func finish() {
    guard !_isBlockFinished else {
      assertionFailure("Shouldn't call finish() twice.")
      return
    }
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
