//
//  SQLiteManager.swift
//  Weibo
//
//  Created by CJS on 16/9/27.
//  Copyright © 2016年 CJS. All rights reserved.
//

import Foundation
import FMDB

private let maxDBCacheTime: TimeInterval = -5 * 24 * 60 * 60

class SQLiteManager{
    
    static let shared = SQLiteManager()
    let queue: FMDatabaseQueue
    
    private init() {
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName)
        print("db path=" + path)
        queue = FMDatabaseQueue(path: path)
        
        createTable()
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearDBCache), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clearDBCache(){
        let dateString = Date.cz_dateString(delta: maxDBCacheTime)
        let sql = "DELETE FROM T_Status WHERE createTime < ?;"
        queue.inDatabase { (db) in
            if db?.executeUpdate(sql, withArgumentsIn: [dateString]) == true{
                print("删除了 \(db?.changes()) 条记录")
            }
        }
    }
}

extension SQLiteManager{
    
    
    func updateStatus(userId: String, array: [[String:Any]]){
        let sql = "INSERT OR REPLACE INTO T_STATUS (statusId, userId, status) VALUES (?,?,?);"
        queue.inTransaction { (db, roolback) in
            for dict in array {
                guard let statusId = dict["idstr"] as? String,
                let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                    else{
                        continue
                }
                if db?.executeUpdate(sql, withArgumentsIn: [statusId, userId, jsonData]) == false {
                    roolback?.pointee = true
                    break
                }
            }
        }
    }
    
    /// 从数据库加载微博数据数组
    ///
    /// - parameter userId:   当前登录的用户账户
    /// - parameter since_id: 返回ID比since_id大的微博
    /// - parameter max_id:   返回ID小于max_id的微博
    ///
    /// - returns: 微博的字典数组，将数据库中status字段对应的二进制数据反序列化，生成字典
    func loadStatus(userId: String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String:Any]]{
        var sql = "SELECT statusId, userId, status FROM T_STATUS \n"
        sql += "WHERE userId = \(userId) \n"
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        }else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC LIMIT 20;"
        
        let array = execRecordSet(sql: sql)
        var result = [[String:Any]]()
        for dict in array{
            guard let jsonData = dict["status"] as? Data,
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] else {
                continue
            }
            result.append(json ?? [:])
        }
        return result
    }
    
    func execRecordSet(sql: String) -> [[String:Any]]{
        var result = [[String:Any]]()
        queue.inDatabase { (db) in
            guard let rs = db?.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            while rs.next(){
                let colCount = rs.columnCount()
                for col in 0..<colCount{
                    guard let name = rs.columnName(for: col),
                        let value = rs.object(forColumnIndex: col) else {
                            continue
                    }
                    result.append([name:value])
                }
            }
        }
        return result
    }
}

// MARK: - Create Table
private extension SQLiteManager{
    
    func createTable(){
        guard let path = Bundle.main.path(forResource: "status.sql", ofType: nil),
            let sql = try? String(contentsOfFile: path) else {
                return
        }
        queue.inDatabase { (db) in
            if db?.executeStatements(sql) == true{
                print("Create Table Successful")
            }else{
                print("Create Table Failed")
            }
        }
    }
}
