//
//  MainViewController.swift
//  Weibo
//
//  Created by CJS on 16/8/21.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainViewController: UITabBarController {
    
    lazy var composeButton: UIButton = UIButton.cz_imageButton("tabbar_compose_icon_add", backgroundImageName: "tabbar_compose_button")
    
    var timer: Timer?
    
    deinit {
        // 释放时钟
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupChildControllers()
        setupComposeButton()
        if NetworkManager.shared.userLogon {
            setupTimer()
        }
        setupNewFeatureViews()
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(userLogin), name: NSNotification.Name(rawValue: UserShouldLoginNotification), object: nil)
    }
    
    func userLogin(notification: Notification){
        print("\(notification)")
        var deadline = DispatchTime.now()
        if notification.object != nil {
            SVProgressHUD.setDefaultMaskType(.gradient)
            SVProgressHUD.showInfo(withStatus: "登录过期，请重新登录")
            deadline = DispatchTime.now() + 1
        }
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            SVProgressHUD.setDefaultMaskType(.clear)
            let nav = UINavigationController(rootViewController: OAuthViewController())
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    @objc func composeStatus() {
        let v = ComposeTypeView.composeTypeView()
        v.show { [weak v] (clsName) in
            guard let clsName = clsName,
            let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? UIViewController.Type else {
                v?.removeFromSuperview()
                return
            }
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            // 强制更新约束
            nav.view.layoutIfNeeded()
            self.present(nav, animated: true, completion: {
                v?.removeFromSuperview()
            })
        }
    }
}

extension MainViewController{
    func setupNewFeatureViews(){
        if !NetworkManager.shared.userLogon {
            return
        }
        
        let v = isNewVersion ? NewFeatureView.newFeatureView() : WelcomeView.welcomeView()

        view.addSubview(v)
    }
    
    private var isNewVersion:Bool {
        // 获取当前版本
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print(currentVersion)
        
        let path:String = ("version" as NSString).cz_appendDocumentDir()
        
        // 获取沙盒版本
        let sandboxVersion = try? String(contentsOfFile: path, encoding: .utf8)
        // 保存当前版本到沙盒
        try? currentVersion.write(toFile: path, atomically: true, encoding: .utf8)
        
        return currentVersion != sandboxVersion
    }
}

extension MainViewController:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = childViewControllers.index(of: viewController)
        
        if selectedIndex == 0 && index==selectedIndex {
            //重复点击首页
            let nav = childViewControllers[0] as! NavigationController
            let vc = nav.childViewControllers[0] as! HomeViewController
            vc.tableView?.setContentOffset(CGPoint(x:0, y:-64), animated: true)
            vc.loadData()
            // 清除红点
            vc.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        return !viewController.isMember(of: UIViewController.self)
    }
}

extension MainViewController{
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        NetworkManager.shared.unreadCount { (count) in
            print("has \(count) new weibo")
            self.tabBar.items?[0].badgeValue = count>0 ? "\(count)" : nil
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}

extension MainViewController{
    
    func setupComposeButton(){
        tabBar.addSubview(composeButton)
        let count = CGFloat(childViewControllers.count)
        let w = tabBar.bounds.width / count  //-1//容错 不需要了，使用delegate彻底解决
        composeButton.frame = tabBar.bounds.insetBy(dx: 2*w, dy: 0)
        composeButton.addTarget(self, action: #selector(composeStatus), for: .touchUpInside)
    }
    
    public func setupChildControllers(){
        
        /*
        let array = [
            ["clsName": "HomeViewController", "title": "首页", "imageName": "home",
             "visitorInfo":["imageName":"", "message":"关注一些人，回这里看看有什么惊喜"]
             ],
            ["clsName": "MessageViewController", "title": "消息", "imageName": "message_center",
             "visitorInfo":["imageName":"visitordiscover_image_message", "message":"登录后，别人评论你的微博，发给你的消息，都会在这里收到通知"]
            ],
            ["clsName":"UIViewController"],
            ["clsName": "DiscoverViewController", "title": "发现", "imageName": "discover",
             "visitorInfo":["imageName":"visitordiscover_image_message", "message":"登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过"]
            ],
            ["clsName": "ProfileViewController", "title": "我", "imageName": "profile",
             "visitorInfo":["imageName":"visitordiscover_image_profile", "message":"登录后，你的微博、相册、个人资料会显示在这里，展示给别人"]
            ]
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: array, options: [.prettyPrinted])
        (data as NSData).write(toFile: "/Users/CJS/Desktop/main.json", atomically: true)
        */
        
        // 0 从沙盒获取json
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
        var data = NSData(contentsOfFile: jsonPath)
        if data == nil {
            let path = Bundle.main.path(forResource: "main.json", ofType: nil)
            data = NSData(contentsOfFile: path!)
        }
        guard let array = try? JSONSerialization.jsonObject(with: data as! Data, options: []) as! [[String:Any]]
            else {
            return
        }
        var arrayM = [UIViewController]()
        
        for dict in array {
            arrayM.append(controller(dict: dict))
        }
        
        viewControllers = arrayM
    }
    
    private func controller(dict: [String:Any])->UIViewController{
        guard let clsName=dict["clsName"] as? String,
                let title = dict["title"] as? String,
                let imageName = dict["imageName"] as? String,
                let visitorInfo = dict["visitorInfo"] as? [String:String],
                let cls = NSClassFromString(Bundle.main.namespace+"."+clsName) as? BaseViewController.Type else {
            return UIViewController()
        }
        
        let vc = cls.init()
        vc.title = title
        vc.visitorInfo = visitorInfo
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_"+imageName+"_selected")?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.orange], for: .highlighted)
        let nav = NavigationController(rootViewController: vc)
        return nav
    }
}
