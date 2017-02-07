//
//  ComposeViewController.swift
//  Weibo
//
//  Created by CJS on 16/9/16.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController {

    @IBOutlet weak var textView: ComposeTextView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var toolbarBottomCons: NSLayoutConstraint!
    
//    lazy var sendButton:UIButton = {
//        let btn = UIButton()
//        btn.setTitle("发布", for: [])
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//        btn.setTitleColor(UIColor.white, for: [])
//        btn.setTitleColor(UIColor.gray, for: .disabled)
//        btn.setBackgroundImage(UIImage(named: "common_button_orange_highlighted"), for: .highlighted)
//        btn.setBackgroundImage(UIImage(named:"common_button_orange"), for: [])
//        btn.setBackgroundImage(UIImage(named:"common_button_white_disable"), for: .disabled)
//        btn.frame = CGRect(x: 0, y: 0, width: 45, height: 35)
//        return btn
//    }()
    lazy var emoticonView:EmoticonInputView = EmoticonInputView.inputView {[weak self] (emoticon) in
        //
        self?.textView.insertEmoticon(emoticon: emoticon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func close(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postStatus() {
        let text = textView.emoticonText()
        let image = UIImage(named: "new_feature_3")
        NetworkManager.shared.postStatus(text: text, image: image) { (json, isSuccess) in
            print(json)
            let message = isSuccess ? "发布成功" : "发布失败"
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showInfo(withStatus: message)
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    SVProgressHUD.setDefaultMaskType(.none)
                    self.close()
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
}

// MARK: - UITextViewDelegate
extension ComposeViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
}

private extension ComposeViewController{
    func setupUI(){
        view.backgroundColor = UIColor.white
        setupNavgationBar()
        setupToolbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardChanged(n: Notification){
        print(n.userInfo)
        guard let rect = (n.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
        let duration = (n.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        let offset = view.bounds.height - rect.origin.y
        toolbarBottomCons.constant = offset
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func emoticonKeyboard(){
        
        textView.inputView = textView.inputView == nil ? emoticonView : nil
        textView.reloadInputViews()
    }
  
    
    func setupNavgationBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        navigationItem.titleView = titleLabel
        sendButton.isEnabled = false
    }
    
    func setupToolbar(){
        
        let itemSettings = [["imageName":"compose_toolbar_picture"],
                            ["imageName":"compose_mentionbutton_background"],
                            ["imageName":"compose_trendbutton_background"],
                            ["imageName":"compose_emoticonbutton_background", "actionName":"emoticonKeyboard"],
                            ["imageName":"compose_add_background"]]
        
        var items = [UIBarButtonItem]()
        for s in itemSettings{
            let imageName = s["imageName"]!
            let image = UIImage(named: imageName)
            let imageHL = UIImage(named: imageName + "_highlighted")
            let btn = UIButton()
            btn.sizeToFit()
            btn.setImage(image, for: [])
            btn.setImage(imageHL, for: .highlighted)
            if let actionName = s["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }
            
            items.append(UIBarButtonItem(customView: btn))
            items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolbar.items = items
    }
}
