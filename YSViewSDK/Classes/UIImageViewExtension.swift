//
//  UIImageViewExtension.swift
//  Pods-YSViewSDK_Example
//
//  Created by Mikey on 2018/1/17.
//

import UIKit

extension UIImageView: UIScrollViewDelegate {

    open func canClickBigImg(_ can:Bool = true) {
        
        // 加入点击手势
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapShowImg(_:)))
        
        if (!can) {
            self.removeGestureRecognizer(touch)
            return
        }
        // 加入手势
        isUserInteractionEnabled = true
        
        touch.numberOfTapsRequired = 1
        //touch.numberOfTouchesRequired = 1
        addGestureRecognizer(touch)
        
    }
    
    @objc open func tapShowImg(_ sender: UIGestureRecognizer) {
        if sender.view is UIImageView {
            showImgView(sender.view as! UIImageView)
        }
    }
    
    func showImgView(_ currentImageView: UIImageView) {
        
        let img = currentImageView.image
        let window = UIApplication.shared.keyWindow
        let goBackgroundView = UIScrollView(frame: UIScreen.main.bounds)
        let currentRect = currentImageView.convert(currentImageView.bounds, to: window)
        goBackgroundView.backgroundColor = .clear
        goBackgroundView.minimumZoomScale = 1
        goBackgroundView.maximumZoomScale = 2.5
        goBackgroundView.showsVerticalScrollIndicator = false
        goBackgroundView.showsHorizontalScrollIndicator = false
        goBackgroundView.delegate = self
        let imgView = UIImageView(frame: currentRect)
        imgView.image = img
        imgView.tag = 789
        //imgView.layer.masksToBounds = self.layer.masksToBounds
        //imgView.layer.cornerRadius = self.layer.cornerRadius
        goBackgroundView.addSubview(imgView)
        window?.addSubview(goBackgroundView)
        
        self.element()["goBackgroundView"] = goBackgroundView
        
        let touchDouble = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        touchDouble.numberOfTapsRequired = 2
        //touchDouble.numberOfTouchesRequired = 1
        goBackgroundView.addGestureRecognizer(touchDouble)
        
        // 放大
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideImgView(_:)))
        //tap.delaysTouchesBegan = true
        tap.numberOfTapsRequired = 1
        goBackgroundView.addGestureRecognizer(tap)
        tap.require(toFail: touchDouble)
        
        
        self.alpha = 0
        imgView.alpha = 0.5
        // 动画
        let screenSize = UIScreen.main.bounds.size
        //goBackgroundView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            imgView.alpha = 1
            imgView.frame = CGRect(x: 0, y: (screenSize.height - img!.size.height * screenSize.width / img!.size.width) / 2, width: screenSize.width, height: img!.size.height * screenSize.width / img!.size.width)
            
            goBackgroundView.backgroundColor = .black
            
        }) { (_) in
        }
        
    }
    
    // 隐藏
    @objc func hideImgView(_ sender: UIGestureRecognizer) {
        let imgView = sender.view?.viewWithTag(789)
        //Log(message: "self = \(self.frame) imgView?.frame = \(imgView!.frame)")
        self.alpha = 1
        let view = self.element()["goBackgroundView"] as! UIScrollView
        view.setZoomScale(1, animated: false)
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 0
            imgView?.frame = self.frame
            //view.backgroundColor = .clear
        }) { (_) in
            view.removeFromSuperview()
            
        }
    }
    
    // 双击事件
    @objc func handleDoubleTap(_ sender: UIGestureRecognizer) {
        //Log(message: "handleDoubleTap")
        let view = self.element()["goBackgroundView"] as! UIScrollView
        
        let touchPoint = sender.location(in: view)
        if view.zoomScale <= 1.0 {
            let scaleX = touchPoint.x + view.contentOffset.x
            let scaleY = touchPoint.y + view.contentOffset.y
            view.zoom(to: CGRect(x: scaleX, y: scaleY, width: 10, height: 10), animated: true)
        } else {
            view.setZoomScale(1, animated: true)
        }
        
    }
    
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let imgView = scrollView.viewWithTag(789)
        return imgView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imgView = scrollView.viewWithTag(789)
        imgView?.center = centerOfScrollViewContent(scrollView: scrollView)
    }
    
    // center居中
    func centerOfScrollViewContent(scrollView: UIScrollView)-> CGPoint{
        
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
            (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        let actualCenter = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        
        return actualCenter;
    }
    
    
    // 放大缩小动画
    func showAnimate() {
        
    }
    
}

extension UIImageView {
    // 高斯模糊
    func boxblurImage(originalImage: UIImage, _ value: CGFloat = 5)->UIImage {
        var context = self.element()["context"] as? CIContext
        if context == nil {
            context = CIContext(options: nil)
        }
        
        //获取原始图片
        let inputImage =  CIImage(image: originalImage)
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(value, forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: originalImage.size)
        let cgImage = context?.createCGImage(outputCIImage, from: rect)
        //显示生成的模糊图片
        
        return UIImage(cgImage: cgImage!)
    }
}


