//
//  ViewController.swift
//  TableViewGroupDemo
//
//  Created by snqu-ios on 16/4/19.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "FirstTestTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstTestTableViewCell")
        tableView.registerNib(UINib(nibName: "SecondTestTableViewCell", bundle: nil), forCellReuseIdentifier: "SecondTestTableViewCell")
        tableView.registerNib(UINib(nibName: "ThirdTestTableViewCell", bundle: nil), forCellReuseIdentifier: "ThirdTestTableViewCell")
        
        let testHeadView = UIView(frame: CGRectMake(0, 0, 320, 100))
        testHeadView.backgroundColor = UIColor.orangeColor()
        tableView.tableHeaderView = testHeadView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 2 else {
            return 1
        }
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("FirstTestTableViewCell", forIndexPath: indexPath)
            return cell
        }else if (indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("SecondTestTableViewCell", forIndexPath: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ThirdTestTableViewCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 106.0
        case 1: return 227.0
        case 2: return 84.0
        default: return 44
        }
    }
    
    // 设置间距
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10;
        }else{
            return 5;
        }
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard indexPath.section == 2 else {
            return false
        }
        return true
    }

}

