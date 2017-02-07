//
//  UIImageView+WebImage.swift
//  Weibo
//
//  Created by CJS on 16/9/3.
//  Copyright © 2016年 CJS. All rights reserved.
//

import SDWebImage

extension UIImageView{
    func cz_setImage(urlString:String?, placeholderImage:UIImage?, isAvatar:Bool=false){
        guard let urlString = urlString, let url = URL(string:urlString) else {
            image = placeholderImage
            return
        }
        sd_setImage(with: url, placeholderImage: placeholderImage, options: [], progress: nil) { [weak self] (image, _, _, _) in
            if isAvatar {
                self?.image = image?.cz_avatarImage(size: self?.bounds.size)
            }
        }
    }
}
