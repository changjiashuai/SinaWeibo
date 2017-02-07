//
//  OAuthViewController.swift
//  Weibo
//
//  Created by CJS on 16/8/29.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {

    lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        webView.scrollView.isScrollEnabled = false
        webView.delegate = self
        title = "微博登录"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", target: self, action: #selector(close), isBack: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFill))
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(AppKey)&redirect_uri=\(RedirectURI)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    func close(){
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    }
    
    func autoFill(){
        let js = "document.getElementById('userId').value='rj1031cjs@163.com';"
            + "document.getElementById('passwd').value='';"
        webView.stringByEvaluatingJavaScript(from: js)
    }
}

extension OAuthViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("request=\(request.url?.query)")
        
        // 加载授权页面
        if request.url?.absoluteString.hasPrefix(RedirectURI) == false{
            return true
        }
        
        // 授权失败 返回
        if request.url?.query?.hasPrefix("code=") == false {
            close()
            return false
        }
        // 获取授权码
        let code = request.url?.query?.substring(from: "code=".endIndex)
        print("code=\(code)")
        NetworkManager.shared.loadAccessToken(code: code!) { (isSuccess) in
            if isSuccess {
                SVProgressHUD.showInfo(withStatus: "登录成功")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserLoginSuccessNotification), object: nil)
                self.close()
                
            }else{
                SVProgressHUD.showInfo(withStatus: "登录失败")
            }
        }
        return false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}
