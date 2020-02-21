//
//  LoadingCircle.swift
//  Financy
//
//  Created by Jakub Pazik on 02/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

@IBDesignable
class LoadingCircle: UIView {
    @IBInspectable var isAnimating: Bool = false {
        didSet {
            isAnimatingChanged()
        }
    }
    
    @IBInspectable var lightStyle: Bool = true {
        didSet {
            setIcon()
        }
    }
    
    private var imgView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
        isAnimatingChanged()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
        isAnimatingChanged()
    }
    
    private func isAnimatingChanged() {
        if isAnimating {
            if !isHidden {
                return
            }
            
            isHidden = false
            
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = Double.pi * 2.0
            rotationAnimation.duration = 0.84
            rotationAnimation.repeatCount = .infinity
            layer.add(rotationAnimation, forKey: nil)
        }
        else {
            isHidden = true
            imgView?.layer.removeAllAnimations()
        }
    }
    
    private func prepare() {
        backgroundColor = .clear
        setIcon()
    }
    
    private func setIcon() {
        if (imgView != nil) {
            imgView?.layer.removeAllAnimations()
            imgView?.removeFromSuperview()
        }
        
        imgView = UIImageView(image: UIImage(named: (lightStyle ? "LoadingIcon" : "LoadingIconB")))
        addSubview(imgView!)
        isAnimatingChanged()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
