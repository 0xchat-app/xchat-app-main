//
//  BackgroundActivityManager.swift
//  Runner
//
//  Created by w on 2025/8/13.
//

import UIKit

final class BackgroundActivityManager {
    static let shared = BackgroundActivityManager()
    private init() {}

    enum EndReason { case normal, expired }

    private struct EndCallback {
        let queue: DispatchQueue
        let handler: (EndReason) -> Void
    }

    private struct TaskEntry {
        var taskIdentifier: UIBackgroundTaskIdentifier
        var referenceCount: Int
        var didExpire: Bool
        var didEnd: Bool
        var timeoutWorkItem: DispatchWorkItem?
        var callbacks: [EndCallback]
    }

    private typealias EndInfo = (
        taskId: UIBackgroundTaskIdentifier,
        timeoutItem: DispatchWorkItem?,
        callbacks: [EndCallback],
        reason: EndReason
    )

    private let stateQueue = DispatchQueue(label: "xchat.bg.manager.sync")
    private var entries: [String: TaskEntry] = [:]

    func start(
        key: String,
        requireBackgroundTask: Bool,
        maxDuration: TimeInterval,
        onEnd: ((EndReason) -> Void)? = nil,
        callbackQueue: DispatchQueue = .main
    ) {
        _ = stateQueue.sync { () -> UIBackgroundTaskIdentifier in
            if var entry = entries[key], !entry.didEnd, !entry.didExpire {
                entry.referenceCount += 1
                if let onEnd = onEnd {
                    entry.callbacks.append(.init(queue: callbackQueue, handler: onEnd))
                }
                entries[key] = entry
                return entry.taskIdentifier
            }

            if !requireBackgroundTask {
                var entry = TaskEntry(
                    taskIdentifier: .invalid,
                    referenceCount: 1,
                    didExpire: false,
                    didEnd: false,
                    timeoutWorkItem: nil,
                    callbacks: []
                )
                if let onEnd = onEnd {
                    entry.callbacks.append(.init(queue: callbackQueue, handler: onEnd))
                }
                entries[key] = entry
                return .invalid
            }

            var bgTaskId = UIBackgroundTaskIdentifier.invalid
            bgTaskId = UIApplication.shared.beginBackgroundTask(withName: key) { [weak self] in
                self?.expire(key: key)
            }

            var timeoutItem: DispatchWorkItem?
            if maxDuration > 0 {
                let item = DispatchWorkItem { [weak self] in self?.expire(key: key) }
                timeoutItem = item
                DispatchQueue.global().asyncAfter(deadline: .now() + maxDuration, execute: item)
            }

            var entry = TaskEntry(
                taskIdentifier: bgTaskId,
                referenceCount: 1,
                didExpire: false,
                didEnd: false,
                timeoutWorkItem: timeoutItem,
                callbacks: []
            )
            if let onEnd = onEnd {
                entry.callbacks.append(.init(queue: callbackQueue, handler: onEnd))
            }
            entries[key] = entry
            return bgTaskId
        }
    }

    func stop(key: String) {
        var endInfo: EndInfo?
        stateQueue.sync {
            guard var entry = entries[key] else { return }
            entry.referenceCount = max(0, entry.referenceCount - 1)
            entries[key] = entry
            if entry.referenceCount == 0 {
                endInfo = tryEndLocked(key: key, reason: entry.didExpire ? .expired : .normal)
            }
        }
        if let (taskId, timeoutItem, callbacks, reason) = endInfo {
            timeoutItem?.cancel()
            if taskId != .invalid { UIApplication.shared.endBackgroundTask(taskId) }
            stateQueue.sync { entries.removeValue(forKey: key) }
            for cb in callbacks { cb.queue.async { cb.handler(reason) } }
        }
    }

    private func expire(key: String) {
        var endInfo: EndInfo?
        stateQueue.sync {
            guard var entry = entries[key] else { return }
            entry.didExpire = true
            entries[key] = entry
            endInfo = tryEndLocked(key: key, force: true, reason: .expired)
        }
        if let (taskId, timeoutItem, callbacks, reason) = endInfo {
            timeoutItem?.cancel()
            if taskId != .invalid { UIApplication.shared.endBackgroundTask(taskId) }
            stateQueue.sync { entries.removeValue(forKey: key) }
            for cb in callbacks { cb.queue.async { cb.handler(reason) } }
        }
    }

    private func tryEndLocked(
        key: String,
        force: Bool = false,
        reason: EndReason = .normal
    ) -> EndInfo? {
        guard var entry = entries[key], !entry.didEnd else { return nil }
        guard force || entry.referenceCount == 0 else { return nil }
        entry.didEnd = true
        entries[key] = entry
        let finalReason: EndReason = entry.didExpire ? .expired : reason
        return (entry.taskIdentifier, entry.timeoutWorkItem, entry.callbacks, finalReason)
    }

    func run(
        key: String,
        requireBackgroundTask: Bool,
        maxDuration: TimeInterval,
        onEnd: ((EndReason) -> Void)? = nil,
        callbackQueue: DispatchQueue = .main,
        work: (_ done: @escaping () -> Void) -> Void
    ) {
        start(
            key: key,
            requireBackgroundTask: requireBackgroundTask,
            maxDuration: maxDuration,
            onEnd: onEnd,
            callbackQueue: callbackQueue
        )
        let once = Once()
        let done = { [weak self] in
            once.run { self?.stop(key: key) }
        }
        work(done)
    }
}

private final class Once {
    private var hasRun = false
    private let stateQueue = DispatchQueue(label: "xchat.bg.once")
    func run(_ block: () -> Void) {
        var shouldRun = false
        stateQueue.sync {
            if !hasRun { hasRun = true; shouldRun = true }
        }
        if shouldRun { block() }
    }
}
