//
//  ZYHorizontalRefreshComponet.swift
//  HorizontalRefresh
//
//  Created by zhu yuanbin on 2017/10/17.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import UIKit

typealias ZYRefreshComponentRefreshingClosure = ()->Void

class ZYHorizontalRefreshComponet: UIView {
    
    // UIScrollerView 起始的内容展示位置
     var originOriginalInset:UIEdgeInsets = UIEdgeInsets.zero
    // 引用父视图必须为weak
     weak var scrollerView:UIScrollView? = nil
    
    private var pan:UIPanGestureRecognizer? = nil
    
    var refreshClosure:ZYRefreshComponentRefreshingClosure? = nil
    
    // 拖拽百分比
    var pullingPercent:CGFloat = 0.0
    
    // 是否正在刷新
    var isRefreshing:Bool{
        return self.state == ZYRefreshState.Refreshing || self.state == ZYRefreshState.WillRefresh
    }
    
    // 默认为初始状态
    internal var _state:ZYRefreshState = .Init
    
    // 通过计算属性对状态进行设置 由子类来具体实现
    var state:ZYRefreshState{
        get{
            return self._state
        }
        set{
            self._state = newValue
            DispatchQueue.main.async {[weak self] in
                    self?.setNeedsLayout()
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化
    func prepare()->Void{
        // 因为是横向拖动所以只动态适配高度
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
    }
    // 开始刷新
    func beginRefreshing()->Void{
        
        UIView.animate(withDuration: ZYRefreshFastAnimationDuration, animations: {[weak self] in
            self?.alpha = 1.0
            
        }) { (isfinish) in
            
        }
        self.pullingPercent = 1.0
        if nil != self.window{
            self.state = ZYRefreshState.Refreshing
        }
        else{
            if ZYRefreshState.Refreshing != self.state{
                self.state = ZYRefreshState.WillRefresh
                self.setNeedsDisplay()
            }
        }
        
    }
    
    // 刷新完成后回调
    func endRefreshCallingBack()->Void{
        DispatchQueue.main.async {[weak self] in
            guard let refreshingClosure = self?.refreshClosure else{
                return
            }
            refreshingClosure()
    
        }
    }
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.removeObservers()

        // 父视图为nil 或不是UIScroller以及其子类 那么直接返回
        guard let scrollerView = newSuperview as? UIScrollView else {
            return
        }
        self.frame.size.height = scrollerView.frame.size.height
        self.frame.origin.y = 0
        self.scrollerView = scrollerView
        self.scrollerView?.alwaysBounceHorizontal = true
        self.originOriginalInset = self.scrollerView!.contentInset
        self.backgroundColor = UIColor.yellow
        self.addObservers()
        
    }
    
    override func layoutSubviews() {
        self.placeSubViews()
        super.layoutSubviews()
    }
    

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if ZYRefreshState.WillRefresh == self.state{
            self.state = .Refreshing
        }
    }
 
    
    func removeObservers() -> Void {
        self.scrollerView?.removeObserver(self, forKeyPath: ZYRefreshNotificationKey.contentOffset.rawValue, context: nil)
        self.scrollerView?.removeObserver(self, forKeyPath: ZYRefreshNotificationKey.size.rawValue, context: nil)
        self.pan?.removeObserver(self, forKeyPath: ZYRefreshNotificationKey.state.rawValue, context: nil)
        self.pan = nil
    }
    
    func addObservers() -> Void {
        self.scrollerView?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.contentOffset.rawValue, options: .new, context: nil)
        self.scrollerView?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.contentOffset.rawValue, options: .old, context: nil)
        self.scrollerView?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.size.rawValue, options: .new, context: nil)
        self.scrollerView?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.size.rawValue, options: .old, context: nil)
        self.pan = self.scrollerView?.panGestureRecognizer
        self.pan?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.state.rawValue, options: .new, context: nil)
        self.pan?.addObserver(self, forKeyPath: ZYRefreshNotificationKey.state.rawValue, options: .old, context: nil)
    }
    
    // 交给子类实现
    func placeSubViews() -> Void {
    }
    
    // 交给子类实现
    func scrollViewContentOffsetDidChange(change:[NSKeyValueChangeKey:Any]?)->Void{
        
    }
    
    // 交给子类实现
    func scrollViewContentSizeDidChange(change:[NSKeyValueChangeKey:Any]?) -> Void {
        
    }
    
    // 交给子类实现
    func scrollViewPanStateDidChange(change:[NSKeyValueChangeKey:Any]?)->Void{
        
    }
    // 交给子类实现
    func endRefresh()->Void{
        
        DispatchQueue.main.async {[weak self] in
            self?.state = ZYRefreshState.Init

        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else {
            return
        }
        
        // 如果禁用了交互和隐藏的话直接返回
        if false == self.isUserInteractionEnabled{
            return
        }
        
        if ZYRefreshNotificationKey.size.rawValue == keyPath{
            self.scrollViewContentSizeDidChange(change: change)
        }
        
        if true == self.isHidden{
            return
        }
        
        if ZYRefreshNotificationKey.contentOffset.rawValue == keyPath{
            self.scrollViewContentOffsetDidChange(change: change)
        }
        else if ZYRefreshNotificationKey.state.rawValue == keyPath{
            self.scrollViewPanStateDidChange(change: change)
        }
        
    }

}


extension UILabel{
    
  class  var zy_refresh_label:UILabel{
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        label.textAlignment = NSTextAlignment.center
        label.autoresizingMask = UIViewAutoresizing.flexibleHeight
        label.numberOfLines = 0
        return label
    }
    
    var zy_textHeight:CGFloat{
        
        
        let toNSStringOption:NSString? = NSString(cString: (self.text?.cString(using: String.Encoding.utf8))!, encoding: String.Encoding.utf8.rawValue)
        
        var stringHeight:CGFloat = CGFloat(0.0)
        let size = CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        
        guard let toNSString = toNSStringOption else {
            return stringHeight
        }
        
        if #available(iOS 7.0, *){
            stringHeight = toNSString.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:[NSFontAttributeName:self.font], context: nil).size.height
        }
        else{
            stringHeight = toNSString.size(attributes: [NSFontAttributeName:self.font]).height
        }
        
        return stringHeight
    }
    
}
