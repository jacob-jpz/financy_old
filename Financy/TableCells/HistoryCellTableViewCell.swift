//
//  HistoryCellTableViewCell.swift
//  Financy
//
//  Created by Jakub Pazik on 06/01/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

class HistoryCellTableViewCell: UITableViewCell {
    @IBOutlet weak var chart: TwoBarChart!
    @IBOutlet weak var lblMonthName: UILabel!
    @IBOutlet weak var lblIncomes: UILabel!
    @IBOutlet weak var lblOutgoings: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        backgroundColor = (selected ? UIColor(named: "selectionColor") : .clear)
    }
}
