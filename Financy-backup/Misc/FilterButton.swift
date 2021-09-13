//
//  FilterButton.swift
//  Financy
//
//  Created by Jakub Pazik on 08/02/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

class FilterButton {
    private var background: UIImageView
    private var button: UIButton
    private var image: UIImageView
    private var chosen: Bool
    private var parent: FilterButtonsController
    private var name: String
    private var onChoose: () -> Void
    
    private var imgNormal: UIImage?
    private var imgWhite: UIImage?
    
    init(bckg: UIImageView, btn: UIButton, img: UIImageView, initiallyChosen: Bool, parent: FilterButtonsController, name: String, onChoose: @escaping (() -> Void)) {
        background = bckg
        button = btn
        image = img
        chosen = initiallyChosen
        self.parent = parent
        self.name = name
        self.onChoose = onChoose
        
        imgNormal = UIImage(named: name)
        imgWhite = UIImage(named: name + "W")
        
        button.addTarget(self, action: #selector(filterTouchUp(sender:)), for: .touchUpInside)
    }
    
    @objc private func filterTouchUp(sender: Any) {
        if chosen {
            return
        }
        
        parent.setAllButonsUnchosen()
        
        UIView.animate(withDuration: 0.12, animations: {
            self.background.alpha = 1
        })
        
        button.setTitleColor(.white, for: .normal)
        image.image = imgWhite
        chosen = true
        
        onChoose()
    }
    
    func setUnchosen() {
        if !chosen {
            return
        }
        
        background.alpha = 0
        button.setTitleColor(UIColor(named: "secondFontColor"), for: .normal)
        image.image = imgNormal
        chosen = false
    }
}
