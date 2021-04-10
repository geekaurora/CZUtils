import Foundation

public extension DispatchQueue {
  /**
   Executes `execute` asynchronously on background DispatchQueue after `seconds`.
   */
  static func asyncOnBackgroundAfter(seconds: TimeInterval,
                                     qos: DispatchQoS.QoSClass = .default,
                                     execute: @escaping () -> Void) {
    DispatchQueue.global(qos: qos).asyncAfter(
      deadline: .now() + seconds,
      execute: execute)
  }
}
