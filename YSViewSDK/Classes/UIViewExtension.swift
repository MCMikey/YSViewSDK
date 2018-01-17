//
//  UIView_Base.swift
//  Pods-YSViewSDK_Example
//
//  Created by Mikey on 2018/1/17.
//

import UIKit

extension UIView {

    // MARK: - 属性
    
    /// 主题渐变色
    //    func addThemeBackgroundColor(frame:CGRect? = nil) {
    //        let cols:[UIColor] = [UIColor(hexString: "#99d630")!, UIColor(hexString: "#72b81e")!, UIColor(hexString: "#4b9a0c")!]
    //        let nums:[NSNumber] = [0.1, 0.5, 1]
    //        addBackgroundColor(colors: cols, frame: frame, locations: nums, vertical: true)
    //    }
    
    /// 渐变背景色 (colors:数组， frame: frame, locations: [0.1, 0.5, 1], vertical:水平垂直)
    open func addBackgroundColor(colors: [UIColor], frame:CGRect? = nil, locations:[NSNumber]? = nil, vertical:Bool = true) {
        
        var cgColors = [CGColor]()
        for col in colors {
            cgColors.append(col.cgColor)
        }
        
        let layer = CAGradientLayer()
        
        if frame == nil {
            layer.frame = self.bounds
        } else {
            layer.frame = frame!
        }
        
        if vertical {
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
        } else {
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
        }
        layer.colors = cgColors
        layer.locations = locations
        
        self.layer.insertSublayer(layer, at: 0)
    }
    
    
    // MARK: - 动画
    /// percent: 开始, bounce: 加多少
    open static func scaleAnimateBounces(view: UIView, time: TimeInterval, percent: CGFloat, bounce: CGFloat, closure: @escaping ()->Void) {
        
        var percent = percent
        if percent == 0 {
            percent = 0.01
        }
        view.layer.removeAllAnimations()
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = time
        scaleAnimation.values = [percent, percent+bounce, percent]
        //scaleAnimation.values = [1,1.5,1]
        //scaleAnimation.keyTimes = [0,0.5,1]
        scaleAnimation.fillMode = kCAFillModeForwards
        //scaleAnimation.autoreverses = true
        view.layer.add(scaleAnimation, forKey: "scale-layer")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: {
            closure()
            
        })
    }
    
    
    /// 抛物线移动
    open static func throwView(view:UIView, endpoint: CGPoint, closure: @escaping ()->Void) {
        let path = UIBezierPath()
        let startPoint = view.center
        path.move(to: startPoint)
        
        // 贝赛尔曲线控制点
        let sx = startPoint.x
        let sy = startPoint.y
        let ex = endpoint.x
        let ey = endpoint.y
        let x = sx + (ex - sx) / 3
        let y = sy + (ey - sy) * 0.5 - 400;
        path.addQuadCurve(to: endpoint, controlPoint: CGPoint(x: x, y: y))
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.duration = 0.8
        animation.autoreverses = false
        animation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)]
        view.layer.add(animation, forKey: "throw")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) {
            closure()
        }
    }
    
    open func rotate3DAnimate(closure: @escaping ()->Void) {
        let animateRotate = retate3DAnimate()
        let groupAnimation = CAAnimationGroup()
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.duration = 1
        groupAnimation.repeatCount = 1
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.animations = [animateRotate]
        self.layer.add(groupAnimation, forKey: "animationRotate")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            closure()
        }
    }
    
    open func retate3DAnimate()-> CAAnimation {
        let rotationTransform = CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0, 1, 0)
        let animation = CABasicAnimation(keyPath: "transform")
        
        animation.toValue = NSValue.init(caTransform3D: rotationTransform)
        animation.duration = 0.6
        animation.autoreverses = true
        animation.repeatCount = 1
        animation.beginTime = 0
        return animation
    }
    
    // 透明度
    open func addOpacityAnimate(beginTime: CFTimeInterval = 0, duration: CFTimeInterval = 0, fromValue: NSNumber = NSNumber(value: 0), toValue: NSNumber = NSNumber(value: 1)) {
        let animation = CABasicAnimation(keyPath: "opacity")
        
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.beginTime = CACurrentMediaTime() + beginTime
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.layer.add(animation, forKey: "opacity")
    }
    
    // 弹性位移
    @available(iOS 9.0, *)
    open func addSpringAnimate(fromValue: NSValue, toValue: NSValue, damping: CGFloat = 10, stiffness: CGFloat = 100, mass: CGFloat = 1, beginTime:CFTimeInterval = 0) {
        let spring = CASpringAnimation(keyPath: "position")
        spring.fromValue = fromValue
        spring.toValue = toValue
        //animation.speed = 10
        // 阻尼系数
        spring.damping = damping
        // 刚度系数
        spring.stiffness = stiffness
        spring.initialVelocity = 10
        // 质量
        spring.mass = mass
        
        spring.beginTime = CACurrentMediaTime() + beginTime
        spring.fillMode = kCAFillModeForwards
        spring.isRemovedOnCompletion = false
        spring.duration = spring.settlingDuration
        
        self.layer.add(spring, forKey: "SpringAnimate")
    }
    
    // 位移
    open func addPositionAnimate(fromValue: NSValue, toValue: NSValue, beginTime:CFTimeInterval = 0, duration: CFTimeInterval = 0.2) {
        let spring = CABasicAnimation(keyPath: "position")
        spring.fromValue = fromValue
        spring.toValue = toValue
        spring.duration = duration
        spring.beginTime = CACurrentMediaTime() + beginTime
        spring.isRemovedOnCompletion = false
        spring.fillMode = kCAFillModeForwards
        self.layer.add(spring, forKey: "PositionAnimate")
    }
    
    // 截屏
    open func screenShotAction()->UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img!
    }
    
    // MARK: - 圆角
    open func mc_addCorner(radius: CGFloat, borderWidth: CGFloat, backgroundColor: UIColor, borderColor: UIColor) {
        let imageView = UIImageView(image: mc_drawRectWithRoundedCorner(radius: radius,
                                                                        borderWidth: borderWidth,
                                                                        backgroundColor: backgroundColor,
                                                                        borderColor: borderColor))
        self.insertSubview(imageView, at: 0)
    }
    
    func mc_drawRectWithRoundedCorner(radius: CGFloat,
                                      borderWidth: CGFloat,
                                      backgroundColor: UIColor,
                                      borderColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        //let context = UIGraphicsGetCurrentContext()
        
        //let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
        
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return output!
    }
}
