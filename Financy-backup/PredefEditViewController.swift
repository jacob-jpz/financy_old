//
//  PredefEditViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 14/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class PredefEditViewController: SwipeBackViewController, UITextFieldDelegate, CategoryChooser {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCategoryName: UILabel!
    @IBOutlet weak var imgCategoryIcon: UIImageView!
    
    private var btnCloseBehavior: ImageButtonBehavior?
    private var btnAcceptBehavior: ImageButtonBehavior?
    var chosenCategoryValue = -1
    
    enum ViewMode {
        case none, new, edit
    }
    var viewMode: ViewMode = .none
    
    enum DataKind {
        case none, income, outgo
    }
    var dataKind: DataKind = .none
    
    var startingName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch viewMode {
        case .new:
            isModal = true
            lblTitle.text = NSLocalizedString("new", comment: "") //"New "
        case .edit:
            isModal = false
            lblTitle.text = NSLocalizedString("edit", comment: "") //"Edit "
            
            txtName.text = startingName
            categoryChosen(value: chosenCategoryValue, isIncome: (dataKind == .income))
        default:
            fatalError("ViewMode has not been chosen.")
        }
        
        switch dataKind {
        case .income:
            lblTitle.text? += NSLocalizedString("inc", comment: "") //"income"
        case .outgo:
            lblTitle.text? += NSLocalizedString("out", comment: "") //"outgo"
        default:
            fatalError("DataKind has not been chosen.")
        }
        
        btnAcceptBehavior = ImageButtonBehavior(btnAccept, onTouch: {
            //nic się nie dzieje - jest podpięty unwind
        })
        
        txtName.delegate = self
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        txtName.becomeFirstResponder()
    }
    
    func categoryChosen(value: Int, isIncome: Bool) {
        //czynności po wybraniu kategorii
        chosenCategoryValue = value
        
        if isIncome {
            txtCategoryName.text = Categories.incomeNames[value]
            imgCategoryIcon.image = Categories.getIncomeIconBy(index: Int16(exactly: value)!)
        }
        else {
            txtCategoryName.text = Categories.outgoNames[value]
            imgCategoryIcon.image = Categories.getOutgoIconBy(index: Int16(exactly: value)!)
        }
    }
    
    func categoryListClosed(isIncome: Bool) {
        //nic nie robię
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            guard let catList = segue.destination as? CategoriesListViewController else {
                fatalError("Destination is not an instance of CategoriesListViewController.")
            }
            
            catList.parentChooser = self
            catList.viewMode = (dataKind == .income ? CategoriesListViewController.ViewMode.income : CategoriesListViewController.ViewMode.outgo)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwind" {
            txtName.text = txtName.text?.trimmingCharacters(in: .whitespaces)
            if txtName.text == "" {
                let alertController = UIAlertController(title: "Stop", message: NSLocalizedString("nameErr", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { c in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                alertController.view.tintColor = UIColor(named: "mainFontColor")
                present(alertController, animated: true)
                
                return false
            }
            
            //sprawdzenie czy istnieje już wpis pod taką nazwą
            if startingName != txtName.text {
                var sameNameIdx: Int?
                let nameLower = txtName.text?.lowercased()
                
                if dataKind == .income {
                    sameNameIdx = StaticData.predefinedIncomes.firstIndex(where: { income in income.name?.lowercased() == nameLower })
                }
                else {
                    sameNameIdx = StaticData.predefinedOutgoings.firstIndex(where: { outgo in outgo.name?.lowercased() == nameLower })
                }
                
                if sameNameIdx != nil {
                    let alertController = UIAlertController(title: "Stop", message: NSLocalizedString("sameNameErr", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        alertController.dismiss(animated: true, completion: nil)
                    }))
                    alertController.view.tintColor = UIColor(named: "mainFontColor")
                    present(alertController, animated: true)
                    
                    return false
                }
            }
            
            if chosenCategoryValue == -1 {
                let alertController = UIAlertController(title: "Stop", message: NSLocalizedString("catErr", comment: ""), preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { c in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                alertController.view.tintColor = UIColor(named: "mainFontColor")
                present(alertController, animated: true)
                
                return false
            }
        }
        
        return true
    }
}
