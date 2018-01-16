//
//  YSButton.swift
//  Pods-YSViewSDK_Example
//
//  Created by Mikey on 2018/1/16.
//

import UIKit

open class YSButton: UIButton {
    
    public enum YSButtonLayoutStyle {
        case LeftImageRightTitle
        case LeftTitleRightImage
        case UpImageDownTitle
        case UpTitleDownImage
    }

    /// 布局方式
    open var layoutStyle: YSButtonLayoutStyle = .LeftImageRightTitle {
        didSet {
            
        }
    }
    
    
    /// 图片文字间距，默认为5
    open var midSpacing: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate var padding:CGFloat = 6
    
    open var imgSize: CGSize = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var textLine: Int = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = imageView {
            if __CGSizeEqualToSize(CGSize.zero, imgSize) {
                imageView.sizeToFit()
            } else {
                imageView.frame = CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imgSize.width, height: imgSize.height)
            }
        }
        
        if let titleLabel = titleLabel {
            
                var size: CGSize!
                switch layoutStyle {
                case .LeftTitleRightImage, .LeftImageRightTitle :
                    
                    let maxWidth = frame.size.width - imageView!.frame.size.width - midSpacing - padding
                    let maxHeight = frame.size.height - padding
                    
                    if titleLabel.numberOfLines == 0 {
                        size = titleLabel.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
                    } else {
                        size = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight), limitedToNumberOfLines: titleLabel.numberOfLines).size
                    }
                    
                    break
                case .UpImageDownTitle, .UpTitleDownImage :
                    
                    let maxWidth = frame.size.width - padding
                    let maxHeight = frame.size.height - imageView!.frame.size.height - midSpacing - padding
                    
                    if titleLabel.numberOfLines == 0 {
                        size = titleLabel.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
                    } else {
                        size = titleLabel.textRect(forBounds: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight), limitedToNumberOfLines: titleLabel.numberOfLines).size
                    }
                    
                    break
                }
                
                titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: size.width, height: size.height)
            
        }
        
        if imageView?.image != nil && titleLabel?.text != nil {
            switch layoutStyle {
            case .LeftImageRightTitle:
                layoutHorizontalWithView(leftView: imageView!, rightView: titleLabel!)
                break
            case .LeftTitleRightImage:
                layoutHorizontalWithView(leftView: titleLabel!, rightView: imageView!)
                break
            case .UpImageDownTitle:
                layoutVerticalWithView(upView: imageView!, downView: titleLabel!)
                break
            case .UpTitleDownImage:
                layoutVerticalWithView(upView: titleLabel!, downView: imageView!)
                break
            }
        } else if imageView?.image != nil && titleLabel?.text == nil {
            imageView?.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        } else if imageView?.image == nil && titleLabel?.text != nil {
            titleLabel?.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        }
        
    }
    
    func layoutHorizontalWithView(leftView: UIView, rightView:UIView) {
        var leftViewFrame = leftView.frame
        var rightViewFrame = rightView.frame
        
        let totalWidth = leftViewFrame.size.width + midSpacing + rightViewFrame.size.width
        
        leftViewFrame.origin.x = (frame.size.width - totalWidth) / 2.0
        leftViewFrame.origin.y = (frame.size.height - leftViewFrame.size.height) / 2.0
        leftView.frame = leftViewFrame
        
        rightViewFrame.origin.x = leftViewFrame.origin.x + leftViewFrame.size.width + midSpacing
        rightViewFrame.origin.y = (frame.size.height - rightViewFrame.height) / 2.0
        rightView.frame = rightViewFrame
    }
    
    func layoutVerticalWithView(upView: UIView, downView: UIView) {
        var upViewFrame = upView.frame
        var downViewFrame = downView.frame
        
        let totalHeight = upViewFrame.size.height + midSpacing + downViewFrame.size.height
        
        upViewFrame.origin.y = (frame.size.height - totalHeight) / 2.0
        upViewFrame.origin.x = (frame.size.width - upViewFrame.size.width) / 2.0
        upView.frame = upViewFrame
        
        downViewFrame.origin.y = upViewFrame.origin.y + upViewFrame.size.height + midSpacing
        downViewFrame.origin.x = (frame.size.width - downViewFrame.size.width) / 2.0
        downView.frame = downViewFrame
    }
    
    open override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        setNeedsLayout()
    }
    
    open override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        setNeedsLayout()
    }
    
}



