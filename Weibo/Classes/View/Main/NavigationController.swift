//
//  NavigationController.swift
//  Weibo
//
//  Created by CJS on 16/8/21.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        print("vc = \(viewController)")
        if childViewControllers.count>0 {
            viewController.hidesBottomBarWhenPushed = true
            
            if let vc = viewController as? BaseViewController{
                var title = "返回"
                if childViewControllers.count==1 {
                    title = childViewControllers.first?.title ?? "返回"
                }
                
                vc.navItem.leftBarButtonItem = UIBarButtonItem(title: title, target: self, action: #selector(popToParent), isBack: true)
            }
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    func popToParent(){
        popViewController(animated: true)
    }
}
