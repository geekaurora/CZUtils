import Foundation

/**
 Automatically bind value change of model  to View with KVO keyPath.
 
 ### Usage
 ```
 class TestViewModel: NSObject {
   @objc dynamic var count = 0
 }
  
 class ViewController: UIViewController {
   var observations: [NSKeyValueObservation] = []
 
   var viewModel = TestViewModel()
   var button: UIButton
   
   func initKeyPathBindings() {
     observations = [
       viewModel.bind(\.count, to: titleLabel, at: \.text),
       viewModel.bind(\.count, to: titleLabel, at: \.text) { String($0) },
       viewModel.observe(\.count) { self.button.setTitle(String($0), for: .normal) },
     ]
   }
 }
 ```
 */
public extension NSObjectProtocol where Self: NSObject {
  /**
   Data binding - sets target's value for its `keyPath` when value changes.
   
   - Parameters:
     - sourceKeyPath  : the source KeyPath of model.
     - target                  : the target object - normally View.
     - targetKeyPath  : the KeyPath of View to be mutated.
     - tranform             : the closure that transforms sourceValue to targetValue. Defaults to nil.
   - Returns                    : the generated `NSKeyValueObservation`.
   */
  func bind<SourceValue, Target, TargetValue>(_ sourceKeyPath: KeyPath<Self, SourceValue>,
                                              to target: Target,
                                              at targetKeyPath: ReferenceWritableKeyPath<Target, TargetValue>,
                                              tranform: ((SourceValue) -> TargetValue)? = nil) -> NSKeyValueObservation {
    return observe(sourceKeyPath) { sourceValue in
      // Set target's value for the corrsponding `keyPath`.
      let targetValue: TargetValue = {
        if tranform != nil {
          return tranform!(sourceValue)
        } else {
          return sourceValue as! TargetValue
        }
      }()
      target[keyPath: targetKeyPath] = targetValue
    }
  }
  
  /**
   KVO - observes value change with model's keyPath.
   */
  func observe<Value>(_ keyPath: KeyPath<Self, Value>,
                      onChange: @escaping (Value) -> ()) -> NSKeyValueObservation {
    return observe(keyPath, options: [.initial, .new]) { _, change in
      guard let newValue = change.newValue else { return }
      onChange(newValue)
    }
  }
}
