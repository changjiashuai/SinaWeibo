//
//  WelcomeView.swift
//  Weibo
//
//  Created by CJS on 16/9/2.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeView: UIView {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var bottomCons: NSLayoutConstraint!
   
    // 头像宽度约束
    @IBOutlet weak var iconWidthCons: NSLayoutConstraint!
    
    class func welcomeView() -> WelcomeView {
        let v = UINib(nibName: "WelcomeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! WelcomeView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        guard let urlString = NetworkManager.shared.userAccount.avatar_large,
            let url = URL(string: urlString) else {
                return
        }
        print("url = \(url)")
        iconView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar_default_big"))
        iconView.layer.cornerRadius = iconWidthCons.constant * 0.5
        iconView.layer.masksToBounds = true
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.layoutIfNeeded()
        print("didMoveToWindow \(bottomCons.constant)  \(bounds.size.height)")
        bottomCons.constant = bounds.size.height - 200
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { 
                        //
                        self.layoutIfNeeded()
            }) { (_) in
                //
                UIView.animate(withDuration: 1.0, animations: { 
                    self.tipLabel.alpha = 1
                    }, completion: { (_) in
                        //
                        self.removeFromSuperview()
                })
        }
    }
}
