//
//  Categories.swift
//  Financy
//
//  Created by Jakub Pazik on 14/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class Categories {
    enum IncomeCategory: Int16 {
        case other = 0, salary = 1, stuffSale = 2, gift = 3, moneyBack = 4
    }
    static let incomeNames = [NSLocalizedString("catOther", comment: ""), NSLocalizedString("catSalary", comment: ""),
                              NSLocalizedString("catSale", comment: ""), NSLocalizedString("catGift", comment: ""),
                              NSLocalizedString("catMoneyBack", comment: "")]
    
    static func getIncomeIconBy(category: IncomeCategory) -> UIImage? {
        switch category {
        case .other:
            return UIImage(named: "CatOther")
        case .salary:
            return UIImage(named: "CatSalary")
        case .stuffSale:
            return UIImage(named: "CatStuffSale")
        case .gift:
            return UIImage(named: "CatGift")
        case .moneyBack:
            return nil
        }
    }
    
    static func getIncomeIconBy(index: Int16) -> UIImage? {
        switch index {
        case 0:
            return UIImage(named: "CatOther")
        case 1:
            return UIImage(named: "CatSalary")
        case 2:
            return UIImage(named: "CatStuffSale")
        case 3:
            return UIImage(named: "CatGift")
        case 4:
            return UIImage(named: "CatMoneyBack")
        default:
            fatalError("Invalid index has been given: \(index)")
        }
    }
    
    enum OutgoCategory: Int16 {
        case other = 0, entertainment = 1, grocery = 2, clothes = 3, shopping = 4, recreation = 5, bills = 6
    }
    static let outgoNames = [NSLocalizedString("catOther", comment: ""), NSLocalizedString("catEntertain", comment: ""),
                             NSLocalizedString("catGrocery", comment: ""), NSLocalizedString("catClothes", comment: ""),
                             NSLocalizedString("catShopping", comment: ""), NSLocalizedString("catRecreation", comment: ""),
                             NSLocalizedString("catBills", comment: "")]
    
    static func getOutgoIconBy(category: OutgoCategory) -> UIImage? {
        switch category {
        case .other:
            return UIImage(named: "CatOther")
        case .entertainment:
            return UIImage(named: "CatEntertainment")
        case .grocery:
            return UIImage(named: "CatGrocery")
        case .clothes:
            return UIImage(named: "CatClothes")
        case .shopping:
            return UIImage(named: "CatShopping")
        case .recreation:
            return UIImage(named: "CatRecreation")
        case .bills:
            return UIImage(named: "CatBills")
        }
    }
    
    static func getOutgoIconBy(index: Int16) -> UIImage? {
        switch index {
        case 0:
            return UIImage(named: "CatOther")
        case 1:
            return UIImage(named: "CatEntertainment")
        case 2:
            return UIImage(named: "CatGrocery")
        case 3:
            return UIImage(named: "CatClothes")
        case 4:
            return UIImage(named: "CatShopping")
        case 5:
            return UIImage(named: "CatRecreation")
        case 6:
            return UIImage(named: "CatBills")
        default:
            fatalError("Invalid index has been given: \(index)")
        }
    }
}
