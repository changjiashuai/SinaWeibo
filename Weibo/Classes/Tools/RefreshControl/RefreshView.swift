//
//  RefreshView.swift
//  Weibo
//
//  Created by CJS on 16/9/11.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class RefreshView: UIView {
    
    var refreshState:RefreshState = .Normal{
        didSet{
            switch refreshState {
            case .Normal:
                tipIcon?.isHidden = false
                indicator?.stopAnimating()
                tipLabel?.text = "继续下拉"
                UIView.animate(withDuration: 0.25, animations: { 
                    self.tipIcon?.transform = CGAffineTransform.identity
                })
            case .Pulling:
                tipLabel?.text = "松手刷新"
                UIView.animate(withDuration: 0.25, animations: { 
                    self.tipIcon?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI - 0.0001))
                })
            case .WillRefresh:
                tipLabel?.text = "正在刷新中..."
                tipIcon?.isHidden = true
                indicator?.startAnimating()
            }
        }
    }
    
    var parentHeight:CGFloat = 0
    
    @IBOutlet weak var tipIcon: UIImageView?
    @IBOutlet weak var tipLabel: UILabel?
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    class func refreshView() -> RefreshView{
        let nib = UINib(nibName: "MeituanRefreshView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil)[0] as! RefreshView
    }
}
