//
//  StatusPictureView.swift
//  Weibo
//
//  Created by CJS on 16/9/4.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class StatusPictureView: UIView {
    
    var statusViewModel: StatusViewModel? {
        didSet{
            caclViewSize()
        }
    }
    
    func caclViewSize(){
        
        //单图
        if statusViewModel?.picURLs?.count == 1 {
            let viewSize = statusViewModel?.pictureViewSize ?? CGSize()
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: StatusPictureViewOutterMargin, width: viewSize.width, height: viewSize.height - StatusPictureViewOutterMargin)
        }else{
            //多图
            let v = subviews[0]
            v.frame = CGRect(x: 0, y: StatusPictureViewOutterMargin, width: StatusPictureItemWidth, height: StatusPictureItemWidth)
        }
        
        heightCons.constant = statusViewModel?.pictureViewSize.height ?? 0
    }
    
    var urls: [StatusPicture]?{
        didSet{
            for v in subviews{
                v.isHidden = true
            }
            
            var index = 0
            for url in urls ?? []{
                let iv = subviews[index] as! UIImageView
                if (index == 1 && urls?.count == 4) {
                    index += 1
                }
                iv.isHidden = false
                iv.cz_setImage(urlString: url.thumbnail_pic, placeholderImage: nil)
                // gif
                iv.subviews[0].isHidden = ((url.thumbnail_pic ?? "") as NSString).pathExtension.lowercased() != "gif"
                index += 1
            }
        }
    }

    @IBOutlet weak var heightCons: NSLayoutConstraint!
    
    override func awakeFromNib() {
        setupUI()
    }

    func setupUI(){
        backgroundColor = superview?.backgroundColor
        let rect = CGRect(x: 0, y: StatusPictureViewOutterMargin, width: StatusPictureItemWidth, height: StatusPictureItemWidth)
        for i in 0..<9{
            clipsToBounds = true
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            let row = CGFloat(i / 3) // Y
            let col = CGFloat(i % 3) // X
            let xOffset = col * (StatusPictureItemWidth + StatusPictureViewInnerMargin)
            let yOffset = row * (StatusPictureItemWidth + StatusPictureViewInnerMargin)
            iv.frame = rect.offsetBy(dx: xOffset, dy: yOffset)
            
            iv.tag = i
            iv.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
            iv.addGestureRecognizer(tap)
            addSubview(iv)
            addGifImage(iv: iv)
        }
    }
    
    func addGifImage(iv: UIImageView){
        let image = UIImage(named: "timeline_image_gif")
        let gifImageView = UIImageView(image: image)
        iv.addSubview(gifImageView)
        
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        iv.addConstraint(NSLayoutConstraint(item: gifImageView, attribute: .right, relatedBy: .equal, toItem: iv, attribute: .right, multiplier: 1.0, constant: 0))
        iv.addConstraint(NSLayoutConstraint(item: gifImageView, attribute: .bottom, relatedBy: .equal, toItem: iv, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    func tapImageView(tap: UITapGestureRecognizer){
        guard let iv = tap.view, let picURLs = statusViewModel?.picURLs else {
            return
        }
        
        var selectedIndex = iv.tag
        if  picURLs.count == 4 && selectedIndex > 1 {
            selectedIndex -= 1
        }
        
        let urls = (picURLs as NSArray).value(forKey: "largePic") as! [String]
        var imageViewList = [UIImageView]()
        for iv in subviews as! [UIImageView]{
            if !iv.isHidden {
                imageViewList.append(iv)
            }
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: StatusCellBrowerPhotoNotification),
            object: self,
            userInfo: [StatusCellBrowerPhotoURLsKey:urls,
                       StatusCellBrowerPhotoSelectedIndexKey:selectedIndex,
                       StatusCellBrowerPhotoImageViewsKey:imageViewList])
    }
}
