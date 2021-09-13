//
//  CategoriesListViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 14/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class CategoriesListViewController: SwipeBackViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var categoriesTable: UITableView!
    
    enum ViewMode {
        case none, income, outgo
    }
    var viewMode: ViewMode = .none
    
    var parentChooser: CategoryChooser?
    private var btnCloseBehavior: ImageButtonBehavior?
    private var catList = [String]()
    private var iconsList = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        switch viewMode {
        case .income:
            catList = Categories.incomeNames
            
            //pobranie listy ikon na podstawie tabeli nazw
            for i in 0..<catList.count {
                iconsList.append(Categories.getIncomeIconBy(index: Int16(exactly: i)!))
            }
        case .outgo:
            catList = Categories.outgoNames
            
            //pobranie listy ikon na podstawie tabeli nazw
            for i in 0..<catList.count {
                iconsList.append(Categories.getOutgoIconBy(index: Int16(exactly: i)!))
            }
        default:
            fatalError("ViewMode has not been specified.")
        }
        
        if parentChooser == nil {
            fatalError("No parent of chooser has been provided.")
        }
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.dismiss(animated: true, completion: nil)
        })
        
        isModal = true
        
        categoriesTable.dataSource = self
        categoriesTable.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chosenCell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else {
            fatalError("Chosen cell is not CategoryTableViewCell.")
        }
        
        let isIncome = (viewMode == .income)
        parentChooser?.categoryChosen(value: chosenCell.categoryValue, isIncome: isIncome)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.parentChooser?.categoryListClosed(isIncome: isIncome)
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as? CategoryTableViewCell else {
            fatalError("Cell is not CategoryTableViewCell.")
        }
        cell.selectionStyle = .none
        
        var index = indexPath.row + 1
        
        if index >= catList.count {
            index = 0
        }
        
        cell.imgIcon.image = iconsList[index]
        cell.lblName.text = catList[index]
        cell.categoryValue = index
        
        return cell
    }
}
