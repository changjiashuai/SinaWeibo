//
//  ComposeTextView.swift
//  Weibo
//
//  Created by CJS on 16/9/23.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class ComposeTextView: UITextView {

    private lazy var placeholder = UILabel()
    
    override func awakeFromNib() {
        setupUI()
    }
    
    func textChanged(){
        placeholder.isHidden = self.hasText
    }
    
    func setupUI(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        
        placeholder.font = self.font
        placeholder.text = "分享新鲜事..."
        placeholder.textColor = UIColor.lightGray
        placeholder.frame.origin = CGPoint(x: 5, y: 8)
        placeholder.sizeToFit()
        addSubview(placeholder)
    }
    
    
    func insertEmoticon(emoticon:Emoticon?){
        if emoticon == nil {
            deleteBackward()
        }else{
            if let emoji = emoticon?.emoji, let textRange = selectedTextRange {
                replace(textRange, withText: emoji)
            }else{
                let imageText = emoticon?.imageText(font: font!)
                let attrStrM = NSMutableAttributedString(attributedString: attributedText)
                let range = selectedRange
                attrStrM.replaceCharacters(in: range, with: imageText!)
                attributedText = attrStrM
                // 恢复光标位置
                selectedRange = NSRange(location: range.location+1, length: 0)
            }
            delegate?.textViewDidChange!(self)
            textChanged()
        }
    }
    
    func emoticonText() -> String{
        var result = String()
        guard let attrStr = attributedText else {
            return result
        }
        attrStr.enumerateAttributes(in: NSRange(location:0,length:attrStr.length), options: []) { (dict, range, _) in
            //
            if let attachment = dict["NSAttachment"] as? EmoticonTextAttachment{
                result += attachment.chs ?? ""
            }else{
                let subStr = (attrStr.string as NSString).substring(with: range)
                result += subStr
            }
        }
        return result
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
