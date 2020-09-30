//
//  Model.swift
//  analyst-ios
//
//  Created by 蔡苏鹏 on 2018/11/19.
//  Copyright © 2018 蔡苏鹏. All rights reserved.
//

import Foundation

struct Constants {
//    static let domain = "http://192.168.10.130:8080/"
    static let domain = "http://www.Bl0ckchain.me/"
}

struct Exchange :Codable{
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var name:String
    var code:String
    var domain:String
}

struct Asset :Codable{
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var name:String
    var code:String
}

struct AssetPair :Codable{
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var baseId:Int64
    var quoteId:Int64
}

struct Period :Codable{
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var unit:Int
    var unitNum:Int
}

struct Strategy :Codable{
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var name:String
    var weight:Int
}

struct Notice: Codable {
    var id:Int64
    var createAt:Int64
    var updateAt:Int64
    var status:Int
    var exchangeId:Int64
    var assetPairId:Int64
    var periodId:Int64
    var strategyId:Int64
    var description:String
    var notifyAt:Int64
}

struct NoticeInfo {
    var assetPairId:Int64
    var base:String
    var quote:String
    var title:String
    var latestTime:String
    var latestDescription:String
    var noticeNum:Int
    var weight:Int
    var noticeDict:[String:[Notice]]
}
