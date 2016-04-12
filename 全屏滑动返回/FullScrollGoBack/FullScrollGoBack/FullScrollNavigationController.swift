//
//  FullScrollNavigationController.swift
//  FullScrollGoBack
//
//  Created by qinge on 16/4/12.
//  Copyright © 2016年 Q. All rights reserved.
//

import UIKit

class FullScrollNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let target = self.interactivePopGestureRecognizer?.delegate
        if let target = target {
            let gesture = UIPanGestureRecognizer(target: target, action: "handleNavigationTransition:")
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
            
            // 禁止使用系统自带的滑动手势
            self.interactivePopGestureRecognizer?.enabled = false
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    // 不是root view controller 时候手势有效
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.childViewControllers.count != 1 else {
            return false
        }
        return true
    }

    
    
    
}
