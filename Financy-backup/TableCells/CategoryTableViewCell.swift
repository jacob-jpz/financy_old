//
//  CategoryTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 14/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var categoryValue: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//        
//    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = (!highlighted ? UIColor.clear : UIColor(named: "selectionColor"))
    }
}
