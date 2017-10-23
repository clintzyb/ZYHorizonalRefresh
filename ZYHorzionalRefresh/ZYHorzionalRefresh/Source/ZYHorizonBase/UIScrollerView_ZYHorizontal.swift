//
//  UIScrollerView_ZYHorizontal.swift
//  TestScrollerView
//
//  Created by zhu yuanbin on 2017/10/22.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import Foundation
import UIKit
var key:Character = "\0"

extension UIScrollView{
    var zyRefreshHeader:ZYHorizontalRefreshHeader?{
        get{
           return objc_getAssociatedObject(self, &key) as? ZYHorizontalRefreshHeader
        }
        set{
            if newValue !== self.zyRefreshHeader{
                self.zyRefreshHeader?.removeFromSuperview()
                
                guard let newValue = newValue else{
                    return
                }
     
                self.insertSubview(newValue, at: 0)
                
                
                //MARK:自己创建的对象 如果外部要用KVO的话必须手动通知
                //FIXME:没弄清楚KeyPath<>的流程
//                self.willChangeValue(for: )
                objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                self.didChangeValue(for: )


            }
        }
    }
    
}
