//
//  AppDelegate.swift
//  Weibo
//
//  Created by CJS on 16/8/21.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupAdditions()
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        loadAppInfo()
        SQLiteManager.shared
        return true
    }
}

extension AppDelegate{
    func setupAdditions(){
        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
}

extension AppDelegate{
    func loadAppInfo() {
        let url = Bundle.main.url(forResource: "main.json", withExtension: nil)
        let data = NSData(contentsOf: url!)
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
        data?.write(toFile: jsonPath, atomically: true)
        print("应用程序加载完成 \(jsonPath)")
    }
}
