//
//  HomeViewController.swift
//  Weibo
//
//  Created by CJS on 16/8/21.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

// 原创微博 可重用cellId
private let originalCellId = "originalCellId"
// 被转发微博 可重用cellId
private let retweetedCellId = "retweetedCellId"

class HomeViewController: BaseViewController {

    lazy var listViewModel = StatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(browserPhoto), name: NSNotification.Name(rawValue: StatusCellBrowerPhotoNotification), object: nil)
        setupNavTitle()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func browserPhoto(notification: Notification){
        guard let selectedIndex = notification.userInfo?[StatusCellBrowerPhotoSelectedIndexKey] as? Int,
        let urls = notification.userInfo?[StatusCellBrowerPhotoURLsKey] as? [String],
            let imageViewList = notification.userInfo?[StatusCellBrowerPhotoImageViewsKey] as? [UIImageView] else {
                return
        }
        
        let vc = HMPhotoBrowserController.photoBrowser(withSelectedIndex: selectedIndex, urls: urls, parentImageViews: imageViewList)
        present(vc, animated: true, completion: nil)
    }
    
    func setupNavTitle(){
        let title = NetworkManager.shared.userAccount.screen_name
        let button = TitleButton(title: title)
        button.addTarget(self, action: #selector(clickTitleButton), for: .touchUpInside)
        navItem.titleView = button
    }
    
    func clickTitleButton(btn:UIButton){
        btn.isSelected = !btn.isSelected
    }

    override func setupTableView() {
        super.setupTableView()
        
        //tableView?.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        tableView?.register(UINib(nibName: "StatusNormalCell", bundle: nil), forCellReuseIdentifier: originalCellId)
        tableView?.register(UINib(nibName: "StatusRetweetedCell", bundle: nil), forCellReuseIdentifier: retweetedCellId)
        tableView?.rowHeight = UITableViewAutomaticDimension
        // 预估行高
        tableView?.estimatedRowHeight = 300
        // 取消分割线
        tableView?.separatorStyle = .none
        
        self.navItem.leftBarButtonItem = UIBarButtonItem(title: "好友", target: self, action: #selector(showFriends))
    }
    
    func showFriends(){
        let messageVC = ViewController()
        navigationController?.pushViewController(messageVC, animated: true)
    }
    
    override func loadData() {
        
        print("上拉加载前最后一条数据 \(listViewModel.statusList.last?.status.text)")
        refreshControl?.beginRefreshing()
        listViewModel.loadStatus(isPullUp: isPullup) { (isSuccess, shouldRefresh) in
            
            print("数据加载完成 isSuccess=\(isSuccess)")
            self.refreshControl?.endRefreshing()
            self.isPullup = false
            if shouldRefresh {
                self.tableView?.reloadData()
            }
        }
    }
}

extension HomeViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let statusView = listViewModel.statusList[indexPath.row]
        let cellId = statusView.status.retweeted_status != nil ? retweetedCellId : originalCellId
        // FIXME:  设置cellId
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! StatusCell
        cell.viewModel = statusView
        cell.delegate = self
        return cell
    }
}

// MARK: -- StatusCellDelegate
extension HomeViewController: StatusCellDelegate{
    func statusCellDidSelectedURLString(cell: StatusCell, urlString: String) {
        //
        let vc = WebViewController()
        vc.urlString = urlString
        navigationController?.pushViewController(vc, animated: true)
    }
}
