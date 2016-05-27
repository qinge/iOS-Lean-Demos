//
//  NavigationBarAction.swift
//  NavigationBarDemo
//
//  Created by snqu-ios on 16/4/18.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    private struct AssociatedKeys {
        static var overlayKey = "overlayKey"
    }
    
    var overlay: UIView? {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.overlayKey) as? UIView
        }
        
        set{
            if let newValue = newValue {
                objc_setAssociatedObject(self,
                    &AssociatedKeys.overlayKey,
                    newValue as UIView,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    
    func snqu_setBackgroundColor(backgroundColor: UIColor) {
        if self.overlay == nil {
            self.overlay = UIView(frame: CGRectMake(0, -20, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + 20))
            self.overlay?.userInteractionEnabled = false
            self.overlay?.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin ,  UIViewAutoresizing.FlexibleRightMargin]
        }
        self.insertSubview(self.overlay!, atIndex: 0)
        self.overlay?.backgroundColor = backgroundColor
    }
    
    func snqu_resetOverlay() {
        self.overlay?.removeFromSuperview()
        self.overlay = nil
    }
}
