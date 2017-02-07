//
//  Emoticon.swift
//  Weibo
//
//  Created by CJS on 16/9/17.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class Emoticon: NSObject {
    // 表情类型 false - 图片表情， true - emoji
    var type = false
    // 表情字符串，发送给新浪微博服务器（节约流量）
    var chs:String?
    // 表情图片名称，用于本地图文混排
    var png:String?
    // emoji 的十六进制编码
    var code:String?{
        didSet{
            if let code = code {
                let scanner = Scanner(string:code)
                var result:UInt32 = 0
                scanner.scanHexInt32(&result)
                emoji = String(Character(UnicodeScalar(result)!))
            }
        }
    }
    // 使用次数
    var times: Int = 0
    var emoji:String?
    // 表情模型所在的目录
    var directory:String?
    // ‘图片’ 表情对应的图像
    var image: UIImage? {
        // 判断表情类型
        if type {
            // emoji
            return nil
        }
        
        guard let directory = directory,
            let png = png,
            let path = Bundle.main.path(forResource: "HMEmoticon.bundle", ofType: nil),
            let bundle = Bundle(path: path)
            else {
            return nil
        }
        return UIImage(named: "\(directory)/\(png)", in: bundle, compatibleWith: nil)
    } 
    
    /// 将当前的表情图像转换为生成图片的属性文本
    ///
    /// - parameter font: 字体
    ///
    /// - returns: 当前文本的属性文本
    func imageText(font: UIFont) -> NSAttributedString{
        // 1> 判断图像是否存在
        guard let image = image else {
            return NSAttributedString(string: "")
        }
        // 2> 创建文本附件
        let attachment = EmoticonTextAttachment()
        attachment.chs = chs
        attachment.image = image
        let height = font.lineHeight
        attachment.bounds = CGRect(x: 0, y: -4, width: height, height: height)
        let attrStrM = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        attrStrM.addAttributes([NSFontAttributeName:font], range: NSRange(location: 0, length: 1))
        return attrStrM
    }
    
    override var description: String{
        return yy_modelDescription()
    }
}
