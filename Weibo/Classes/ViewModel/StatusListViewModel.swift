//
//  StatusListViewModel.swift
//  Weibo
//
//  Created by CJS on 16/8/28.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation
import SDWebImage

private let maxPullupTryTimes = 3;

class StatusListViewModel {
    
    lazy var statusList = [StatusViewModel]()
    var pullUpErrorTimes = 0
    
    func loadStatus(isPullUp: Bool, completion:@escaping (_ isSuccess:Bool, _ shouldRefresh:Bool)->()) {
        
        if isPullUp && (pullUpErrorTimes > maxPullupTryTimes) {
            completion(true, false)
            return
        }
        //下拉刷新
        let since_id = isPullUp ? 0 : (statusList.first?.status.id ?? 0)
        //上拉刷新
        let max_id = isPullUp ? (statusList.last?.status.id ?? 0) : 0
        
        StatusListDAL.loadStatus(since_id: since_id, max_id: max_id) { (json, isSuccess) in
//            
//        }
//        
//        NetworkManager.shared.statusList(since_id: since_id, max_id: max_id) { (json, isSuccess) in
//            
            if !isSuccess {
                completion(false, false)
                return
            }
            
            var array = [StatusViewModel]()
            
            for dict in json ?? [] {
                /*
                guard let status = Status.yy_model(with: dict) else {
                    continue
                }*/
                let status = Status()
                status.yy_modelSet(with: dict)
                array.append(StatusViewModel(status: status))
            }
            
            /*
            guard let array = NSArray.yy_modelArray(with: Status.self, json: json) as? [Status]
                else {
                completion(isSuccess, false)
                return
            }*/
            print("刷新到 \(array.count) 条数据")
            
            if isPullUp {
                // 上拉加载
                self.statusList += array
            }else{
                //下拉刷新
                self.statusList = array + self.statusList;
            }
            if isPullUp && array.count == 0{
                self.pullUpErrorTimes += 1
                completion(isSuccess, false)
            }else{
                self.cacheSingleImage(list: array, completion: completion)
                //completion(isSuccess, true)
            }
        }
    }
    
    func cacheSingleImage(list:[StatusViewModel], completion:@escaping (_ isSuccess:Bool, _ shouldRefresh:Bool)->()){
        
        // 调度组
        let group = DispatchGroup()
        var length = 0
        
        for statusView in list {
            if statusView.picURLs?.count != 1 {
                continue
            }
            
            guard let pic = statusView.picURLs?[0].thumbnail_pic,
                let url = URL(string: pic) else {
                continue
            }
            
            group.enter()
            SDWebImageManager.shared().downloadImage(with: url, options: [], progress: nil, completed: { (image, _, _, _, _) in
                //
                if let image = image, let data = UIImagePNGRepresentation(image){
                    length += data.count
                    statusView.updateSingleImageSize(image: image)
                }
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) { 
            //
            completion(true, true)
        }
    }
}
