//
//  WebViewController.swift
//  Weibo
//
//  Created by CJS on 16/9/17.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class WebViewController: BaseViewController {
    var urlString : String?{
        didSet{
            guard let urlString = urlString,
                let url = URL(string: urlString) else {
                return
            }
            webView.loadRequest(URLRequest(url: url))
        }
    }
    lazy var webView = UIWebView(frame:UIScreen.main.bounds)
    
    override func setupTableView() {
        navItem.title = "网页"
        view.insertSubview(webView, belowSubview: navigationBar)
        webView.backgroundColor = UIColor.white
        webView.scrollView.contentInset.top = navigationBar.bounds.height
    }
}
