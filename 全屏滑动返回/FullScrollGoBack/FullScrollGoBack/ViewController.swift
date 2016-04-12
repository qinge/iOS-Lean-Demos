//
//  ViewController.swift
//  FullScrollGoBack
//
//  Created by qinge on 16/4/12.
//  Copyright © 2016年 Q. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIGestureRecognizerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(self.navigationController?.interactivePopGestureRecognizer)")
        print(" \n -------- \n")
        print("\(self.navigationController?.interactivePopGestureRecognizer?.delegate)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

