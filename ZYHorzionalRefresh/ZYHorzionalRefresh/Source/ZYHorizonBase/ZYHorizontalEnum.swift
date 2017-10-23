//
//  ZYHorizontalEnum.swift
//  HorizontalRefresh
//
//  Created by zhu yuanbin on 2017/10/17.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import Foundation

enum ZYRefreshState {
    // 初始状态
    case Init
    // 松开可以进行刷新
    case Pulling
    // 正在刷新中
    case Refreshing
    // 即将刷新的状态
    case WillRefresh
    // 所有数据加载完毕没有更多数据
    case NoMoreData
}

enum ZYRefreshNotificationKey:String{
        case contentOffset
        case contentInset
        case size
        case state
}
