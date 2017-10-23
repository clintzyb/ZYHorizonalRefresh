//
//  ZYHorizontalNormalHeader.swift
//  HorizontalRefresh
//
//  Created by zhu yuanbin on 2017/10/17.
//  Copyright © 2017年 zhuyuanbin. All rights reserved.
//

import UIKit
import Foundation
class ZYHorizontalNormalHeader: ZYHorizontalStateHeader {
    
    private var _arrowView:UIImageView? = nil
    private var _loadingView:UIActivityIndicatorView? = nil
    private var _activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    var activityIndicatorViewStyle:UIActivityIndicatorViewStyle{
        get{
            return self._activityIndicatorViewStyle
        }
        set{
            self._activityIndicatorViewStyle = newValue
            self.loadingView = nil
            self.setNeedsLayout()
        }
    }

    var arrowView:UIImageView?{
        get{
            if(nil == self._arrowView){
                self._arrowView = UIImageView(image: UIImage(named: "arrow"))
                self.addSubview(self._arrowView!)
            }
            return _arrowView
        }
    }
    
    var loadingView:UIActivityIndicatorView?{
        get{
            if nil == self._loadingView{
                self._loadingView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorViewStyle)
                self._loadingView?.hidesWhenStopped = true
                self.addSubview(self._loadingView!)
            }
            return self._loadingView
        }
        set{
            self._loadingView = newValue
        }
        
    }
    
    override func prepare() {
        super.prepare()
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    }
    
    override func placeSubViews() {
        super.placeSubViews()
        var arrowCenterY:CGFloat = self.frame.size.height*0.5
        if false == self.stateLabel?.isHidden{
            let stateHeight:CGFloat = (self.stateLabel?.zy_textHeight)!
            var timeHeight:CGFloat = CGFloat(0.0)
            if true == self.lastUpdatedTimeLabel?.isHidden{
                timeHeight = (self.lastUpdatedTimeLabel?.zy_textHeight)!
            }
            let textHeight = CGFloat.maximum(stateHeight, timeHeight)
            arrowCenterY = arrowCenterY + textHeight*0.5+self.topleftInset
        }
        let arrowCenterX = self.frame.size.width*0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        if 0 == self.arrowView?.constraints.count{
            self.arrowView?.frame.size = (self.arrowView?.image?.size)!
            self.arrowView?.center = arrowCenter
        }
        
        if 0 == self.loadingView?.constraints.count{
            self.loadingView?.center = arrowCenter
        }
        self.arrowView?.tintColor = self.stateLabel?.textColor
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

            if ZYRefreshState.Init == newValue{
                
                if ZYRefreshState.Refreshing == oldState{
                    self.arrowView?.transform = CGAffineTransform.identity
                    UIView.animate(withDuration: ZYRefreshSlowAnimationDuration, animations: {[weak self] in
                        self?.loadingView?.alpha = 0.0
                    }, completion: { [weak self](isfinish) in
                        if ZYRefreshState.Init != self?._state{
                            return
                        }
                        self?.loadingView?.alpha = 1.0
                        self?.loadingView?.stopAnimating()
                        self?.arrowView?.isHidden = false
                    })
                }
                else{
                    self.loadingView?.stopAnimating()
                    self.arrowView?.isHidden = false
                    UIView.animate(withDuration: ZYRefreshFastAnimationDuration, animations: {[weak self] in
                        self?.arrowView?.transform = CGAffineTransform.identity
                    })
                }
    
            }
            else if ZYRefreshState.Pulling == newValue{
                self.loadingView?.stopAnimating()
                self.arrowView?.isHidden = false
                UIView.animate(withDuration: ZYRefreshFastAnimationDuration, animations: {[weak self] in
                    self?.arrowView?.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - Double.pi))
                })
            }
            else if ZYRefreshState.Refreshing == newValue{
                self.loadingView?.alpha = 1.0
                self.loadingView?.startAnimating()
                self.arrowView?.isHidden = true
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
