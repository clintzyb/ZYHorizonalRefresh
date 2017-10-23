//
//  ViewController.swift
//  ZYHorzionalRefresh
//
//  Created by zhu yuanbin on 2017/10/23.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var MyScroller: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyScroller.zyRefreshHeader = ZYHorizontalNormalHeader.headerWithRefreshing(refreshingClousre: {
            print("开始刷新")
        }) as? ZYHorizontalRefreshHeader
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

