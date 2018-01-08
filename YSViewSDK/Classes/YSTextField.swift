//
//  YSTextField.swift
//  YSTextField
//
//  Created by 605055291@qq.com on 01/06/2018.
//  Copyright (c) 2018 605055291@qq.com. All rights reserved.
//

import Foundation
import UIKit

// MARK: - YSTextFieldDelegate

@objc public protocol YSTextFieldDelegate : NSObjectProtocol {
    
    @objc optional func textFieldDidReachMaxLength(textField: YSTextField)
    
    @objc optional func textFieldDidTextChange(textField: YSTextField, count: Int)
}


open class YSTextField: UITextField, UITextFieldDelegate {

    lazy internal var counterLabel: UILabel = UILabel()
    
    weak open var ysDelegate: YSTextFieldDelegate?
    
    // MARK: IBInspectable: Limits and behaviors
    
    /// 字数动画
    @IBInspectable public dynamic var animate : Bool = true
    
    /// 字数上升
    @IBInspectable public dynamic var ascending : Bool = true
    
    /// 字数限制
    @IBInspectable public var maxLength : Int = YSTextField.defaultLength {
        didSet {
            if (!isValidMaxLength(max: maxLength)) {
                maxLength = YSTextField.defaultLength
            }
        }
    }
    
    /// 显示字数
    @IBInspectable public dynamic var showLimit: Bool = false {
        didSet {
            if showLimit {
                counterLabel.isHidden = false
                rightView = counterLabel
                rightViewMode = .whileEditing
            } else {
                counterLabel.isHidden = true
                rightView = nil
                rightViewMode = .whileEditing
            }
        }
    }
    
    @IBInspectable public dynamic var padding: UIEdgeInsets = .zero
    
    ///
    @IBInspectable public dynamic var counterColor : UIColor = .lightGray
    @IBInspectable public dynamic var limitColor: UIColor = .red
    
    // MARK: Enumerations and Constants
    
    enum AnimationType {
        case basic
        case didReachLimit
        case unknown
    }
    
    static let defaultLength = 100
    
    // MARK: Init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.delegate = self
        counterLabel = setupCounterLabel()
    }
    
    override open func draw(_ rect: CGRect) {
        _ = self.textRect(forBounds: rect)
        super.draw(rect)
        
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding.left, y: bounds.origin.y + padding.top, width: bounds.size.width - padding.right, height: bounds.size.height - padding.bottom)
    }
    
    // MARK: Public Methods
    
    /**
     Initializes a new beautiful *YSTextField*.
     
     - parameter frame: The frame of view.
     - parameter animate: Default is `true`.
     - parameter ascending: Default is `true`.
     - parameter limit: By default, if the number is not greater than 0, the limit will be `30`.
     - parameter counterColor: Default color is `UIColor.lightGray`.
     - parameter limitColor: Default color is `UIColor.red`.
    */
    
    public init(frame: CGRect, limit: Int, animate: Bool = true, ascending: Bool = true, counterColor: UIColor = .lightGray, limitColor: UIColor = .red) {
        
        super.init(frame: frame)
        
        if !isValidMaxLength(max: limit) {
            maxLength = YSTextField.defaultLength
        } else {
            maxLength = limit
        }
        
        self.animate = animate
        self.ascending = ascending
        self.counterColor = counterColor
        self.limitColor = limitColor
        

        
        super.delegate = self
        counterLabel = setupCounterLabel()
    }
    
    // MARK: Private Methods
    
    private func isValidMaxLength(max: Int) -> Bool {
        return max > 0
    }
    
    private func setupCounterLabel() -> UILabel {
        
        let fontFrame : CGRect = CGRect(x: 0, y: 0, width: counterLabelWidth(), height: Int(frame.height))
        let label : UILabel = UILabel(frame: fontFrame)
        
        if let currentFont : UIFont = font {
            label.font = currentFont
            label.textColor = counterColor
            label.textAlignment = label.userInterfaceLayoutDirection == .rightToLeft ? .right : .left
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 1
        }
        
        return label
    }
    
    private func localizedString(of number: Int) -> String {
        return String.localizedStringWithFormat("%i", number)
    }
    
    private func counterLabelWidth() -> Int {
        let biggestText = localizedString(of: maxLength)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.lineBreakMode = .byWordWrapping
        
        var size : CGSize = CGSize()
        
        if let currentFont = font {
            /**
             swift 3.0 :
             size = (biggestText as NSString).size(attributes: [NSFontAttributeName: currentFont, NSParagraphStyleAttributeName: paragraph])
             */
            
            size = biggestText.size(withAttributes: [NSAttributedStringKey.font: currentFont, NSAttributedStringKey.paragraphStyle: paragraph])
        }
        
        return Int(size.width) + 15
    }
    
    private func updateCounterLabel(count: Int) {
        if !showLimit {
            return
        }
        
        if count <= maxLength {
            if (ascending) {
                counterLabel.text = localizedString(of: count)
            } else {
                counterLabel.text = localizedString(of: maxLength - count)
            }
        }
        
        prepareToAnimateCounterLabel(count: count)
    }
    
    private func textFieldCharactersCount(textField: UITextField, string: String, changeCharactersIn range: NSRange) -> Int {
        
        var textFieldCharactersCount = 0
        
        if let textFieldText = textField.text {
            
            if !string.isEmpty {
                textFieldCharactersCount = textFieldText.count + string.count - range.length
            } else {
                textFieldCharactersCount = textFieldText.count - range.length
            }
        }
        
        return textFieldCharactersCount
    }
    
    private func checkIfNeedsCallDidReachMaxLengthDelegate(count: Int) {
        if (count >= maxLength) {
            if let delegate = ysDelegate {
                if delegate.responds(to: #selector(YSTextFieldDelegate.textFieldDidReachMaxLength(textField:))) {
                    delegate.textFieldDidReachMaxLength!(textField: self)
                }
            }
        }
    }

    // MARK: - Animations
    
    private func prepareToAnimateCounterLabel(count: Int) {
        
        var animationType : AnimationType = .unknown
        
        if (count >= maxLength) {
            animationType = .didReachLimit
        } else if (count <= maxLength) {
            animationType = .basic
        }
        
        animateTo(type: animationType)
    }
    
    private func animateTo(type: AnimationType) {
        
        switch type {
        case .basic:
            animateCounterLabelColor(color: counterColor)
        case .didReachLimit:
            animateCounterLabelColor(color: limitColor)
            
            if #available(iOS 10.0, *) {
                fireHapticFeedback()
            }
            
            if (animate) {
                counterLabel.shakeTo(transform: CGAffineTransform(translationX: 5, y: 0), duration: 0.3)
            }
        default:
            break
        }
    }
    
    private func animateCounterLabelColor(color: UIColor) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.counterLabel.textColor = color
        }, completion: nil)
    }
    
    // MARK: - Haptic Feedback
    
    private func fireHapticFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var shouldChange = false
        let charactersCount = textFieldCharactersCount(textField: textField, string: string, changeCharactersIn: range)
        
        if string.isEmpty {
            shouldChange = true
        } else {
            shouldChange = charactersCount <= maxLength
        }
        
        
        
        updateCounterLabel(count: charactersCount)
        checkIfNeedsCallDidReachMaxLengthDelegate(count: charactersCount)
        
        if shouldChange {
            if let delegate = ysDelegate {
                if delegate.responds(to: #selector(YSTextFieldDelegate.textFieldDidTextChange(textField:count:))) {
                    delegate.textFieldDidTextChange!(textField: self, count: charactersCount)
                }
            }
        }
        
        
        return shouldChange
    }
    
}


// MARK: - Extensions

extension UIView {
    
    public func shakeTo(transform: CGAffineTransform, duration: TimeInterval) {
        
        self.transform = transform
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        if #available(iOS 9.0, *) {
            return UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        } else {
            return UIApplication.shared.userInterfaceLayoutDirection
        }
    }
    
}
