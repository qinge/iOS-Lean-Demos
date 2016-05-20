//
//  ViewController.swift
//  MyTaasky
//
//  Created by snqu-ios on 16/5/19.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuContainerView: UIView!
    
    private var detailViewController: ContentViewController?
    
    var showingMenu = false
    var hamburgerView: HamburgerView!
    
    var menuItem: NSDictionary? {
        didSet{
            hideOrShowMenu(false, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 由于scrollview 包含两个 tableView 所以设置以下属性 才能各个tableView 各自滚动
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge.None
        
//        self.navigationController!.navigationBar.tintColor = UIColor.redColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.orangeColor()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hamburgerViewTapped")
        hamburgerView = HamburgerView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        hamburgerView!.addGestureRecognizer(tapGestureRecognizer)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerView)
        
        // 设置 菜单滑动时动画锚点
        menuContainerView.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        
        
//        self.navigationController?.navigationBar.translucent = false
        // 解决 设置 self.edgesForExtendedLayout = UIRectEdge.None 后 tabbar 颜色显示异常问题
        self.tabBarController?.tabBar.translucent = false
        
//        self.navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideOrShowMenu(showingMenu, animated: false)
    }

    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollView.pagingEnabled = scrollView.contentOffset.x < (scrollView.contentSize.width - CGRectGetWidth(scrollView.frame))
        
        let multiplier = 1.0 / CGRectGetWidth(menuContainerView.bounds)
        let offset = scrollView.contentOffset.x * multiplier
        let fraction = 1.0 - offset
        menuContainerView.layer.transform = transformForFraction(fraction)
        menuContainerView.alpha = fraction
        
//        let angle = Double(fraction) * M_PI_2
//        hamburgerView.transform = CGAffineTransformMakeRotation(CGFloat(angle))
        
    }
    
    func hideOrShowMenu(show: Bool, animated: Bool){
        let menuOffset = CGRectGetWidth(menuContainerView.bounds)
        scrollView.setContentOffset(show ? CGPointZero: CGPoint(x: menuOffset, y: 0), animated: animated)
        showingMenu = show
    }
    
    
    /**
     解决 手动滑动后点击菜单按钮 菜单隐藏显示不对问题
     
     - parameter scrollView:
     */
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let mentuOffset = CGRectGetWidth(menuContainerView.bounds)
        showingMenu = !CGPointEqualToPoint(CGPoint(x: mentuOffset, y: 0), scrollView.contentOffset)
    }
    
    
    func transformForFraction(fraction: CGFloat) -> CATransform3D {
        var identify = CATransform3DIdentity
        identify.m34 = -1.0 / 1000.0
        let angle = Double(1.0 - fraction) * -M_PI_2
        let xOffset = CGRectGetWidth(menuContainerView.bounds) * 0.5
        let rotateTransform = CATransform3DRotate(identify, CGFloat(angle), 0.0, 1.0, 0.0)
        let translateTransform = CATransform3DMakeTranslation(xOffset, 0.0, 0.0)
        return CATransform3DConcat(rotateTransform, translateTransform)
    }
    
    
    
    func hamburgerViewTapped(){
       hideOrShowMenu(!showingMenu, animated: true)
    }

}

