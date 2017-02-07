//
//  EmoticonManager.swift
//  Weibo
//
//  Created by CJS on 16/9/17.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class EmoticonManager{
    
    static let shared = EmoticonManager()
    // 表情包的懒加载数组， 第一个数组是最近使用表情，加载之后，表情数组为空
    lazy var packages = [EmoticonPackage]()
    // 表情素材的Bundle
    lazy var bundle:Bundle = {
        let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil)
        let bundle = Bundle(path: path!)
        return bundle!
    }()
    private init(){
        loadPackages()
    }
}

// MARK: - 表情字符串处理
extension EmoticonManager{
    
    /// 查找字符串对应的表情
    ///
    /// - parameter string: 字符串
    ///
    /// - returns: 对应的表情
    func findEmoticon(string:String) -> Emoticon?{
        for package in packages{
            let result = package.emoticons.filter({ (emoticon) -> Bool in
                return emoticon.chs == string
            })
            if result.count == 1 {
                return result[0]
            }
        }
        return nil
    }
    
    /// 匹配对应表情 返回转换为表情的属性文本
    ///
    /// - parameter string: 原始文本
    /// - parameter font:   字体
    ///
    /// - returns: 带有表情的属性文本
    func emoticonString(string:String, font:UIFont) -> NSAttributedString{
        let attrString = NSMutableAttributedString(string: string)
        // 正则
        let pattern = "\\[.*?\\]"
        guard let regx = try? NSRegularExpression(pattern:pattern, options:[]) else {
            return attrString
        }
        let matches = regx.matches(in: string, options: [], range: NSRange(location: 0, length: attrString.length))
        for match in matches.reversed(){
            let range = match.rangeAt(0)
            let subStr = (attrString.string as NSString).substring(with: range)
            print("subStr = \(subStr)")
            if let emotion = findEmoticon(string: subStr) {
                attrString.replaceCharacters(in: range, with: emotion.imageText(font: font))
            }
        }
        attrString.addAttributes([NSFontAttributeName:font,
                                  NSForegroundColorAttributeName:UIColor.darkGray],
                                 range: NSRange(location: 0, length: attrString.length))
        return attrString
    }
}

// MARK: - 表情包数据处理
internal extension EmoticonManager{
    
    func recentEmotion(em: Emoticon){
        // 1. 增加使用次数
        em.times += 1
        // 2. 判断是否已经记录了该表情，如果没有则添加
        if !packages[0].emoticons.contains(em) {
            packages[0].emoticons.append(em)
        }
        // 3. 按使用次数排序表情
        packages[0].emoticons.sort { (em1, em2) -> Bool in
            return em1.times > em2.times
        }
        // 4. 判断是否超出一页范围，超出部分删除
        if packages[0].emoticons.count > 20 {
            packages[0].emoticons.removeSubrange(20..<packages[0].emoticons.count)
        }
    }
    
    func loadPackages(){
        guard let plistPath = bundle.path(forResource: "emoticons.plist", ofType: nil),
        let array = NSArray(contentsOfFile: plistPath) as? [[String:String]],
        let models = NSArray.yy_modelArray(with: EmoticonPackage.self, json: array) as? [EmoticonPackage]
        else {
            return
        }
        packages += models
    }
}
