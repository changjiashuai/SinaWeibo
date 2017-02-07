//
//  RefreshControl.swift
//  Weibo
//
//  Created by CJS on 16/9/9.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

enum RefreshState {
    case Normal
    case Pulling
    case WillRefresh
}

class RefreshControl: UIControl {
    private let refreshOffset:CGFloat = 126
    weak var scrollView:UIScrollView?
    lazy var refreshView = RefreshView.refreshView()
    
    init() {
        super.init(frame: CGRect())
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setupUI(){
        backgroundColor = superview?.backgroundColor
        //clipsToBounds = true
        addSubview(refreshView)
        
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .centerX,
                                         multiplier: 1.0,
                                         constant: 0))
            
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.width))
        
        addConstraint(NSLayoutConstraint(item: refreshView,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .notAnAttribute,
                                         multiplier: 1.0,
                                         constant: refreshView.bounds.height))
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        guard let sv = newSuperview as? UIScrollView else {
            return
        }
        scrollView = sv
        // KVO 监听父视图的 contentOffset
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [], context: nil)
    }
    
    override func removeFromSuperview() {
        // 移除KVO， 监听后不移除会崩溃
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        super.removeFromSuperview()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let sv = scrollView else {
            return
        }
        let height = -(sv.contentInset.top + sv.contentOffset.y)
        if refreshView.refreshState != .WillRefresh {
            refreshView.parentHeight = height
        }
        
        if height < 0 {
            return
        }
        
        if sv.isDragging {
            if height > refreshOffset && refreshView.refreshState == .Normal {
                print("放手开始刷新")
                refreshView.refreshState = .Pulling
            }else if height <= refreshOffset && refreshView.refreshState == .Pulling{
            print("继续往下拉")
            refreshView.refreshState = .Normal
            }
        }else if refreshView.refreshState == .Pulling {
            print("开始刷新")
            beginRefreshing()
            sendActions(for: .valueChanged)
        }
        self.frame = CGRect(x: 0, y: -height, width: sv.bounds.width, height: height)
    }
    
    func beginRefreshing(){
        guard let sv = scrollView else {
            return
        }
        
        if refreshView.refreshState == .WillRefresh {
            return
        }
        
        refreshView.refreshState = .WillRefresh
        var inset = sv.contentInset
        inset.top += refreshOffset
        sv.contentInset = inset
        refreshView.parentHeight = refreshOffset
    }
    
    func endRefreshing(){
        guard let sv = scrollView else {
            return
        }
        if refreshView.refreshState != .WillRefresh {
            return
        }
        refreshView.refreshState = .Normal
        var inset = sv.contentInset
        inset.top -= refreshOffset
        sv.contentInset = inset
    }

}
