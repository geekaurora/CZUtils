import Foundation

/// Helper class to make async stream for concurrent tasks.
public class TaskGroupAsyncStreamHelper {
  /// Makes an async stream for concurrent tasks.
  ///
  /// - Parameters:
  ///   - taskModels: The models for tasks group.
  ///   - asyncTaskBlock: Asynchronous task block to execute with each `taskModel`.
  /// - Returns: The async stream for concurrent tasks.
  public static func makeAsyncStream<TaskModel, Result>(
    taskModels: [TaskModel],
    asyncTaskBlock: @escaping (TaskModel) async -> Result
  ) -> AsyncStream<Result> {
    // Make an async stream.
    let (stream, continuation) = AsyncStream.makeStream(of: Result.self)

    let task = Task {
      // Make a task group to execute `asyncTaskBlock` with `taskModels`.
      await withTaskGroup(of: Result.self) { group in
        for taskModel in taskModels {
          group.addTask {
            await asyncTaskBlock(taskModel)
          }
        }

        // Append the execution results of the task group to the async stream.
        for await result in group {
          continuation.yield(result)
        }

        // End the stream after all tasks complete.
        continuation.finish()
      }
    }

    continuation.onTermination = { _ in
      task.cancel()
    }

    return stream
  }
}
