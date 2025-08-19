//
//  IMBackgroundCoordinator.swift
//  Runner
//
//  Created by w on 2025/8/13.
//

import UIKit
import BackgroundTasks

final class IMBackgroundCoordinator {

    static let shared = IMBackgroundCoordinator()
    
    struct Config {
        let bgRefreshIdentifier: String
        let bgProcessingIdentifier: String
        let urlSessionIdentifier: String
        let defaultAddTimeSeconds: TimeInterval
        init(bgRefreshIdentifier: String,
             bgProcessingIdentifier: String,
             urlSessionIdentifier: String,
             defaultAddTimeSeconds: TimeInterval = 27) {
            self.bgRefreshIdentifier = bgRefreshIdentifier
            self.bgProcessingIdentifier = bgProcessingIdentifier
            self.urlSessionIdentifier = urlSessionIdentifier
            self.defaultAddTimeSeconds = defaultAddTimeSeconds
        }
    }

    private var config: Config!
    private let bgTask = BackgroundActivityManager.shared
    private var pendingURLSessionCompletion: (() -> Void)?

    func configure(with config: Config) {
        self.config = config
        registerBGTasks()
    }

    func handleSilentPush(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let key = "bg.silent.push"
        bgTask.start(key: key, requireBackgroundTask: true, maxDuration: config.defaultAddTimeSeconds) { _ in
            completionHandler(.newData)
        }
    }
    
    func applicationDidEnterBackground() {
        let key = "bg.app.enter.background"
        bgTask.start(key: key, requireBackgroundTask: true, maxDuration: config.defaultAddTimeSeconds)
    }
}

// MARK: BGTaskScheduler
extension IMBackgroundCoordinator {
    private func registerBGTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: config.bgRefreshIdentifier, using: nil) { [weak self] task in
            self?.handleAppRefresh(task as! BGAppRefreshTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: config.bgProcessingIdentifier, using: nil) { [weak self] task in
            self?.handleProcessing(task as! BGProcessingTask)
        }
    }

    func scheduleAppRefresh(after seconds: TimeInterval = 15*60) {
        let req = BGAppRefreshTaskRequest(identifier: config.bgRefreshIdentifier)
        req.earliestBeginDate = Date(timeIntervalSinceNow: seconds)
        _ = try? BGTaskScheduler.shared.submit(req)
    }

//    func scheduleProcessing(earliestBegin: TimeInterval? = nil,
//                            requirePower: Bool = false,
//                            requireNetwork: Bool = true) {
//        let req = BGProcessingTaskRequest(identifier: config.bgProcessingIdentifier)
//        req.requiresExternalPower = requirePower
//        req.requiresNetworkConnectivity = requireNetwork
//        if let eb = earliestBegin { req.earliestBeginDate = Date(timeIntervalSinceNow: eb) }
//        _ = try? BGTaskScheduler.shared.submit(req)
//    }

    private func handleAppRefresh(_ task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let key = "bg.app.refresh"
        bgTask.start(key: key, requireBackgroundTask: true, maxDuration: config.defaultAddTimeSeconds)

        task.expirationHandler = { [weak self] in
            self?.bgTask.stop(key: key)
        }
    }

    private func handleProcessing(_ task: BGProcessingTask) {
        let key = "bg.app.processing"
        bgTask.start(key: key, requireBackgroundTask: true, maxDuration: config.defaultAddTimeSeconds)

        task.expirationHandler = { [weak self] in
            self?.bgTask.stop(key: key)
        }
    }
}
