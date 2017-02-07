//
//  MeituanRefreshView.swift
//  Weibo
//
//  Created by CJS on 16/9/13.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class MeituanRefreshView: RefreshView {

    @IBOutlet weak var buildIconView: UIImageView!
   
    @IBOutlet weak var earthIconView: UIImageView!
    @IBOutlet weak var kangarooIconView: UIImageView!
    
    override var parentHeight: CGFloat{
        didSet{
            if parentHeight<18 {
                return
            }
            var scale:CGFloat
            if parentHeight>126 {
                scale = 1
            }else{
                scale = 1-(126-parentHeight) / (126-18)
            }
            kangarooIconView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    override func awakeFromNib() {
        let bgImage1 = #imageLiteral(resourceName: "icon_building_loading_1")
        let bgImage2 = #imageLiteral(resourceName: "icon_building_loading_2")
        buildIconView.image = UIImage.animatedImage(with: [bgImage1, bgImage2], duration: 0.5)
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = -2*M_PI
        anim.duration = 2
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        earthIconView.layer.add(anim, forKey: nil)
        
        
        let kImage1 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_1")
        let kImage2 = #imageLiteral(resourceName: "icon_small_kangaroo_loading_2")
        kangarooIconView.image = UIImage.animatedImage(with: [kImage1, kImage2], duration: 0.5)
        
        kangarooIconView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        let x = self.bounds.width * 0.5
        let y = self.bounds.height - 18
        kangarooIconView.center = CGPoint(x: x, y: y)
        kangarooIconView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
    }
}
