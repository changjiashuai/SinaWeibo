//
//  EmoticonPackage.swift
//  Weibo
//
//  Created by CJS on 16/9/17.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject {
    // 表情包的分组名
    var groupName:String?
    // 背景图片名称
    var bgImageName:String?
    // 表情包目录， 从目录下加载 info.plist 可以创建表情模型数组
    var directory:String?{
        didSet{
            //
            guard let directory = directory,
                let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
                let bundle = Bundle(path: path),
                let infoPath = bundle.path(forResource: "info.plist", ofType: nil, inDirectory: directory),
                let array = NSArray(contentsOfFile: infoPath) as? [[String:String]],
                let models = NSArray.yy_modelArray(with: Emoticon.self, json: array) as? [Emoticon]
            else {
                return
            }
         
            for model in models {
                model.directory = directory
            }
            emoticons += models 
        }
    }
    // 懒加载 表情模型的数组
    lazy var emoticons = [Emoticon]()
    
    // 表情页面数量， 每页20个表情
    var numberOfPages: Int {
        return (emoticons.count - 1) / 20 + 1
    }
    
    
    /// 每页显示的表情数组，最多20个
    ///
    /// - parameter page: 当前页
    ///
    /// - returns: 当前页的表情数组
    func emoticon(page: Int) -> [Emoticon]{

        let count = 20
        let location = page * count
        var length = count
        
        if length + location > emoticons.count {
            length = emoticons.count - location
        }
        let range = NSRange(location: location, length: length)
        let subArray = (emoticons as NSArray).subarray(with: range)
        return subArray as! [Emoticon]
    }
    
    override var description: String{
        return yy_modelDescription()
    }
}
