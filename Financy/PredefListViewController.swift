//
//  PredefListViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 24/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class PredefListViewController: SwipeBackViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearchBar: SearchBar!
    
    private var foundIncomes = [PredefIncome]()
    private var foundOutgoings = [PredefOutgo]()
    private var isSearchActive = false
    
    enum ViewMode {
        case none, income, outgo
    }
    var viewMode: ViewMode = .none
    var parentChooser: PredefinedChooser?
    
    private var btnCloseBehavior: ImageButtonBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = true
        
        switch viewMode {
        case .income:
            lblTitle.text? = NSLocalizedString("predefInc", comment: "")
            
            if !StaticData.isIncomesLoaded {
                StaticData.loadPredefinedIncomes(completion: {
                    self.displayInTableView()
                })
            }
            else {
                displayInTableView()
            }
        case .outgo:
            lblTitle.text? = NSLocalizedString("predefOut", comment: "")
            
            if !StaticData.isOutgoingsLoaded {
                StaticData.loadPredefinedOutgoings(completion: {
                    self.displayInTableView()
                })
            }
            else {
                displayInTableView()
            }
        default:
            fatalError("No viewMode specified.")
        }
        
        if parentChooser == nil {
            fatalError("No parentChooser defined.")
        }
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.dismiss(animated: true, completion: nil)
        })
        
        txtSearchBar.placeholder = NSLocalizedString("search", comment: "")
        txtSearchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtSearchBar.txtSearch.becomeFirstResponder()
    }
    
    func searchTextDidChange(searchText: String) {
        DispatchQueue.global().async {
            let txt = searchText
            
            if self.viewMode == .outgo {
                if txt != "" {
                    self.isSearchActive = true
                    self.foundOutgoings = StaticData.predefinedOutgoings.filter({ outgo in
                        let name = (outgo.name ?? "").lowercased()
                        return name.hasPrefix(txt) || name.contains(txt)
                    })
                }
                else {
                    self.isSearchActive = false
                    self.foundOutgoings.removeAll()
                }
            }
            else {
                if txt != "" {
                    self.isSearchActive = true
                    self.foundIncomes = StaticData.predefinedIncomes.filter({ income in
                        let name = (income.name ?? "").lowercased()
                        return name.hasPrefix(txt) || name.contains(txt)
                    })
                }
                else {
                    self.isSearchActive = false
                    self.foundIncomes.removeAll()
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidCancel() {
        isSearchActive = false
        foundIncomes.removeAll()
        foundOutgoings.removeAll()
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func displayInTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewMode == .outgo {
            if isSearchActive {
                return foundOutgoings.count
            }
            else {
                return StaticData.predefinedOutgoings.count
            }
        }
        else {
            if isSearchActive {
                return foundIncomes.count
            }
            else {
                return StaticData.predefinedIncomes.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PredefListTableViewCell else {
            fatalError("Not a PredefListTableViewCell")
        }
        
        cell.selectionStyle = .none
        
        let index = indexPath.row
        if viewMode == .outgo {
            let item = (isSearchActive ? foundOutgoings[index] : StaticData.predefinedOutgoings[index])
            
            cell.lblPredef.text = item.name
            cell.imgPredef.image = Categories.getOutgoIconBy(index: item.category)
        }
        else {
            let item = (isSearchActive ? foundIncomes[index] : StaticData.predefinedIncomes[index])
            
            cell.lblPredef.text = item.name
            cell.imgPredef.image = Categories.getIncomeIconBy(index: item.category)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isIncome = (viewMode == .income)
        var idx = -1
        
        if !isSearchActive {
            idx = indexPath.row
        }
        else {
            if !isIncome {
                idx = StaticData.predefinedOutgoings.firstIndex(of: foundOutgoings[indexPath.row]) ?? -1
            }
            else {
                idx = StaticData.predefinedIncomes.firstIndex(of: foundIncomes[indexPath.row]) ?? -1
            }
        }
        
        if idx == -1 {
            return
        }
        
        parentChooser?.predefinedChosen(index: idx, isIncome: isIncome)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                self.parentChooser?.predefinedListClosed(isIncome: isIncome)
            })
        }
    }
}
