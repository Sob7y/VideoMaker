//
//  AppManager.swift
//  MVVMDemo
//
//  Created by Mohammed Khaled on 11/25/19.
//  Copyright © 2019 Ibtikar. All rights reserved.
//

import Foundation
import UIKit

class AppManager: NSObject {
    static let shared = AppManager()
    
    var window: UIWindow?
    
    static func launchApp(_ application: UIApplication) {
        if #available(iOS 13, *) {
        } else {
            initWindow()
        }
    }
    
    static func initWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = Container.getLoginScreen()
        vc.view.backgroundColor = .blue
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.shared.window = window
    }
    
    static func initSceneWindow(_ windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        let vc = Container.getLoginScreen()
        vc.view.backgroundColor = .red
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.shared.window = window
    }
}
