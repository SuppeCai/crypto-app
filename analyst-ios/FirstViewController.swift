//
//  FirstViewController.swift
//  analyst-ios
//
//  Created by 蔡苏鹏 on 16/07/2018.
//  Copyright © 2018 蔡苏鹏. All rights reserved.
//

import UIKit
import FoldingCell
import Alamofire

class FirstViewController: UITableViewController{
    
    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
        static let rowsCount = 10
    }
    
    var cellHeights: [CGFloat] = []
    
    var exchangeDict:[Int64:Exchange] = [:]
    var assetDict:[Int64:Asset] = [:]
    var assetPairDict:[Int64:AssetPair] = [:]
    var periodDict:[Int64:Period] = [:]
    var strategyDict:[Int64:Strategy] = [:]
    var noticeInfoDict:[Int64:NoticeInfo] = [:]
    var infoDict:[Int64:NoticeInfo] = [:]
    var dformatter = DateFormatter()
    
    var result:[(key: Int64, value: NoticeInfo)]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dformatter.dateFormat = "HH:mm"
        loadData()
        Thread.sleep(forTimeInterval: 0.2)
        
        refreshNotice()
        
        setup()
    }
    
    private func setup() {
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        //        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        Alamofire.request(Constants.domain+"exchange").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                let exchanges = try! decoder.decode([Exchange].self, from: response.data!)
                for exchange in exchanges{
                    self.exchangeDict.updateValue(exchange, forKey: exchange.id)
                }
            case false:
                print(response.result.error!)
            }
        }
        
        Alamofire.request(Constants.domain+"asset").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                let assets = try! decoder.decode([Asset].self, from: response.data!)
                for asset in assets{
                    self.assetDict.updateValue(asset, forKey: asset.id)
                }
            case false:
                print(response.result.error!)
            }
        }
        
        Alamofire.request(Constants.domain+"asset/pair").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                let assetPairs = try! decoder.decode([AssetPair].self, from: response.data!)
                for assetPair in assetPairs{
                    self.assetPairDict.updateValue(assetPair, forKey: assetPair.id)
                }
            case false:
                print(response.result.error!)
            }
        }
        
        Alamofire.request(Constants.domain+"period").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                let periods = try! decoder.decode([Period].self, from: response.data!)
                for period in periods{
                    self.periodDict.updateValue(period, forKey: period.id)
                }
            case false:
                print(response.result.error!)
            }
        }
        
        Alamofire.request(Constants.domain+"strategy").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                let decoder = JSONDecoder()
                let strategies = try! decoder.decode([Strategy].self, from: response.data!)
                for strategy in strategies{
                    self.strategyDict.updateValue(strategy, forKey: strategy.id)
                }
            case false:
                print(response.result.error!)
            }
        }
    }
    
    private func refreshNotice() {
        
        if(exchangeDict.isEmpty || assetDict.isEmpty || assetPairDict.isEmpty || !strategyDict.isEmpty || !noticeInfoDict.isEmpty){
            print("Initializing metadata...")
            return
        }
        
        Alamofire.request(Constants.domain+"notice").responseJSON { response in
            switch response.result.isSuccess {
            case true:
                self.noticeInfoDict.removeAll()
                let decoder = JSONDecoder()
                let notices = try! decoder.decode([Notice].self, from: response.data!)
                for notice in notices {
                    let assetPair=self.assetPairDict[notice.assetPairId]
                    let base=self.assetDict[(assetPair?.baseId)!]
                    let quote=self.assetDict[(assetPair?.quoteId)!]
                    let baseCode=base?.code.uppercased()
                    let quoteCode=quote?.code.uppercased()
                    let title=baseCode!+"/"+quoteCode!
                    let period=self.periodDict[notice.periodId]
                    
                    var periodStr="UNKNOW"
                    if(period?.unit==2&&period?.unitNum==1){
                        periodStr="1HOUR"
                    }else if(period?.unit==2&&period?.unitNum==4){
                        periodStr="4HOUR"
                    }else if(period?.unit==3&&period?.unitNum==1){
                        periodStr="1DAY"
                    }
                    
                    var noticeInfo:NoticeInfo
                    if self.noticeInfoDict.keys.contains(notice.assetPairId){
                        noticeInfo=self.noticeInfoDict[notice.assetPairId]!
                    }else{
                        noticeInfo=NoticeInfo(assetPairId: notice.assetPairId, base:baseCode! , quote:quoteCode! , title: title, latestTime: "", latestDescription: "", noticeNum: 0, weight: 0, noticeDict:[:])
                    }
                    
                    var periodNotices:[Notice]
                    if noticeInfo.noticeDict.keys.contains(periodStr){
                        periodNotices=noticeInfo.noticeDict[periodStr]!
                    }else{
                        periodNotices=[]
                    }
                    
                    periodNotices.append(notice)
                    noticeInfo.noticeDict.updateValue(periodNotices, forKey: periodStr)
                    self.noticeInfoDict.updateValue(noticeInfo, forKey: notice.assetPairId)
                }
                
                for infoKey in self.noticeInfoDict.keys{
                    var info=self.noticeInfoDict[infoKey]
                    var latestTime:Int64=0
                    var latestDescription=""
                    var noticeNum=0
                    var weight:Double=0
                    
                    for subNotices in info!.noticeDict.values{
                        for n in subNotices{
                            let strategy=self.strategyDict[n.strategyId]
                            let period=self.periodDict[n.periodId]
                            
                            if(n.notifyAt>latestTime){
                                latestTime=n.notifyAt
                                latestDescription=(strategy?.name)!
                            }
                            noticeNum=noticeNum+1
                            var factor:Double=1
                            if(period?.unit==2){
                                factor=0.5
                            }
                            if(period?.unit==1){
                                factor=0.1
                            }
                            weight+=Double((strategy?.weight)!)*factor
                        }
                    }
                    
                    info!.latestDescription=latestDescription
                    let timeInterval:TimeInterval = TimeInterval(latestTime/1000)
                    let date = Date(timeIntervalSince1970: timeInterval)
                    info!.latestTime=self.dformatter.string(from: date)
                    info!.noticeNum=noticeNum
                    info!.weight=Int(weight)
                    self.noticeInfoDict.updateValue(info!, forKey: infoKey)
                    self.cellHeights = Array(repeating: Const.closeCellHeight, count: self.noticeInfoDict.count)
                }
                
                self.result = self.noticeInfoDict.sorted { (n1, n2) -> Bool in
                    if(n1.value.assetPairId==1||n2.value.assetPairId==1){
                        return n1.value.assetPairId==1
                    }
                    
                    if(n1.value.weight==n2.value.weight){
                        if(n1.value.noticeNum==n2.value.noticeNum){
                            return n1.value.assetPairId<n2.value.assetPairId
                        }else{
                            return n1.value.noticeNum>n2.value.noticeNum
                        }
                    }else{
                        return n1.value.weight>n2.value.weight
                    }
                }
                self.tableView.reloadData()
            case false:
                print(response.result.error!)
            }
        }
    }
    
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            self?.refreshNotice()
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
        })
    }
}

extension FirstViewController {
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.noticeInfoDict.count
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as NoticeCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
//        print("#########")
//        print("row:")
//        print(indexPath.row)
        cell.baseAssetLabel.text=result[indexPath.row].value.base
        cell.quoteAssetLable.text=result[indexPath.row].value.quote
        cell.timeLable.text=result[indexPath.row].value.latestTime
        cell.latestDescriptionLable.text=result[indexPath.row].value.latestDescription
        cell.noticeNumLable.text=String(result[indexPath.row].value.noticeNum)
        cell.weightLable.text=String(result[indexPath.row].value.weight)
        
//        print("base:")
//        print(result[indexPath.row].value.base)
        cell.assetPairLabel.text=result[indexPath.row].value.title
        cell.noticeDict=result[indexPath.row].value.noticeDict
        cell.assetPairId=result[indexPath.row].value.assetPairId
//        print("noticeDict:")
//        print(cell.noticeDict)
//        print("#########")
        cell.viewLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: false, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: false, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
}




