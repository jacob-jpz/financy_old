//
//  TwoBarChart.swift
//  Financy
//
//  Created by Jakub Pazik on 06/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

@IBDesignable class TwoBarChart: UIStackView {
    var incomesValue: Decimal = 0
    var outgoingsValue: Decimal = 0
    
    private var bars = [UIView]()
    private var placeholders = [UIView]()
    private var barWidth: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareBars()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        prepareBars()
    }
    
    private func prepareBars() {
        for plc in placeholders {
            removeArrangedSubview(plc)
            plc.removeFromSuperview()
        }
        placeholders.removeAll()
        bars.removeAll()
        
        barWidth = (frame.width - spacing) / 2.0
        
        let incomePlaceholder = UIView()
        incomePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        incomePlaceholder.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        incomePlaceholder.widthAnchor.constraint(equalToConstant: barWidth).isActive = true
        addArrangedSubview(incomePlaceholder)
        placeholders.append(incomePlaceholder)
        
        let incomeBar = UIView()
        incomeBar.translatesAutoresizingMaskIntoConstraints = false
        incomeBar.frame = CGRect(x: 0, y: frame.height, width: barWidth, height: 0)
        incomeBar.backgroundColor = UIColor(named: "greenBarColor")
        incomeBar.layer.shadowColor = incomeBar.backgroundColor?.cgColor //UIColor.green.cgColor
        incomeBar.layer.shadowRadius = 0
        incomeBar.layer.shadowOpacity = 0.45
        incomeBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        incomePlaceholder.addSubview(incomeBar)
        bars.append(incomeBar)
        
        let outgoPlaceholder = UIView()
        outgoPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        outgoPlaceholder.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        outgoPlaceholder.widthAnchor.constraint(equalToConstant: barWidth).isActive = true
        addArrangedSubview(outgoPlaceholder)
        placeholders.append(outgoPlaceholder)
        
        let outgoBar = UIView()
        outgoBar.translatesAutoresizingMaskIntoConstraints = false
        outgoBar.frame = CGRect(x: 0, y: frame.height, width: barWidth, height: 0)
        outgoBar.backgroundColor = UIColor(named: "mainFontColor")
        outgoBar.layer.shadowColor = outgoBar.backgroundColor?.cgColor //UIColor.red.cgColor
        outgoBar.layer.shadowRadius = 0
        outgoBar.layer.shadowOpacity = 0.45
        outgoBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        outgoPlaceholder.addSubview(outgoBar)
        bars.append(outgoBar)
    }
    
    func showBars(incomeValue: Decimal, outgoValue: Decimal, animated: Bool) {
        let total = incomeValue + outgoValue
        var income = (total > 0 ? CGFloat(exactly: NSDecimalNumber(decimal: incomeValue / total))! * frame.height : 0)
        var outgo = (total > 0 ? CGFloat(exactly: NSDecimalNumber(decimal: outgoValue / total))! * frame.height : 0)
        
        if income == 0 {
            income = 1
        }
        if outgo == 0 {
            outgo = 1
        }
        else if income == outgo {
            income = frame.height * 0.65
            outgo = income
        }
        else if outgo > income {
            if frame.height - outgo > frame.height * 0.16 {
                let moar = frame.height * 0.15
                outgo += moar
                income += moar
            }
        }
        else {
            if frame.height - income > frame.height * 0.16 {
                let moar = frame.height * 0.15
                outgo += moar
                income += moar
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.bars[0].frame = CGRect(x: 0, y: self.frame.height - income, width: self.barWidth, height: income)
                self.bars[1].frame = CGRect(x: 0, y: self.frame.height - outgo, width: self.barWidth, height: outgo)
            }, completion: { _ in
                if income > outgo {
                    self.bars[0].layer.shadowRadius = 4
                    self.bars[1].layer.shadowRadius = 0
                }
                else if outgo > income {
                    self.bars[0].layer.shadowRadius = 0
                    self.bars[1].layer.shadowRadius = 4
                }
                else {
                    self.bars[0].layer.shadowRadius = 4
                    self.bars[1].layer.shadowRadius = 4
                }
            })
        }
        else {
            bars[0].frame = CGRect(x: 0, y: frame.height - income, width: barWidth, height: income)
            bars[1].frame = CGRect(x: 0, y: frame.height - outgo, width: barWidth, height: outgo)
            
            if income > outgo {
                bars[0].layer.shadowRadius = 4
                bars[1].layer.shadowRadius = 0
            }
            else if outgo > income {
                bars[0].layer.shadowRadius = 0
                bars[1].layer.shadowRadius = 4
            }
            else {
                bars[0].layer.shadowRadius = 4
                bars[1].layer.shadowRadius = 4
            }
        }
    }
    
    func clearBars() {
        for bar in bars {
            bar.frame = CGRect(x: 0, y: frame.height, width: barWidth, height: 0)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
