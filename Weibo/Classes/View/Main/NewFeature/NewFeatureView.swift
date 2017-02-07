//
//  NewFeatureView.swift
//  Weibo
//
//  Created by CJS on 16/9/2.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class NewFeatureView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func enterStatus() {
        removeFromSuperview()
    }
    
    class func newFeatureView() -> NewFeatureView {
        let v = UINib(nibName: "NewFeatureView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NewFeatureView
        v.frame = UIScreen.main.bounds
        return v
    }
    
    override func awakeFromNib() {
        let count = 4
        let rect = UIScreen.main.bounds
        for i in 0..<count {
            let iv = UIImageView(image: UIImage(named: "new_feature_\(i+1)"))
            iv.frame = rect.offsetBy(dx: CGFloat(i) * rect.width, dy: 0)
            scrollView.addSubview(iv)
        }
        scrollView.contentSize = CGSize(width: CGFloat(count + 1) * rect.width, height: rect.height)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        enterButton.isHidden = true
    }
}

extension NewFeatureView:UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if page == scrollView.subviews.count {
            removeFromSuperview()
        }
        enterButton.isHidden = (page != scrollView.subviews.count-1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        enterButton.isHidden = true
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        pageControl.currentPage = page
        pageControl.isHidden = (page == scrollView.subviews.count)
    }
}
