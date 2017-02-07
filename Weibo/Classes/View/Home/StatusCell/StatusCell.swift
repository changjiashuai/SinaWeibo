//
//  StatusCell.swift
//  Weibo
//
//  Created by CJS on 16/9/3.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

@objc protocol StatusCellDelegate: NSObjectProtocol {
    @objc optional func statusCellDidSelectedURLString(cell: StatusCell, urlString:String)
}

class StatusCell: UITableViewCell {
    
    weak var delegate: StatusCellDelegate?

    var viewModel: StatusViewModel?{
        didSet{
            statusLabel.attributedText = viewModel?.statusAttrText
            nameLabel.text = viewModel?.status.user?.screen_name
            memberIconView.image = viewModel?.memberIcon
            vipIconView.image = viewModel?.vipIcon
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"), isAvatar: true)
            toolBar.viewModel = viewModel
            pictureView.statusViewModel = viewModel
            pictureView.urls = viewModel?.picURLs
            retweetedLabel?.attributedText = viewModel?.retweetedAttrText
            sourceLabel.text = viewModel?.sourceStr
            timeLabel.text = viewModel?.status.createDate?.cz_dateDescription   
        }
    }
    // 头像
    @IBOutlet weak var iconView: UIImageView!
    // 姓名
    @IBOutlet weak var nameLabel: UILabel!
    // 会员图标
    @IBOutlet weak var memberIconView: UIImageView!
    
    // 时间
    @IBOutlet weak var timeLabel: UILabel!
    // 来源
    @IBOutlet weak var sourceLabel: UILabel!
    // 认证图标
    @IBOutlet weak var vipIconView: UIImageView!
    // 微博正文
    @IBOutlet weak var statusLabel: FFLabel!
    // 底部工具栏
    @IBOutlet weak var toolBar: StatusToolBar!
    
    @IBOutlet weak var pictureView: StatusPictureView!
    
    @IBOutlet weak var retweetedLabel: FFLabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // 离屏渲染
        self.layer.drawsAsynchronously = true
        // 栅格化
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        // 设置代理
        statusLabel.delegate = self
        retweetedLabel?.delegate = self
    }
}

extension StatusCell : FFLabelDelegate {
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        //
        if !text.hasPrefix("http://") {
            return
        }
        delegate?.statusCellDidSelectedURLString?(cell: self, urlString: text)
    }
}
