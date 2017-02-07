//
//  TitleButton.swift
//  Weibo
//
//  Created by CJS on 16/9/1.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class TitleButton: UIButton {
    init(title:String?) {
        super.init(frame: CGRect())
        if title == nil {
            setTitle("首页", for: [])
        }else{
            setTitle(title, for: [])
            setImage(UIImage(named: "navigationbar_arrow_down"), for: [])
            setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        }
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        setTitleColor(UIColor.darkGray, for: [])
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel, let imageView = imageView else {
            return
        }
        titleLabel.frame.origin.x = 0
        imageView.frame.origin.x = titleLabel.bounds.width
    }
}
