//
//  HistoryDetailTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 09/01/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

class HistoryDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    var canSelect: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if canSelect {
            backgroundColor = (selected ? UIColor(named: "selectionColor") : .clear)
        }
    }

}
