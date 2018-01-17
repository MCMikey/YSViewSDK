//
//  NSObject+AddProperty.swift
//  swiftOfAfn
//
//  Created by Mikey on 16/10/17.
//  Copyright © 2016年 mikey. All rights reserved.
//

import UIKit

extension NSObject {
    
    private struct AssociatedKeys {
        static var ElementStringName = "mc_StringName"
        static var ElementDicName = "mc_DicName"
    }
    
    public var elementString: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ElementStringName) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.ElementStringName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    /// 该对象绑定一个字典并且返回
    public func element()->NSMutableDictionary {
        var ele = objc_getAssociatedObject(self, &AssociatedKeys.ElementDicName) as? NSMutableDictionary
        if (ele == nil) {
            ele = NSMutableDictionary()
            objc_setAssociatedObject(self, &AssociatedKeys.ElementDicName, ele, .OBJC_ASSOCIATION_RETAIN)
        }
        return ele!
    }
    
    public func removeElement(key: String?) {
        let ele = objc_getAssociatedObject(self, &AssociatedKeys.ElementDicName) as? NSMutableDictionary
        if (ele == nil) {return}
        ele!.removeObject(forKey: key!)
        objc_setAssociatedObject(self, &AssociatedKeys.ElementDicName, ele, .OBJC_ASSOCIATION_RETAIN)
    }
    
    
    /*
    var elementDic: NSMutableDictionary? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ElementDicName) as? NSMutableDictionary
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.ElementDicName,
                    newValue as NSMutableDictionary?,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }
 */

}
