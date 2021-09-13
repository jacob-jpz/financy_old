//
//  PredefListTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 25/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class PredefListTableViewCell: UITableViewCell {
    @IBOutlet weak var imgPredef: UIImageView!
    @IBOutlet weak var lblPredef: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        backgroundColor = (highlighted ? UIColor(named: "selectionColor") : .clear)
    }
}
