//
//  NoticeCell.swift
//  analyst-ios
//
//  Created by 蔡苏鹏 on 2018/11/19.
//  Copyright © 2018 蔡苏鹏. All rights reserved.
//

import FoldingCell
import UIKit
import LTScrollView

class NoticeCell: FoldingCell {
    
    @IBOutlet var baseAssetLabel: UILabel!
    @IBOutlet var quoteAssetLable: UILabel!
    @IBOutlet var latestDescriptionLable: UILabel!
    @IBOutlet var noticeNumLable: UILabel!
    @IBOutlet var weightLable: UILabel!
    @IBOutlet var assetPairLabel: UILabel!
    @IBOutlet var timeLable: UILabel!
    @IBOutlet var periodLabel: UILabel!
    @IBOutlet var backButton: UIView!
    @IBOutlet var view: UIView!
    
    var assetPairId:Int64=0
    var noticeDict:[String:[Notice]] = [:]
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    private lazy var viewControllers: [UIViewController] = {
        let oneVc = NoticeViewController()
        let twoVc = NoticeViewController()
        let threeVc = NoticeViewController()
        oneVc.assetPairId=assetPairId
        twoVc.assetPairId=assetPairId
        threeVc.assetPairId=assetPairId
        if(noticeDict.keys.contains("1DAY")){
            oneVc.notices=noticeDict["1DAY"]!
        }
        if(noticeDict.keys.contains("4HOUR")){
            twoVc.notices=noticeDict["4HOUR"]!
        }
        if(noticeDict.keys.contains("1HOUR")){
            threeVc.notices=noticeDict["1HOUR"]!
        }
        return [oneVc, twoVc, threeVc]
    }()
    
    private lazy var titles: [String] = {
        return ["1DAY", "4HOUR", "1HOUR"]
    }()
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.sliderWidth = 100
        layout.titleMargin = 10.0
        // （屏幕宽度 - 标题总宽度 - 标题间距宽度） / 2 = 最左边以及最右边剩余
        let lrMargin = (view.bounds.width - (CGFloat(titles.count) * layout.sliderWidth + CGFloat(titles.count - 1) * layout.titleMargin)) * 0.5
        layout.lrMargin = lrMargin
        layout.isAverage = true
        layout.sliderHeight=0
        return layout
    }()
    
    private lazy var pageView: LTPageView = {
        let statusBarH = UIApplication.shared.statusBarFrame.size.height
        let Y: CGFloat = 0
        let H: CGFloat = view.bounds.height
        let pageView = LTPageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: H+10), currentViewController: self.parentViewController()!, viewControllers: viewControllers, titles: titles, layout: layout)
        pageView.isClickScrollAnimation = true
        return pageView
    }()
    
    func parentViewController() -> UIViewController? {
        var n = self.next
        while n != nil {
            if (n is UIViewController) {
                return n as? UIViewController
            }
            n = n?.next
        }
        return nil
    }

    func viewLoad() {
        self.periodLabel.text = self.titles[0]
        view.backgroundColor = UIColor.white
        view.addSubview(pageView)
        //        simpleManagerConfig()
        
        pageView.didSelectIndexBlock = {(_, index) in
            print("pageView.didSelectIndexBlock", index)
            self.periodLabel.text = self.titles[index]
        }
    }
    
    @IBAction func doBack(_ sender: Any) {
//        cellHeights[indexPath.row] = Const.closeCellHeight
        self.unfold(false, animated: false, completion: nil)
//        duration = 0.8
    }
}

// MARK: - Actions ⚡️

extension NoticeCell {
    
    @IBAction func buttonHandler(_: AnyObject) {
        print("tap")
    }
}

