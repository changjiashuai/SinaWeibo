//
//  NetworkManager.swift
//  Weibo
//
//  Created by CJS on 16/8/27.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit
import AFNetworking

enum HTTPMethod {
    case GET
    case POST
}

class NetworkManager: AFHTTPSessionManager {
    static let shared:NetworkManager = {
        let instance = NetworkManager()
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return instance
    }()
    
    lazy var userAccount = UserAccount()
    
    var userLogon:Bool{
        return userAccount.access_token != nil
    }
    
    func tokenRequest(method: HTTPMethod = .GET, urlString:String, parameters:[String:Any]?, data:Data? = nil, name:String? = nil, fileName:String? = nil, completion:@escaping (_ json:Any?, _ isSuccess:Bool)->()){
        
        guard let token = userAccount.access_token else {
            // 发送通知， 提示用户登录
            print("没有token, 需要登录")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserShouldLoginNotification), object: nil)
            completion(nil, false)
            return
        }
        
        var parameters = parameters;
        if parameters == nil {
            parameters = [String:Any]()
        }
        parameters!["access_token"]=token
        
        if data != nil {
            upload(urlString: urlString, parameters: parameters, data: data!, name: name!, fileName: fileName ?? "test", completion: completion)
        }else{
            request(method: method, urlString: urlString, parameters: parameters, completion: completion)
        }
        
    }
    
    func upload(urlString:String, parameters:[String:Any]?, data:Data, name:String, fileName:String, completion:@escaping (_ json:Any?, _ isSuccess:Bool)->()){
        post(urlString, parameters: parameters, constructingBodyWith: { (formData) in
            //
            formData.appendPart(withFileData: data, name: name, fileName: fileName, mimeType: "application/octect-stream")
            }, progress: nil, success: { (task:URLSessionDataTask, json:Any?) in
                //
                completion(json, true)
        }) { (task:URLSessionDataTask?, error:Error) in
                //
            if (task?.response as? HTTPURLResponse)?.statusCode==403 {
                // 发送通知，重新登录
                print("token 过期了")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserShouldLoginNotification), object: "bad token")
            }
            print("请求错误 \(error)")
            completion(nil, false)
        }
    }
    
    func request(method: HTTPMethod = .GET, urlString:String, parameters:[String:Any]?, completion:@escaping (_ json:Any?, _ isSuccess:Bool)->()){
        
        let success = {(task:URLSessionDataTask, json:Any?)->() in
            completion(json, true)
        }
        
        let failure = {(task:URLSessionDataTask?, error:Error)->() in
            // 403 token 过期
            if (task?.response as? HTTPURLResponse)?.statusCode==403 {
                // 发送通知，重新登录
                print("token 过期了")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserShouldLoginNotification), object: "bad token")
            }
            print("请求错误 \(error)")
            completion(nil, false)
        }
        
        if method == .GET {
            get(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }else{
            post(urlString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
