//
//  Common.swift
//  Weibo
//
//  Created by CJS on 16/8/29.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation

// App 信息
let AppKey = "4070308746"
let AppSecret = "5d69576c5da64f8da29dee228f64accc"
let RedirectURI = "http://baidu.com"

//用户登录通知
let UserShouldLoginNotification =  "UserShouldLoginNotification"

//登录成功通知
let UserLoginSuccessNotification = "UserLoginSuccessNotification"

// 微博配图
let StatusPictureViewOutterMargin:CGFloat = 12
let StatusPictureViewInnerMargin:CGFloat = 3
// 配图宽度
let StatusPictureViewWidth = UIScreen.cz_screenWidth() - 2 * StatusPictureViewOutterMargin
// 每个图片的宽度
let StatusPictureItemWidth = (StatusPictureViewWidth - 2 * StatusPictureViewInnerMargin)/3

let StatusCellBrowerPhotoNotification = "StatusCellBrowerPhotoNotification"
let StatusCellBrowerPhotoURLsKey = "StatusCellBrowerPhotoURLsKey"
let StatusCellBrowerPhotoSelectedIndexKey = "StatusCellBrowerPhotoSelectedIndexKey"
let StatusCellBrowerPhotoImageViewsKey = "StatusCellBrowerPhotoImageViewsKey"
