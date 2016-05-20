//
//  HamburgerView.swift
//  Taasky
//
//  Created by snqu-ios on 16/5/19.
//  Copyright © 2016年 Ray Wenderlich. All rights reserved.
//

import UIKit

class HamburgerView: UIView {

    let imageView: UIImageView! = UIImageView(image: UIImage(named: "menu"))
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure(){
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        imageView.contentMode = .Center
        addSubview(imageView)
    }
    
    func rotate(fraction: CGFloat) {
        let angle = Double(fraction) * M_PI_2
        imageView.transform = CGAffineTransformMakeRotation(CGFloat(angle))
    }

}
