//
//  MoreTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 07/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        backgroundColor = (!selected ? UIColor.clear : UIColor(named: "selectionColor"))
    }

}
