//
//  UIStatic.swift
//  Financy
//
//  Created by Jakub Pazik on 29/11/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class ImageButtonBehavior {
    private var button: UIButton
    private var onTouch: (() -> Void)
    
    init(_ btn: UIButton, onTouch: @escaping (() -> Void)) {
        button = btn
        self.onTouch = onTouch
        
        button.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(sender:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchCancel(sender:)), for: .touchCancel)
    }
    
    @objc private func buttonTouchDown(sender: Any) {
        button.alpha = 0.8
    }
    
    @objc private func buttonTouchUp(sender: Any) {
        UIView.animate(withDuration: 0.16, animations: {
            self.button.alpha = 1
        })
        
        onTouch()
    }
    
    @objc private func buttonTouchCancel(sender: Any) {
        UIView.animate(withDuration: 0.16, animations: {
            self.button.alpha = 1
        })
    }
}
