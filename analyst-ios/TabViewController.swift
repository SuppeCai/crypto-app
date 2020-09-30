//
//  TabViewController.swift
//  analyst-ios
//
//  Created by 蔡苏鹏 on 18/07/2018.
//  Copyright © 2018 蔡苏鹏. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.tintColor = UIColor.ColorHex(hex: "fbb117")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

