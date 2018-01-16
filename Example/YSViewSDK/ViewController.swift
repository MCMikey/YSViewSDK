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
        
        let tv = YSTextView(frame: CGRect(x: 10, y: 90, width: 200, height: 40))
        tv.backgroundColor = .red
        tv.placeholder = "撒旦撒发大水发发大水发发大水发发大水发发大水发的是"
        tv.showLimit = true
        tv.maxLength = 10
        //tv.ysDelegate = self
        tv.ysDelegate = self
        view.addSubview(tv)
        
        let btn = YSButton(frame: CGRect(x: 10, y: 150, width: 100, height: 40))
        btn.backgroundColor = .lightGray
        btn.setImage(UIImage(named:"i1"), for: .normal)
        btn.imgSize = CGSize(width: 20, height: 30)
        btn.setTitle("阿斯蒂芬大沙发斯芬", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.layoutStyle = .LeftTitleRightImage
        btn.titleLabel?.numberOfLines = 2
        btn.titleLabel?.textAlignment = .center
        view.addSubview(btn)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: YSTextViewDelegate {
    func textViewDidTextChange(textView: YSTextView, count: Int) {
        print("textViewDidTextChange = \(count)")
    }
    
//    func textViewDidReachMaxLength(textView: YSTextView) {
//
//        print("textViewDidReachMaxLength = \(textView.text.count)")
//    }
    
    
}

