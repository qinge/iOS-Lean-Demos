//
//  SpaceViewController.swift
//  NavigationBarDemo
//
//  Created by snqu-ios on 16/4/18.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

import UIKit

class SpaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var navigationBarColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    }

    /**
     调试发现 push 时候 scrollViewDidScroll 被调用 解决 viewWillAppear 设置 delegate 
     viewWillDisappear 置空 delegate 
     参考: http://www.cnblogs.com/smileEvday/p/problem.html
     
     - parameter animated:
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.delegate = nil
        self.navigationController?.navigationBar.snqu_resetOverlay()
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            let alpha = 1 - (64 - scrollView.contentOffset.y) / 64
            self.navigationController?.navigationBar .snqu_setBackgroundColor(navigationBarColor.colorWithAlphaComponent(alpha))
        }else {
            self.navigationController?.navigationBar .snqu_setBackgroundColor(navigationBarColor.colorWithAlphaComponent(0.0))
        }
    }

}

