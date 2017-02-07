//
//  Status.swift
//  Weibo
//
//  Created by CJS on 16/8/28.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import YYModel

class Status: NSObject {
    var id:Int64 = 0;
    // 微博正文
    var text:String?
    // 转发数
    var reposts_count:Int = 0
    // 评论数
    var comments_count:Int = 0
    // 表态数
    var attitudes_count:Int = 0
    // 被转发微博
    var retweeted_status:Status?
    // 微博创建时间
    var created_at:String?{
        didSet{
            createDate = Date.cz_sinaDate(string: created_at ?? "")
        }
    }
    var createDate: Date?
    // 	微博来源
    var source:String?
    
    var user:User?
    
    var pic_urls: [StatusPicture]?
    
    override var description: String{
       return yy_modelDescription()
    }
    
    class func modelContainerPropertyGenericClass() -> [String:AnyClass]{
        return ["pic_urls": StatusPicture.self]
    }
}
