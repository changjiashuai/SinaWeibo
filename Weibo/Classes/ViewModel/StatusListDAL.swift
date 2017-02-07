//
//  StatusListDAL.swift
//  Weibo
//
//  Created by CJS on 16/10/5.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation

class StatusListDAL {
    class func loadStatus(since_id: Int64 = 0, max_id: Int64 = 0, completion:@escaping (_ list:[[String:Any]]?, _ isSuccess:Bool) -> ()){
        guard let userId = NetworkManager.shared.userAccount.uid else {
            return
        }
        let array = SQLiteManager.shared.loadStatus(userId: userId, since_id: since_id, max_id: max_id)
        if array.count > 0 {
            completion(array, true)
            return
        }
        NetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (list, isSuccess) in
            if !isSuccess {
                completion(nil, false)
                return
            }
            guard let list = list else {
                completion(nil, isSuccess)
                return
            }
            SQLiteManager.shared.updateStatus(userId: userId, array: list)
            completion(list, isSuccess)
        }
    }
}
