//
//  ViewController.swift
//  YSViewSDK
//
//  Created by 605055291@qq.com on 01/06/2018.
//  Copyright (c) 2018 605055291@qq.com. All rights reserved.
//

import UIKit
import YSViewSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tf = YSTextField(frame: CGRect(x: 10, y: 30, width: 200, height: 40), limit: 25)
        tf.showLimit = true
        tf.padding = UIEdgeInsetsMake(0, 15, 0, 23)
        tf.backgroundColor = .white
        tf.layer.borderWidth = 0.35
        tf.layer.cornerRadius = 5.0
        tf.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(tf)
        

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

