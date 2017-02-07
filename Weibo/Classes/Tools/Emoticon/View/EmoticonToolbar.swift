//
//  EmoticonToolbar.swift
//  Weibo
//
//  Created by CJS on 16/9/25.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

protocol EmoticonToolbarDelegate: NSObjectProtocol {
    func emoticonToolbarDidSelectedItemIndex(toolbar:EmoticonToolbar, index:Int);
}

class EmoticonToolbar: UIView {
    
    weak var delegate: EmoticonToolbarDelegate?
    
    var selectedIndex: Int = 0 {
        didSet{
            for (i, btn) in (subviews as! [UIButton]).enumerated() {
                if i == selectedIndex {
                    btn.isSelected = true
                }else{
                    btn.isSelected = false
                }
            }
        }
    }

    override func awakeFromNib() {
        setupUI()
    }

    func setupUI(){
        for (i, p) in EmoticonManager.shared.packages.enumerated() {
            let btn = UIButton()
            btn.setTitle(p.groupName, for: [])
            btn.setTitleColor(UIColor.white, for: [])
            btn.setTitleColor(UIColor.darkGray, for: .highlighted)
            btn.setTitleColor(UIColor.darkGray, for: .selected)
            
            let imageName = "compose_emotion_table_\(p.bgImageName ?? "")_normal"
            let imageNameSel = "compose_emotion_table_\(p.bgImageName ?? "")_selected"
            
            var image = UIImage(named: imageName, in: EmoticonManager.shared.bundle, compatibleWith: nil)
            var imageSel = UIImage(named: imageNameSel, in: EmoticonManager.shared.bundle, compatibleWith: nil)
            
            let size = image?.size ?? CGSize()
            let insets = UIEdgeInsets(top: size.height * 0.5,
                                      left: size.width * 0.5,
                                      bottom: size.height * 0.5,
                                      right: size.width * 0.5)
            image = image?.resizableImage(withCapInsets: insets)
            imageSel = imageSel?.resizableImage(withCapInsets: insets)
            
            btn.setBackgroundImage(image, for: [])
            btn.setBackgroundImage(imageSel, for: .highlighted)
            btn.setBackgroundImage(imageSel, for: .selected)
            btn.tag = i
            if i==0 {
                btn.isSelected = true
            }
            btn.addTarget(self, action: #selector(clickItem), for: .touchUpInside)
            addSubview(btn)
        }
    }
    
    func clickItem(button: UIButton){
        delegate?.emoticonToolbarDidSelectedItemIndex(toolbar: self, index: button.tag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width / CGFloat(subviews.count)
        let rect = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        for (i, btn) in subviews.enumerated() {
            btn.frame = rect.offsetBy(dx: CGFloat(i) * w, dy: 0)
        }
    }
}
