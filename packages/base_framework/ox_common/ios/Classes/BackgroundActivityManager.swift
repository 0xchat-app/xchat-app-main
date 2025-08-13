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

    private struct Callback {
        let queue: DispatchQueue
        let block: (EndReason) -> Void
    }

    private struct Entry {
        var id: UIBackgroundTaskIdentifier
        var ref: Int
        var expired: Bool
        var ended: Bool
        var timeout: DispatchWorkItem?
        var callbacks: [Callback]
    }

    private let q = DispatchQueue(label: "xchat.bg.manager.sync")
    private var map: [String: Entry] = [:]

    func start(
        key: String,
        requireBackgroundTask: Bool,
        maxDuration: TimeInterval,
        onEnd: ((EndReason) -> Void)? = nil,
        callbackQueue: DispatchQueue = .main
    ) {
        _ = q.sync { () -> UIBackgroundTaskIdentifier in
            if var e = map[key], e.id != .invalid, !e.expired {
                e.ref += 1
                if let onEnd = onEnd {
                    e.callbacks.append(.init(queue: callbackQueue, block: onEnd))
                }
                map[key] = e
                return e.id
            }

            if !requireBackgroundTask {
                var e = Entry(id: .invalid, ref: 1, expired: false, ended: false, timeout: nil, callbacks: [])
                if let onEnd = onEnd { e.callbacks.append(.init(queue: callbackQueue, block: onEnd)) }
                map[key] = e
                return .invalid
            }

            var id = UIBackgroundTaskIdentifier.invalid
            id = UIApplication.shared.beginBackgroundTask(withName: key) { [weak self] in
                self?.expire(key: key)
            }

            var to: DispatchWorkItem?
            if id != .invalid && maxDuration > 0 {
                let item = DispatchWorkItem { [weak self] in self?.expire(key: key) }
                to = item
                DispatchQueue.global().asyncAfter(deadline: .now() + maxDuration, execute: item)
            }

            var e = Entry(id: id, ref: 1, expired: false, ended: false, timeout: to, callbacks: [])
            if let onEnd = onEnd { e.callbacks.append(.init(queue: callbackQueue, block: onEnd)) }
            map[key] = e
            return id
        }
    }

    func stop(key: String) {
        var ending: (UIBackgroundTaskIdentifier, DispatchWorkItem?, [Callback], EndReason)?
        q.sync {
            guard var e = map[key] else { return }
            e.ref = max(0, e.ref - 1)
            map[key] = e
            if e.ref == 0 {
                ending = tryEndLocked(key: key, reason: e.expired ? .expired : .normal)
            }
        }
        if let (id, to, cbs, reason) = ending {
            to?.cancel()
            if id != .invalid { UIApplication.shared.endBackgroundTask(id) }
            q.sync { map.removeValue(forKey: key) }
            for cb in cbs { cb.queue.async { cb.block(reason) } }
        }
    }

    private func expire(key: String) {
        var ending: (UIBackgroundTaskIdentifier, DispatchWorkItem?, [Callback], EndReason)?
        q.sync {
            guard var e = map[key] else { return }
            e.expired = true
            map[key] = e
            ending = tryEndLocked(key: key, force: true, reason: .expired)
        }
        if let (id, to, cbs, reason) = ending {
            to?.cancel()
            if id != .invalid { UIApplication.shared.endBackgroundTask(id) }
            q.sync { map.removeValue(forKey: key) }
            for cb in cbs { cb.queue.async { cb.block(reason) } }
        }
    }

    private func tryEndLocked(
        key: String,
        force: Bool = false,
        reason: EndReason = .normal
    ) -> (UIBackgroundTaskIdentifier, DispatchWorkItem?, [Callback], EndReason)? {
        guard var e = map[key], !e.ended else { return nil }
        guard force || e.ref == 0 else { return nil }
        e.ended = true
        map[key] = e
        return (e.id, e.timeout, e.callbacks, reason)
    }

    func run(
        key: String,
        requireBackgroundTask: Bool,
        maxDuration: TimeInterval,
        onEnd: ((EndReason) -> Void)? = nil,
        callbackQueue: DispatchQueue = .main,
        work: (_ done: @escaping () -> Void) -> Void
    ) {
        start(key: key, requireBackgroundTask: requireBackgroundTask, maxDuration: maxDuration, onEnd: onEnd, callbackQueue: callbackQueue)
        let once = Once()
        let done = { [weak self] in
            once.run { self?.stop(key: key) }
        }
        work(done)
    }
}

private final class Once {
    private var ran = false
    private let q = DispatchQueue(label: "xchat.bg.once")
    func run(_ block: () -> Void) {
        var should = false
        q.sync { if !ran { ran = true; should = true } }
        if should { block() }
    }
}
