//
//  VisitorView.swift
//  Weibo
//
//  Created by CJS on 16/8/24.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class VisitorView: UIView {
    
    /// dict ["imageName":"", "message":""]
    var visitorInfo:[String:String]?{
        didSet{
            guard let imageName=visitorInfo?["imageName"],
                let message = visitorInfo?["message"] else {
                    return
            }
            tipLabel.text = message
            if imageName=="" {
                startAnimation()    
                return
            }
            iconImage.image = UIImage(named: imageName)
            houseIconImage.isHidden = true
            maskIconView.isHidden = true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.duration = 15
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        iconImage.layer.add(anim, forKey: nil)
    }
    
    lazy var iconImage = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    lazy var maskIconView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
    lazy var houseIconImage = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    lazy var tipLabel:UILabel = UILabel.cz_label(withText: "关注一些人，回这里看看有什么惊喜", fontSize: 14, color: UIColor.darkGray)
    lazy var registerButton:UIButton = UIButton.cz_textButton("注册", fontSize: 16, normalColor: UIColor.orange, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
    
    lazy var loginButton:UIButton = UIButton.cz_textButton("登录", fontSize: 16, normalColor: UIColor.darkGray, highlightedColor: UIColor.black, backgroundImageName: "common_button_white_disable")
}

extension VisitorView{
    func setupUI() {
        backgroundColor = UIColor.cz_color(withHex: 0xEDEDED)
        // 1. 添加控件
        addSubview(iconImage)
        addSubview(maskIconView)
        addSubview(houseIconImage)
        addSubview(tipLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        tipLabel.textAlignment = .center
        // 2. 取消autoResizing
        for v in subviews {
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        // 3. 设置自动布局
        
        //
        addConstraint(NSLayoutConstraint(item: iconImage,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: iconImage,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: -60))
        //
        addConstraint(NSLayoutConstraint(item: houseIconImage,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: iconImage,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: houseIconImage,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: iconImage,
                                         attribute: .centerY,
                                         multiplier: 1.0,
                                         constant: 0))
        //
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: iconImage,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: iconImage,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 20))
        addConstraint(NSLayoutConstraint(item: tipLabel,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: 236))
        //
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .left,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 20))
        addConstraint(NSLayoutConstraint(item: registerButton,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: 100))
        //
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .right,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .right,
                                         multiplier: 1.0,
                                         constant: 0))
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: tipLabel,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 20))
        addConstraint(NSLayoutConstraint(item: loginButton,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: registerButton,
                                         attribute: .width,
                                         multiplier: 1.0,
                                         constant: 0))
        //
        let viewDict:[String:Any] = ["maskIconView":maskIconView,
                        "registerButton":registerButton]
        let metrics = ["spacing":-35]
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[maskIconView]-0-|",
            options: [],
            metrics: nil,
            views: viewDict))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[maskIconView]-(spacing)-[registerButton]",
            options: [],
            metrics: metrics,
            views: viewDict))
    }
}
