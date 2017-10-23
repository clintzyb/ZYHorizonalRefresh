//
//  ZYHorizontalRefreshHeader.swift
//  HorizontalRefresh
//
//  Created by zhu yuanbin on 2017/10/17.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import UIKit

class ZYHorizontalRefreshHeader: ZYHorizontalRefreshComponet {
    // 上一次横拖刷新成功时间
    var lastUpdateTimeKey:String = ""
    // 上一次横拖刷新成功的时间
    var lastUpdatedTime:Date{
        get{
            let userDefault = UserDefaults.standard
            guard let date = userDefault.object(forKey: self.lastUpdateTimeKey) as? Date else {
                print("ZYHorizontalRefreshHeader.lastUpdatedTime 日期转换错误")
                return Date()
            }
            return date
        }
    }

    /** 忽略多少scrollView的contentInset的left */
    var ignoredScrollViewContentInsetLeft:CGFloat = 0.0
    
    var insetLDelta:CGFloat = 0.0
    
    // 重写sate
    override var state: ZYRefreshState{
        get{
            return _state
        }
        set{
            let oldState = self._state
            if oldState == newValue{
                return
            }
            super.state = newValue
            
            if ZYRefreshState.Init == newValue{
                if oldState != ZYRefreshState.Refreshing{
                    return
                }
                // 保存刷新时间
                let userDefault = UserDefaults.standard
                userDefault.set(NSDate(), forKey: self.lastUpdateTimeKey)
                // 恢复inset 和 offset
                UIView.animate(withDuration: ZYRefreshSlowAnimationDuration, animations: {[weak self] in
                    // 设置contentInset的时候 contentOffset同时也会被设置回去
                    self?.scrollerView?.contentInset.left=self!.insetLDelta+(self?.scrollerView!.contentInset.left)!

                }, completion: { [weak self](finished) in
                    self?.pullingPercent = 0.0
                })
            }
            else if ZYRefreshState.Refreshing == newValue{
                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: ZYRefreshSlowAnimationDuration, animations: {[weak self] in
                        let left = (self?.originOriginalInset.left)!+(self?.frame.size.width)!
                        self?.scrollerView?.contentInset.left = left
                        self?.scrollerView?.contentOffset.x = -left

                    }, completion: { [weak self](isfinish) in
                        self?.endRefreshCallingBack()
                    })

                })
                
                

            }
        }
    }
    
    
    class func headerWithRefreshing(refreshingClousre:ZYRefreshComponentRefreshingClosure?)->AnyObject{
        let cmp = self.init()
        cmp.refreshClosure = refreshingClousre
        return cmp
    }
    
    override func prepare() {
        super.prepare()
        self.lastUpdateTimeKey = ZYRefreshHeaderLastUpdatedTimeKey
        // 设置高度
        self.frame.size.width = CGFloat(-54)
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        self.frame.origin.x = -self.frame.size.width - self.ignoredScrollViewContentInsetLeft
    }
    
    override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
    
        // 刷新状态
        if self.state == ZYRefreshState.Refreshing{
            
            if nil == self.window{
                return
            }
            // 在刷新状态下保持scrollerViewContentInset
            // 以下注释代码是为了解决UITableView的Sectionheader停留问题 主要是用在UITableView中
            // 在横向滑动时可以把值固定
            

            var insetLeft = (-self.scrollerView!.contentOffset.x) > self.originOriginalInset.left ? Double(-(self.scrollerView!.contentOffset.x)):(Double(self.originOriginalInset.left))
            insetLeft = insetLeft > Double(self.frame.size.width+self.originOriginalInset.left) ? Double(self.frame.size.width+self.originOriginalInset.left):insetLeft
                self.scrollerView?.contentInset.left = CGFloat(insetLeft)
                self.insetLDelta = self.originOriginalInset.left - CGFloat(insetLeft)
                return
        }
        self.originOriginalInset = (self.scrollerView?.contentInset)!
        let offsetX = (self.scrollerView?.contentOffset.x)!
        // 左边刷新空间刚好出现
        let happenOffsetX = -self.originOriginalInset.left
        
        // 向左滚动看不见头部直接返回
        if offsetX > happenOffsetX{
            return
        }
        
        // Init 和 WillRefresh 的零界点计算
        let normalPullingOffsetX =  happenOffsetX-self.frame.size.width
        // 偏移的百分比
        let pullingPercent = (happenOffsetX-offsetX)/self.frame.size.width
        
        // 正在拖拽
        if true == self.scrollerView?.isDragging{
            self.pullingPercent = pullingPercent
            
            if ZYRefreshState.Init == self.state && offsetX < normalPullingOffsetX{
                // 进入即将刷新状态
                self.state = ZYRefreshState.Pulling
            }
            else if ZYRefreshState.Pulling == self.state && offsetX > normalPullingOffsetX{
                // 进入普通状态
                self.state = ZYRefreshState.Init
            }
        }
        else if ZYRefreshState.Pulling == self.state{
            // 即将刷新
                self.beginRefreshing()
        }
        else if pullingPercent < 1{
            self.pullingPercent = pullingPercent
        }
        
    }
    
    
    override func endRefresh() {
        DispatchQueue.main.async {[weak self] in
            self?.state = ZYRefreshState.Init
        }
    }

}
