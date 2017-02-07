//
//  ToolBar.swift
//  Weibo
//
//  Created by CJS on 16/9/3.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class StatusToolBar: UIView {
    
    var viewModel: StatusViewModel?{
        didSet{
            retweetedButton.setTitle(viewModel?.retweetedStr, for: [])
            commentButton.setTitle(viewModel?.commentStr, for: [])
            likeButton.setTitle(viewModel?.likeStr, for: [])
        }
    }

    @IBOutlet weak var retweetedButton:UIButton!
    @IBOutlet weak var commentButton:UIButton!
    @IBOutlet weak var likeButton:UIButton!

}
