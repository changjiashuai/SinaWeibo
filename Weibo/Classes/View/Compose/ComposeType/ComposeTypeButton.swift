//
//  ComposeTypeButton.swift
//  Weibo
//
//  Created by CJS on 16/9/15.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class ComposeTypeButton: UIControl {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    var clsName:String?
    
    class func composeTypeButton(imageName:String, title:String)->ComposeTypeButton{
        let nib = UINib(nibName: "ComposeTypeButton", bundle: nil)
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! ComposeTypeButton
        btn.imageView.image = UIImage(named: imageName)
        btn.title.text = title
        return btn
    }
}
