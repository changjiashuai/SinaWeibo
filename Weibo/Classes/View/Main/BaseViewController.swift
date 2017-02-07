//
//  BaseViewController.swift
//  Weibo
//
//  Created by CJS on 16/8/21.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var tableView: UITableView?
    var refreshControl: RefreshControl?
    var visitorInfo:[String:String]?
    var isPullup = false
    
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.cz_screenWidth(), height: 64))
    lazy var navItem = UINavigationItem()
    
    override var title: String?{
        didSet{
            navItem.title = title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        //userLogon ? setupTableView() : setupVistorView()
        if NetworkManager.shared.userLogon {
            setupTableView()
            loadData()
        }else{
            setupVistorView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: UserLoginSuccessNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        refreshControl?.endRefreshing()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.insertSubview(tableView!, belowSubview: navigationBar)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.contentInset = UIEdgeInsets(top: navigationBar.bounds.height, left: 0, bottom: tabBarController?.tabBar.bounds.height ?? 49, right: 0)
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        refreshControl = RefreshControl()
        tableView?.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    func setupVistorView() {
        let vistorView = VisitorView(frame: view.bounds)
        vistorView.visitorInfo = visitorInfo
        vistorView.registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        vistorView.loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
        view.insertSubview(vistorView, belowSubview: navigationBar)
    }
    
    func login(){
        print("用户登录")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserShouldLoginNotification), object: nil)
    }
    
    func loginSuccess(notification: Notification){
        navItem.leftBarButtonItem = nil
        navItem.rightBarButtonItem = nil
        // 重新加载界面
        view = nil   // loadView -> viewDidLoad
        // 注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    func register(){
        print("用户注册")
    }
    
    func setupNavigationBar(){
        view.backgroundColor = UIColor.cz_random()
        navigationBar.items = [navItem]
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.darkGray]
        navigationBar.tintColor = UIColor.orange
        view.addSubview(navigationBar)
    }
}

extension BaseViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = tableView.numberOfSections - 1
        if row<0||section<0 {
            return
        }
        let count = tableView.numberOfRows(inSection: section)
        if row==(count-1) && !isPullup{
            print("开始上拉刷新")
            isPullup = true
            loadData()
        }
    }
}
