//
//  PredefinedTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 17/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class PredefinedTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    
    private var isSelectingState: Bool = false
    var isChosen: Bool = false //flaga informująca o stanie zaznaczenia (do usunięcia)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if !isSelectingState {
            backgroundColor = (!highlighted ? UIColor.clear : UIColor(named: "selectionColor"))
        }
    }
    
    func changeChosenState() {
        if isSelectingState {
            //animacja zmiany zaznaczenia
            isChosen = !isChosen
            
            let originalTransform = imgSelected.transform
            imgSelected.transform = originalTransform.scaledBy(x: 0.8, y: 0.8)
            imgSelected.image = UIImage(named: (isChosen ? "Selected" : "Unselected"))
            
            backgroundColor = (!isChosen ? UIColor.clear : UIColor(named: "selectionColor"))
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                self.imgSelected.transform = originalTransform
            }, completion: nil)
        }
    }

    func setSelectionState(selecting: Bool) {
        backgroundColor = UIColor.clear
        
        if selecting {
            isSelectingState = true
            imgSelected.alpha = 0
            imgSelected.isHidden = false
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imgSelected.alpha = 1
            }, completion: nil)
        }
        else {
            isSelectingState = false
            isChosen = false
            imgSelected.isHidden = true
            imgSelected.image = UIImage(named: "Unselected")
        }
    }
}
