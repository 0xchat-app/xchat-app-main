//
//  OXCLaunchCoordinator.swift
//  Runner
//
//  Created by Zharlie on 2024/3/25.
//

import UIKit
import Flutter

class OXCLaunchCoordinator {

    static let shared = OXCLaunchCoordinator()
    
    let mainController: FlutterViewController = FlutterViewController()
    
    func start(window: UIWindow) {
        registeFlutterPlugin(window: window)
    }
    
    private func registeFlutterPlugin(window: UIWindow) {

        let navController = window.rootViewController as? UINavigationController ?? UINavigationController()
    
        GeneratedPluginRegistrant.register(with: mainController)
        if let plugin = mainController.registrar(forPlugin: "OXPerference") {
            OXPerferencePlugin.register(with:plugin)
        }
        OXCNavigator.register(with: mainController.engine)
        
        navController.setViewControllers([mainController], animated: false)
        window.rootViewController = navController
    }
}
