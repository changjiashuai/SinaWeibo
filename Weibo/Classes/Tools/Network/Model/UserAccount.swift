//
//  UserAccount.swift
//  Weibo
//
//  Created by CJS on 16/8/30.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
private let accountFile:NSString = "useraccount.json"
class UserAccount: NSObject {
    //用户授权的唯一票据
    var access_token:String?
    //access_token的生命周期
    var expires_in:TimeInterval = 0.0{
        didSet{
            expiresDate = Date(timeIntervalSinceNow: expires_in)
        }
    }
    var expiresDate:Date?
    //授权用户的UID
    var uid:String?
    
    //用户昵称
    var screen_name:String?
    //用户头像地址（大图），180×180像素
    var avatar_large:String?
    
    override var description: String{
        return yy_modelDescription()
    }
    
    override init() {
        super.init()
        guard let path = accountFile.cz_appendDocumentDir(),
            let data = NSData(contentsOfFile: path),
            let dict = try? JSONSerialization.jsonObject(with: data as Data, options: []) else {
                return
        }
        yy_modelSet(withJSON: dict)
        
        //模拟过期
        //expiresDate = Date(timeIntervalSinceNow: -3600 * 24 * 365 * 10)
        print(expiresDate)
        
        if expiresDate?.compare(Date()) != .orderedDescending {
            // 过期
            access_token = nil
            uid = nil
            try? FileManager.default.removeItem(atPath: path)
        }
    }
    
    func saveAccount(){
        var dict = self.yy_modelToJSONObject() as? [String:Any] ?? [:]
        _ = dict.removeValue(forKey: "expires_in")
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            let filePath = accountFile.cz_appendDocumentDir() else{
            return
        }
        (data as NSData).write(toFile: filePath, atomically: true)
        print("filePath = \(filePath)")
    }
}
