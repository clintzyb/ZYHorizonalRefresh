//
//  ZYHorizontalStateHeader.swift
//  HorizontalRefresh
//
//  Created by zhu yuanbin on 2017/10/17.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import UIKit

class ZYHorizontalStateHeader: ZYHorizontalRefreshHeader {
    // 显示最后更新时间
    private var _lastUpdatedTimeLabel:UILabel? = nil
    // 显示当前操作状态
    private var _stateLabel:UILabel? = nil
    
    private let stateTitles:[ZYRefreshState:String] = [ZYRefreshState.Init:"正\n常\n状\n态\n",
                                                       ZYRefreshState.NoMoreData:"没\n有\n更\n多\n数\n据\n",
                                                       ZYRefreshState.Pulling:"松\n开\n可\n以\n进\n行\n刷\n新\n",
                                                       ZYRefreshState.Refreshing:"正\n在\n刷\n新\n中\n",
                                                       ZYRefreshState.WillRefresh:"即\n将\n刷\n新\n的\n"]
    
    // 文字距离 箭头的距离
    var topleftInset:CGFloat = 0.0
    
    var lastUpdatedTimeLabel:UILabel?{
        
        if nil == self._lastUpdatedTimeLabel{
            self._lastUpdatedTimeLabel = UILabel.zy_refresh_label
            self.addSubview(self._lastUpdatedTimeLabel!)
        }
        return self._lastUpdatedTimeLabel
    }
    
    var stateLabel:UILabel?{
        
        if nil == self._stateLabel{
            self._stateLabel = UILabel.zy_refresh_label
            self.addSubview(self._stateLabel!)

        }
        return self._stateLabel
    }
    
    var changeStateTitle:ZYRefreshState{
        get{
            return ZYRefreshState.Init
        }
        set{
            self.stateLabel?.text = self.stateTitles[newValue]
            self.stateLabel?.sizeToFit()
        }
    }
    
    override var lastUpdateTimeKey: String{
        
        get{
            return super.lastUpdateTimeKey
        }
        set{
            super.lastUpdateTimeKey = newValue
            if true == self.lastUpdatedTimeLabel?.isHidden{
                return
            }
            
            if false == newValue.isEmpty{
//                let calendar = self.currentCalendar
//                let unitFlags = NSCalendar.Unit.year.rawValue |
//                    NSCalendar.Unit.month.rawValue |
//                    NSCalendar.Unit.day.rawValue |
//                    NSCalendar.Unit.hour.rawValue |
//                    NSCalendar.Unit.minute.rawValue
//
//                let comp1 = calendar?.components(NSCalendar.Unit.init(rawValue: unitFlags), from: self.lastUpdatedTime)
//                let comp2 = calendar?.components(NSCalendar.Unit.init(rawValue: unitFlags), from: Date())
//                let dateFormatter = DateFormatter()
                self.lastUpdatedTimeLabel?.text = "更新了1"
                
            }
            else{
                self.lastUpdatedTimeLabel?.text = "更新了1"
            }
        }
    }
    
    override var state: ZYRefreshState{
        get{
            return self._state
        }
        set{
            let oldState = self._state
            if oldState == newValue{
                return
            }
            super.state = newValue

            self.stateLabel?.text = self.stateTitles[newValue]
            self.stateLabel?.sizeToFit()
            self.lastUpdateTimeKey = super.lastUpdateTimeKey
        }
    }
    
    override func prepare() {
        super.prepare()
        self.topleftInset = 25.0
        self.changeStateTitle = ZYRefreshState.Init
        
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        if true == self.stateLabel?.isHidden{
            return
        }
        
        // statulabel上是否有autolayout约束
        let noConstrainsOnStatusLabel = self.stateLabel?.constraints.count == 0
        
        if true == self.lastUpdatedTimeLabel?.isHidden{
            if true == noConstrainsOnStatusLabel{
                self.stateLabel?.frame = self.bounds
            }
        }
        else{
            let statLabelW = self.frame.size.width * 0.5

            if true == noConstrainsOnStatusLabel{
                self.stateLabel?.frame.origin.x = statLabelW
                self.stateLabel?.frame.origin.y = 0.0
                self.stateLabel?.frame.size.width = statLabelW
                self.stateLabel?.frame.size.height = self.frame.size.height
            }

            if 0 == self.lastUpdatedTimeLabel?.constraints.count{
                self.lastUpdatedTimeLabel?.frame.origin.x = 0
                self.lastUpdatedTimeLabel?.frame.origin.y = 0
                self.lastUpdatedTimeLabel?.frame.size.width = self.frame.size.width - statLabelW
                self.lastUpdatedTimeLabel?.frame.size.height = self.frame.size.height
            }
        }
        
    }
    
    
    var currentCalendar:NSCalendar?{
       return NSCalendar(identifier: NSCalendar.Identifier.gregorian)
    }

}
