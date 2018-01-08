//
//  YSTextView.swift
//  YSTextView
//
//  Created by 605055291@qq.com on 01/06/2018.
//  Copyright (c) 2018 605055291@qq.com. All rights reserved.
//

import UIKit
import Foundation

// MARK: - YSTextFieldDelegate

@objc public protocol YSTextViewDelegate: NSObjectProtocol {
    @objc optional func textViewDidReachMaxLength(textView: YSTextView)
    
    @objc optional func textViewDidTextChange(textView: YSTextView, count: Int)
}


//@objc(YSTextView)
open class YSTextView: UITextView {
    
    weak open var ysDelegate: YSTextViewDelegate?
    
    // MARK: - Private Properties
    
    private let placeholderView = UITextView(frame: CGRect.zero)
    
    // MARK: - Placeholder Properties
    
    /// This property applies to the entire placeholder string. 
    /// The default placeholder color is 70% gray.
    ///
    /// If you want to apply the color to only a portion of the placeholder,
    /// you must create a new attributed string with the desired style information 
    /// and assign it to the attributedPlaceholder property.
    @IBInspectable public var placeholderTextColor: UIColor? {
        get {
            return placeholderView.textColor
        }
        set {
            placeholderView.textColor = newValue
        }
    }
    
    /// The string that is displayed when there is no other text in the text view.
    @IBInspectable public var placeholder: String? {
        get {
            return placeholderView.text
        }
        set {
            placeholderView.text = newValue
            setNeedsLayout()
        }
    }
    
    /// This property controls when the placeholder should hide.
    /// Setting it to `true` will hide the placeholder right after the text view 
    /// becomes first responder. Setting it to `false` will hide the placeholder
    /// only when the user starts typing in the text view. 
    
    /// Default value is `false`
    @IBInspectable public var hidesPlaceholderWhenEditingBegins: Bool = false
    
    /// The styled string that is displayed when there is no other text in the text view.
    public var attributedPlaceholder: NSAttributedString? {
        get {
            return placeholderView.attributedText
        }
        set {
            placeholderView.attributedText = newValue
            setNeedsLayout()
        }
    }
    
    /// Returns true if the placeholder is currently showing.
    public var isShowingPlaceholder: Bool {
        return placeholderView.superview != nil
    }
    
    // MARK: - Observed Properties
    
    override open var text: String! {
        didSet {
            showPlaceholderViewIfNeeded()
        }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            showPlaceholderViewIfNeeded()
        }
    }
    
    override open var font: UIFont? {
        didSet {
            placeholderView.font = font
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            placeholderView.textAlignment = textAlignment
        }
    }
    
    override open var textContainerInset: UIEdgeInsets {
        didSet {
            placeholderView.textContainerInset = textContainerInset
        }
    }
    
    // MARK: IBInspectable: Limits and behaviors
    
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
            
        }
    }
    
    @IBInspectable public dynamic var padding: UIEdgeInsets = .zero
    
    @IBInspectable public dynamic var counterColor : UIColor = .lightGray
    @IBInspectable public dynamic var limitColor: UIColor = .red
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholderView()
        self.delegate = self
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderView()
        self.delegate = self
        
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
            label.adjustsFontSizeToFitWidth = true
        }
        
        return label
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Notification
    
    @objc func textDidChange(notification: NSNotification) {
        showPlaceholderViewIfNeeded()
    }
    
    @objc func textViewDidBeginEditing(notification: NSNotification) {
        if hidesPlaceholderWhenEditingBegins && isShowingPlaceholder {
            placeholderView.removeFromSuperview()
            invalidateIntrinsicContentSize()
            setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    @objc func textViewDidEndEditing(notification: NSNotification) {
        if hidesPlaceholderWhenEditingBegins {
            if !isShowingPlaceholder && (text == nil || text.isEmpty) {
                addSubview(placeholderView)
                invalidateIntrinsicContentSize()
                setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    
    // MARK: - UIView
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        resizePlaceholderView()
    }
    
    open override var intrinsicContentSize: CGSize {
        if isShowingPlaceholder {
            return placeholderSize()
        }
        return super.intrinsicContentSize
    }
    
    // MARK: - Placeholder
    
    private func setupPlaceholderView() {
        placeholderView.isOpaque = false
        placeholderView.backgroundColor = UIColor.clear
        placeholderView.textColor = UIColor(white: 0.7, alpha: 1.0)
        
        placeholderView.isEditable = false
        placeholderView.isScrollEnabled = true
        placeholderView.isUserInteractionEnabled = false
        placeholderView.isAccessibilityElement = false
        placeholderView.isSelectable = false
        
        showPlaceholderViewIfNeeded()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(textDidChange(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        notificationCenter.addObserver(self, selector: #selector(textViewDidBeginEditing(notification:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self)
        notificationCenter.addObserver(self, selector: #selector(textViewDidEndEditing(notification:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
    }
    
    private func showPlaceholderViewIfNeeded() {
        if !hidesPlaceholderWhenEditingBegins {
            if text != nil && !text.isEmpty {
                if isShowingPlaceholder {
                    placeholderView.removeFromSuperview()
                    invalidateIntrinsicContentSize()
                    setContentOffset(CGPoint.zero, animated: false)
                }
                
            } else {
                if !isShowingPlaceholder {
                    addSubview(placeholderView)
                    invalidateIntrinsicContentSize()
                    setContentOffset(CGPoint.zero, animated: false)
                }
            }
        }
    }
    
    private func resizePlaceholderView() {
        if isShowingPlaceholder {
            let size = placeholderSize()
            let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            
            if !placeholderView.frame.equalTo(frame) {
                placeholderView.frame = frame
                invalidateIntrinsicContentSize()
            }
            
            contentInset = UIEdgeInsetsMake(0.0, 0.0, size.height - contentSize.height, 0.0)
        } else {
            contentInset = UIEdgeInsets.zero
        }
    }
    
    private func placeholderSize() -> CGSize {
        var maxSize = self.bounds.size
        maxSize.height = CGFloat.greatestFiniteMagnitude
        return placeholderView.sizeThatFits(maxSize)
    }
    
    private func isValidMaxLength(max: Int) -> Bool {
        return max > 0
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
}

extension YSTextView: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldChange = false
        let charactersCount = textViewCharactersCount(textView: textView, string: text, changeCharactersIn: range)
        
        if text.isEmpty {
            shouldChange = true
        } else {
            shouldChange = charactersCount <= maxLength
        }
        
        updateCounterLabel(count: charactersCount)
        checkIfNeedsCallDidReachMaxLengthDelegate(count: charactersCount)
        
        if shouldChange {
            if let delegate = ysDelegate {
                if delegate.responds(to: #selector(YSTextViewDelegate.textViewDidTextChange(textView:count:))) {
                    delegate.textViewDidTextChange!(textView: self, count: charactersCount)
                }
            }
        }
        
        
        return shouldChange
    }
        
    private func textViewCharactersCount(textView: UITextView, string: String, changeCharactersIn range: NSRange) -> Int {

        var textFieldCharactersCount = 0

        if let textFieldText = textView.text {

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
                if delegate.responds(to: #selector(YSTextViewDelegate.textViewDidReachMaxLength(textView:))) {
                    delegate.textViewDidReachMaxLength!(textView: self)
                }
            }
        }
    }
    
    private func updateCounterLabel(count: Int) {
        if !showLimit {
            return
        }
        
        if count <= maxLength {
            if (ascending) {
                //counterLabel.text = localizedString(of: count)
            } else {
                //counterLabel.text = localizedString(of: maxLength - count)
            }
        }
        
        //prepareToAnimateCounterLabel(count: count)
    }
}



