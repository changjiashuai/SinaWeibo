//
//  EmoticonCell.swift
//  Weibo
//
//  Created by CJS on 16/9/25.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

protocol EmoticonCellDelegate:NSObjectProtocol {
    func emoticonCellSelectedEmoticon(cell: EmoticonCell, emoticon:Emoticon?)
}

class EmoticonCell: UICollectionViewCell {
    
    weak var delegate: EmoticonCellDelegate?
    private lazy var tipView = EmoticonTipView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var emoticons:[Emoticon]?{
        didSet{
            for v in contentView.subviews {
                v.isHidden = true
            }
            contentView.subviews.last?.isHidden = false
            for (i, em) in (emoticons ?? []).enumerated() {
                if let btn = contentView.subviews[i] as? UIButton {
                    btn.setImage(em.image, for: [])
                    btn.setTitle(em.emoji, for: [])
                    btn.isHidden = false
                }
            }
        }
    }
    
    @objc func selectedEmoticonButton(btn:UIButton){
        let tag = btn.tag
        var emoticon: Emoticon?
        if tag < (emoticons?.count)! {
            emoticon = emoticons?[tag]
        }
        delegate?.emoticonCellSelectedEmoticon(cell: self, emoticon: emoticon)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let v = newWindow {
            v.addSubview(tipView)
            tipView.isHidden = true
        }
    }
    
    func setupUI(){
        let rowCount = 3
        let colCount = 7
        let leftMargin:CGFloat = 8
        let bottomMargin:CGFloat = 16
        let w = Int(bounds.width - 2*leftMargin)/colCount
        let h = Int(bounds.height - bottomMargin)/rowCount
        
        for i in 0..<21 {
            let row = i / Int(colCount)
            let col = i % Int(colCount)
            let x = Int(leftMargin) + col * w
            let y = row * h
            let btn = UIButton()
            btn.frame = CGRect(x: x, y: y, width: w, height: h)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
            btn.tag = i
            btn.addTarget(self, action: #selector(selectedEmoticonButton), for: .touchUpInside)
            contentView.addSubview(btn)
        }
        let deleteButton = contentView.subviews.last as? UIButton
        let image = UIImage(named: "compose_emotion_delete", in: EmoticonManager.shared.bundle, compatibleWith: nil)
        let imageHL = UIImage(named: "compose_emotion_delete_highlighted", in: EmoticonManager.shared.bundle, compatibleWith: nil)
        deleteButton?.setImage(image, for: [])
        deleteButton?.setImage(imageHL, for: .highlighted)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGesture))
        longPress.minimumPressDuration = 0.1
        addGestureRecognizer(longPress)
    }
    
    func longGesture(gesture: UILongPressGestureRecognizer){
        let location = gesture.location(in: self)
        guard let button = buttonWithLocation(location: location) else {
            tipView.isHidden = true
            return
        }
        switch gesture.state {
        case .began, .changed:
            tipView.isHidden = false
            let center = self.convert(button.center, to: window)
            tipView.center = center
            if button.tag < (emoticons?.count)! {
                tipView.emoticon = emoticons?[button.tag]
            }
        case .ended:
            tipView.isHidden = true
            selectedEmoticonButton(btn: button)
        case .cancelled, .failed:
            tipView.isHidden = true
        default:
            break
        }
    }
    
    func buttonWithLocation(location: CGPoint) -> UIButton?{
        for btn in contentView.subviews as! [UIButton] {
            if btn.frame.contains(location) && !btn.isHidden && btn != contentView.subviews.last {
                return btn
            }
        }
        return nil
    }
}
