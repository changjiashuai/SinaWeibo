//
//  StatusPicture.swift
//  Weibo
//
//  Created by CJS on 16/9/4.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class StatusPicture:NSObject {
    
    /// 缩略图地址
    var thumbnail_pic:String?{
        didSet{
            largePic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/large/")
            thumbnail_pic = thumbnail_pic?.replacingOccurrences(of: "/thumbnail/", with: "/wap360/")
        }
    }
    
    var largePic: String?
    
    override var description: String{
        return yy_modelDescription()
    }
}
