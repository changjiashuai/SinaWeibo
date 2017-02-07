//
//  NetworkManager+Extension.swift
//  Weibo
//
//  Created by CJS on 16/8/27.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation

// MARK - Weibo
extension NetworkManager{
    
    /// 微博列表
    func statusList(since_id: Int64 = 0, max_id: Int64 = 0, completion: @escaping (_ list:[[String:Any]]?, _ isSuccess:Bool)->()){
        //token 2.00Z5rG4DEPb98Ef384930381ewJpiD
        
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        let params = ["since_id": since_id, "max_id": max_id > 0 ? max_id-1 : 0]
      
        tokenRequest(urlString: urlString, parameters: params) { (json, isSuccess) in
            if json != nil {
                let dict = json as? [String:Any]
                let result = dict?["statuses"] as! [[String:Any]]
                completion(result, isSuccess)
            }
        }
    }
    
    func unreadCount(completion:@escaping (_ count:Int)->()){
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://rm.api.weibo.com/2/remind/unread_count.json"
        let params = ["uid":uid]
        
        tokenRequest(urlString: urlString, parameters: params) { (json, isSuccess) in
            //
            let dict = json as? [String:Any]
            let count = dict?["status"] as? Int
            completion(count ?? 0)
        }
    }
}

// MARK: - 发布微博
extension NetworkManager{
    func postStatus(text:String, image:UIImage? = nil, completion:@escaping (_ result:[String:Any]?, _ isSuccess:Bool)->()){
        
        var urlString:String?
        var name:String?
        var data:Data?
        
        if image == image {
            urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
            name = "pic"
            data = UIImagePNGRepresentation(image!)
        }else{
            urlString = "https://api.weibo.com/2/statuses/update.json"
        }
        let params = ["status":text]
        
        tokenRequest(method: .POST, urlString: urlString!, parameters: params, data: data, name: name, fileName: nil) { (json, isSuccess) in
            completion(json as? [String:Any], isSuccess)
        }
    }
}

// MARK - 用户信息
extension NetworkManager{
    func loadUserInfo(completion:@escaping (_ dict:[String:Any])->()){
        guard let uid = userAccount.uid else {
            return
        }
        let urlString = "https://api.weibo.com/2/users/show.json"
        let params = ["uid":uid]
        tokenRequest(urlString: urlString, parameters: params) { (json, isSuccess) in
            if json != nil {
                //print("UserInfo json = \(json)")
                
                print("\n---------------------")
                let dict = (json as? [String:Any]) ?? [:]
                completion(dict)
            }
        }
    }
}

// MARK - OAuth
extension NetworkManager{
 
    func loadAccessToken(code:String, completion:@escaping (_ isSuccess:Bool)->()){
        let urlString = "https://api.weibo.com/oauth2/access_token"
        let params = ["client_id":AppKey,
                      "client_secret":AppSecret,
                      "grant_type":"authorization_code",
                      "code":code,
                      "redirect_uri":RedirectURI]
        request(method: .POST, urlString: urlString, parameters: params) { (json, isSuccess) in
            //
            print("json=\(json)")
            self.userAccount.yy_modelSet(with: (json as? [String:Any]) ?? [:])
            self.loadUserInfo(completion: { (dict) in
                //
                //print("dict = \(dict)")
                self.userAccount.yy_modelSet(with: dict)
                self.userAccount.saveAccount()
                print("\n userAccount screen_name = \(self.userAccount.screen_name)")
                print("\n userAccount avatar_large = \(self.userAccount.avatar_large)")
                completion(isSuccess)
            })
        }
    }
}
