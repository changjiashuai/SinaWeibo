//
//  StatusViewModel.swift
//  Weibo
//
//  Created by CJS on 16/9/3.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation

/// 单条微博数据模型
class StatusViewModel: CustomStringConvertible {
    var status:Status
    var memberIcon:UIImage?
    var vipIcon:UIImage?
    // 转发文字
    var retweetedStr:String?
    // 评论文字
    var commentStr:String?
    // 点赞文字
    var likeStr:String?
    var sourceStr:String?
    // 配图视图大小
    var pictureViewSize = CGSize()
    var picURLs: [StatusPicture]? {
        return status.retweeted_status?.pic_urls ?? status.pic_urls
    }
    // 微博 属性文本
    var statusAttrText:NSAttributedString?
    // 被转发微博 属性文本
    var retweetedAttrText:NSAttributedString?
    
    /// 行高
    var rowHeight: CGFloat = 0
    
    init(status:Status) {
        self.status = status
        let mbrank = status.user?.mbrank ?? 1
        if mbrank > 0 && mbrank < 7{
            let imageName = "common_icon_membership_level\(mbrank)"
            memberIcon = UIImage(named: imageName)
        }
        // 设置认证图标
        switch status.user?.verified_type ?? -1 {
        case 0:
            vipIcon = UIImage(named: "avatar_vip")
        case 2, 3, 5:
            vipIcon = UIImage(named: "avatar_enterprise_vip")
        case 220:
            vipIcon = UIImage(named: "avatar_grassroot")
        default:
            break
        }
        //设置底部工具栏
        retweetedStr = countString(count: status.reposts_count, defaultStr: "转发")
        commentStr = countString(count: status.comments_count, defaultStr: "评论")
        likeStr = countString(count: status.attitudes_count, defaultStr: "赞")
        sourceStr = "来自 " + (status.source?.cz_href()?.text ?? "")
        
        // 计算配图大小 
        pictureViewSize = caclPictureViewSize(count: picURLs?.count ?? 0)
        
        // --- 设置微博文本 ---
        let originalFont = UIFont.systemFont(ofSize: 15)
        let retweetedFont = UIFont.systemFont(ofSize: 14)
        
        statusAttrText = EmoticonManager.shared.emoticonString(string: (status.text ?? ""), font: originalFont)
        let retweetedText = "@"+(status.retweeted_status?.user?.screen_name ?? "") + ":" + (status.retweeted_status?.text ?? "")
        retweetedAttrText = EmoticonManager.shared.emoticonString(string: retweetedText, font: retweetedFont)
    }
    
    func updateSingleImageSize(image: UIImage) {
        var size = image.size
        //过宽处理
        let maxWidth:CGFloat = 300
        if size.width > maxWidth {
            size.width = maxWidth
            size.height = image.size.height / image.size.width * size.width
        }
        //过窄处理
        let minWidth:CGFloat = 40
        if size.width < minWidth {
            size.width = minWidth
            size.height = image.size.height / image.size.width * size.width / 4
        }
        size.height += StatusPictureViewOutterMargin
        pictureViewSize = size
        //updateRowHeight()
    }
    
    /// 根据当前的视图模型内容计算行高
    /// 用在缓存行高， 不使用tableView的自适应行高，会提高滑动列表顺畅度
    func updateRowHeight() {
        // 原创微博：顶部分隔视图(12) + 间距(12) + 图像的高度(34) + 间距(12) + 正文高度(需要计算) + 配图视图高度(计算) + 间距(12) ＋ 底部视图高度(35)
        // 被转发微博：顶部分隔视图(12) + 间距(12) + 图像的高度(34) + 间距(12) + 正文高度(需要计算) + 间距(12)+间距(12)+转发文本高度(需要计算) + 配图视图高度(计算) + 间距(12) ＋ 底部视图高度(35)
        let margin: CGFloat = 12
        let iconHeight: CGFloat = 34
        let toolbarHeight: CGFloat = 35
        
        var height: CGFloat = 0
        
        let viewSize = CGSize(width: UIScreen.cz_screenWidth() - 2 * margin, height: CGFloat(MAXFLOAT))
        
        // 1. 计算顶部位置
        height = 2 * margin + iconHeight + margin
        
        // 2. 正文属性文本的高度
        if let text = statusAttrText {
            
            height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
        }
        
        // 3. 判断是否转发微博
        if status.retweeted_status != nil {
            
            height += 2 * margin
            
            // 转发文本的高度 - 一定用 retweetedText，拼接了 @用户名:微博文字
            if let text = retweetedAttrText {
                
                height += text.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], context: nil).height
            }
        }
        
        // 4. 配图视图
        height += pictureViewSize.height
        
        height += margin
        
        // 5. 底部工具栏
        height += toolbarHeight
        
        // 6. 使用属性记录
        rowHeight = height
    }
    
    
    func caclPictureViewSize(count: Int)->CGSize{
        if count == 0 {
            return CGSize()
        }
        
        let row = (count - 1) / 3 + 1
        // 配图的高度
        let height = StatusPictureViewOutterMargin + StatusPictureItemWidth * CGFloat(row) + StatusPictureViewInnerMargin * CGFloat(row - 1)
        
        return CGSize(width: StatusPictureViewWidth, height: height)
    }
    
    func countString(count:Int, defaultStr:String)->String{
        if count==0 {
            return defaultStr
        }
        if count<1000 {
            return count.description
        }
        return String(format: "%.02f 万", Double(count)/1000)
    }
    
    var description: String{
        return status.description
    }
}
