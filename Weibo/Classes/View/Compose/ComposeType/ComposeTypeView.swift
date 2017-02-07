//
//  ComposeTypeView.swift
//  Weibo
//
//  Created by CJS on 16/9/15.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import pop

class ComposeTypeView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var closeCenterXCons: NSLayoutConstraint!
    @IBOutlet weak var returnCenterXCons: NSLayoutConstraint!
    var completionBlock: ((_ clsName:String?) -> ())?
    
    let buttonsInfo = [["imageName":"tabbar_compose_idea", "title":"文字", "clsName":"ComposeViewController"],
                       ["imageName":"tabbar_compose_photo", "title":"照片/视频"],
                       ["imageName":"tabbar_compose_weibo", "title":"长微博"],
                       ["imageName":"tabbar_compose_lbs", "title":"签到"],
                       ["imageName":"tabbar_compose_review", "title":"点评"],
                       ["imageName":"tabbar_compose_more", "title":"更多", "actionName":"clickMore"],
                       ["imageName":"tabbar_compose_friend", "title":"好友圈"],
                       ["imageName":"tabbar_compose_wbcamera", "title":"微博相机"],
                       ["imageName":"tabbar_compose_music", "title":"音乐"],
                       ["imageName":"tabbar_compose_shooting", "title":"拍摄"],]
    
    
    class func composeTypeView()->ComposeTypeView{
        let nib = UINib(nibName: "ComposeTypeView", bundle: nil)
        let v = nib.instantiate(withOwner: nil, options: nil)[0] as! ComposeTypeView
        v.frame = UIScreen.main.bounds
        v.setupUI()
        return v
    }
    
    func show(completion: ((_ clsName: String?) -> ())?){
        completionBlock = completion
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        vc.view.addSubview(self)
        showCurrentView()
    }
    
    func clickButton(selectButton: ComposeTypeButton){
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        for (i, btn) in v.subviews.enumerated(){
            let scaleAnim = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
            let scale = (selectButton == btn) ? 1.5 : 0.5
            scaleAnim?.toValue = NSValue(cgPoint: CGPoint(x: scale, y: scale))
            scaleAnim?.duration = 0.5
            btn.pop_add(scaleAnim, forKey: nil)
            
            let alphaAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnim?.toValue = 0.2
            alphaAnim?.duration = 0.5
            btn.pop_add(alphaAnim, forKey: nil)
            
            if i == 0 {
                alphaAnim?.completionBlock = {_, _ in
                    self.completionBlock?(selectButton.clsName)
                }
            }
        }
    }
    
    func clickMore(){
        let offset = CGPoint(x: scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        returnButton.isHidden = false
        let margin = scrollView.bounds.width / 6
        returnCenterXCons.constant -= margin
        closeCenterXCons.constant += margin
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func clickReturn() {
        let offset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        returnButton.isHidden = true
        let margin = scrollView.bounds.width / 6
        returnCenterXCons.constant += margin
        closeCenterXCons.constant -= margin
        UIView.animate(withDuration: 0.25) { 
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func close() {
        hideButtons()
    }
}

private extension ComposeTypeView{
    // MARK: -- 隐藏部分动画
    func hideButtons(){
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        let v = scrollView.subviews[page]
        for (i, btn) in v.subviews.enumerated().reversed(){
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim?.fromValue = btn.center.y
            anim?.toValue = btn.center.y + 400
            anim?.springBounciness = 8
            anim?.springSpeed = 10
            anim?.beginTime = CACurrentMediaTime() + CFTimeInterval(v.subviews.count - i) * 0.025
            btn.layer.pop_add(anim, forKey: nil)
            if i==0 {
                anim?.completionBlock = {(_, _) -> () in
                    self.hideCurrentView()
                }
            }
        }
    }
    
    func hideCurrentView(){
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim?.fromValue = 1
        anim?.toValue = 0
        anim?.duration = 0.25
        anim?.completionBlock = { _, _ in
            self.removeFromSuperview()
        }
        pop_add(anim, forKey: nil)
    }
    
    // MARK: -- 显示部分动画
    func showCurrentView(){
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim?.fromValue = 0
        anim?.toValue = 1
        anim?.duration = 0.25
        pop_add(anim, forKey: nil)
        showButtons()
    }
    
    func showButtons(){
        let v = scrollView.subviews[0]
        for (i, btn) in v.subviews.enumerated(){
            let anim = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            anim?.fromValue = btn.center.y + 400
            anim?.toValue = btn.center.y
            anim?.springBounciness = 8
            anim?.springSpeed=10
            anim?.beginTime = CACurrentMediaTime() + CFTimeInterval(i) * 0.025
            btn.layer.pop_add(anim, forKey: nil)
        }
    }
}

private extension ComposeTypeView{
    func setupUI(){
        //强制刷新布局 计算frame
        layoutIfNeeded()
        let rect = scrollView.bounds
        let width = scrollView.bounds.width
        let v = UIView(frame:rect)
        addButtons(v: v, idx: 0)
        scrollView.addSubview(v)
        let v2 = UIView(frame: rect.offsetBy(dx: width, dy: 0))
        addButtons(v: v2, idx: 6)
        scrollView.addSubview(v2)
        scrollView.contentSize = CGSize(width: 2 * width, height: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
    }
    
    func addButtons(v:UIView, idx:Int){
        let count = 6
        for i in idx..<(idx+count) {
            if i >= buttonsInfo.count {
                break
            }
            
            let dict = buttonsInfo[i]
            guard let imageName = dict["imageName"],
                let title = dict["title"] else {
                    continue
            }
            let btn = ComposeTypeButton.composeTypeButton(imageName: imageName, title: title)
            v.addSubview(btn)
            if let actionName = dict["actionName"] {
                btn.addTarget(self, action: Selector(actionName), for: .touchUpInside)
            }else{
                btn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            }
            btn.clsName = dict["clsName"]
        }
        
        let btnSize = CGSize(width: 100, height: 100)
        let margin = (v.bounds.width-3*btnSize.width)/4
        
        for (i, btn) in v.subviews.enumerated() {
            
            let y:CGFloat = (i>2) ? (v.bounds.height-btn.bounds.height) : 0
            let col = i % 3
            let x = CGFloat(col+1) * margin + CGFloat(col)*btn.bounds.width
            print("x=\(x)")
            btn.frame = CGRect(x: x, y: y, width: btnSize.width, height: btnSize.height)
        }
    }
}
