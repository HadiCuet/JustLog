//  LogstashDestination.swift

import Foundation
import SwiftyBeaver

typealias LogContent = [String: Any]
typealias LogTag = Int

/// This entire class relies on `operationQueue` to synchronise access to the `logsToShip` dictionary
/// Every action is put in the `operationQueue` which is synchronous, even though the actual sending
/// via `URLSession` is not. The writers' completion handler are executed on the underlying queue of the `OperationQueue`
/// Here's a brief summary of what operations are added to the queue and when:
/// A log is generated via `send` and added to the `logsToShip` dictionary (along with a `tag` identifier).
/// At some point `writeLogs` is called that creates an `NSURLSessionStreamTask` to send the log to the server.
/// Once the writer has completed all operations, it calls the completion handler passing the logs that failed to push.
/// Those logs are added back to `logsToShip`
/// An optional `completionHandler` is called when all logs existing before the `forceSend` call have been tried to send once.
public class LogstashDestination: BaseDestination {

    /// Settings
    var shouldLogActivity: Bool = false
    public var logzioToken: String?

    private let operationQueue: OperationQueue
    private let dispatchQueue = DispatchQueue(label: "com.justlog.LogstashDestination.dispatchQueue", qos: .utility)
    /// Private
    private let logzioTokenKey = "token"

    /// Socket
    private let sender: LogstashDestinationSending
    private let logstashFileDestination: LogstashFileDestination

    @available(*, unavailable)
    override init() {
        fatalError()
    }

    required init(sender: LogstashDestinationSending, logActivity: Bool) {
        self.operationQueue = OperationQueue()
        self.operationQueue.underlyingQueue = dispatchQueue
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.name = "com.justlog.LogstashDestination.operationQueue"
        self.sender = sender
        self.logstashFileDestination = LogstashFileDestination()
        super.init()
        self.shouldLogActivity = logActivity
    }

    deinit {
        cancelSending()
    }

    public func cancelSending() {
        self.operationQueue.cancelAllOperations()
        self.logstashFileDestination.clearLogs()
        self.sender.cancel()
    }

    // MARK: - Log dispatching

    override public func send(_ level: SwiftyBeaver.Level,
                              msg: String,
                              thread: String,
                              file: String,
                              function: String,
                              line: Int,
                              context: Any? = nil) -> String? {

        if let dict = msg.toDictionary() {
            var flattened = dict.flattened()
            if let logzioToken = logzioToken {
                flattened = flattened.merged(with: [logzioTokenKey: logzioToken])
            }
            addLog(flattened)
        }
        return nil
    }

    private func addLog(_ dict: LogContent) {
        operationQueue.addOperation { [weak self] in
            guard let self else { return }

            let time = mach_absolute_time()
            let logTag = Int(truncatingIfNeeded: time)
            printActivity("🔌 <LogstashDestination>, \(logTag) append")
            logstashFileDestination.appendLog(tag: logTag, content: dict)
        }
    }

    public func forceSend(_ completionHandler: @escaping (_ error: Error?) -> Void = {_ in }) {
        operationQueue.addOperation { [weak self] in
            guard let self else { return }
            let writer = LogstashDestinationWriter(sender: self.sender, shouldLogActivity: self.shouldLogActivity)
            let logsBatch = self.logstashFileDestination.readAndClearLogs()
            printActivity("🔌 <LogstashDestination>,, \(logsBatch.count) logs to send")
            writer.write(logs: logsBatch, queue: self.dispatchQueue) { [weak self] missing, error in
                guard let self else {
                    completionHandler(error)
                    return
                }

                if let unsent = missing {
                    //                    self.logsToShip.merge(unsent) { lhs, _ in lhs }
                    self.logstashFileDestination.appendLogsFromDictionary(unsent)
                    self.printActivity("🔌 <LogstashDestination>, \(unsent.count) failed tasks")
                }
                completionHandler(error)
            }
        }
    }
}

extension LogstashDestination {

    private func printActivity(_ string: String) {
        guard shouldLogActivity else { return }
        print(string)
    }
}
