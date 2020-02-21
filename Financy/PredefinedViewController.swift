//
//  PredefinedViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 11/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit
import CoreData

class PredefinedViewController: SwipeBackViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnAddDelete: UIButton!
    @IBOutlet weak var btnSelectCancel: UIButton!
    @IBOutlet weak var lblSelectedCount: UILabel!
    @IBOutlet weak var predefTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    enum ViewMode {
        case none, incomes, outgoings
    }
    var viewMode: ViewMode = .none
    
    private var btnCloseBehavior: ImageButtonBehavior?
    private var firstShowDone = false
    private var goneEditing = false
    private var isSelectingMode = false
    private var selectedCount = 0
    private var elementsCount = 0
    
    private var editedIncome: PredefIncome?
    private var editedOutgo: PredefOutgo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = false
        
        switch viewMode {
        case .incomes:
            lblTitle.text = NSLocalizedString("predefInc", comment: "") //"Predefined incomes"
        case .outgoings:
            lblTitle.text = NSLocalizedString("predefOut", comment: "") //"Predefined outgoings"
        default:
            fatalError("ViewMode has not been set.")
        }
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.navigationController?.popViewController(animated: true)
        })
        
        btnAddDelete.addTarget(self, action: #selector(btnAddDelete_TouchUp(sender:)), for: .touchUpInside)
        btnSelectCancel.addTarget(self, action: #selector(btnSelectCancel_TouchUp(sender:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstShowDone) {
            return
        }
        firstShowDone = true
        
        //załadowanie danych i umieszczenie w tableView
        switch viewMode {
        case .incomes:
            if !StaticData.isIncomesLoaded {
                loadPredefIncomes()
            }
            else {
                tableViewPreShow()
                displayInTableView()
            }
        case .outgoings:
            if !StaticData.isOutgoingsLoaded {
                loadPredefOutgoings()
            }
            else {
                tableViewPreShow()
                displayInTableView()
            }
        default:
            print("none...")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if goneEditing {
            goneEditing = false
            
            let selectedIndexPath = tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                tableView.deselectRow(at: selectedIndexPath!, animated: false)
            }
        }
    }
    
    private func tableViewPreShow() {
        predefTableView.alpha = 0
        predefTableView.isHidden = false
    }
    
    private func loadPredefIncomes() {
        view.isUserInteractionEnabled = false
        tableViewPreShow()
        
        StaticData.loadPredefinedIncomes(completion: {
            self.displayInTableView()
        })
    }
    
    private func loadPredefOutgoings() {
        view.isUserInteractionEnabled = false
        tableViewPreShow()
        
        StaticData.loadPredefinedOutgoings(completion: {
            self.displayInTableView()
        })
    }
    
    private func displayInTableView() {
        view.isUserInteractionEnabled = true
        
        if viewMode == .incomes {
            elementsCount = StaticData.predefinedIncomes.count
        }
        else {
            elementsCount = StaticData.predefinedOutgoings.count
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.24, delay: 0, options: .curveLinear, animations: {
            self.predefTableView.alpha = 1
        }, completion: nil)
    }
    
    @objc private func btnAddDelete_TouchUp(sender: Any) {
        if !isSelectingMode {
            //dodawanie
            guard let newPredef = storyboard?.instantiateViewController(withIdentifier: "newPredef") as? PredefEditViewController else {
                fatalError("newPredef view controller is not an instance of PredefEditViewController")
            }
            newPredef.viewMode = .new
            newPredef.dataKind = (viewMode == .incomes ? PredefEditViewController.DataKind.income : PredefEditViewController.DataKind.outgo)
            
            editedOutgo = nil
            editedIncome = nil
            
            present(newPredef, animated: true)
        }
        else {
            //usuwanie
            if selectedCount == 0 {
                return
            }
            
            let alertController = UIAlertController(title: NSLocalizedString("deling", comment: ""), message: NSLocalizedString("delMsg1", comment: "") + String(selectedCount) + NSLocalizedString("delMsg2", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("del", comment: ""), style: .destructive, handler: { _ in
                self.view.isUserInteractionEnabled = false
                //usunięcie z bazy
                if self.viewMode == .incomes {
                    for i in 0..<self.elementsCount {
                        guard let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PredefinedTableViewCell else {
                            return
                        }
                        
                        if !cell.isChosen {
                            continue
                        }
                        
                        AppDelegate.managedContext?.delete(StaticData.predefinedIncomes[i])
                    }
                    
                    do {
                        try AppDelegate.managedContext?.save()
                    }
                    catch {
                        fatalError("Deleting incomes error: \(error)")
                    }
                    
                    self.loadPredefIncomes()
                }
                else {
                    for i in 0..<self.elementsCount {
                        guard let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? PredefinedTableViewCell else {
                            return
                        }
                        
                        if !cell.isChosen {
                            continue
                        }
                        
                        AppDelegate.managedContext?.delete(StaticData.predefinedOutgoings[i])
                    }
                    
                    do {
                        try AppDelegate.managedContext?.save()
                    }
                    catch {
                        fatalError("Deleting outgoings error: \(error)")
                    }
                    
                    self.loadPredefOutgoings()
                }
                
                self.btnSelectCancel_TouchUp(sender: sender)
                self.view.isUserInteractionEnabled = true
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            alertController.view.tintColor = UIColor(named: "mainFontColor")
            
            present(alertController, animated: true)
        }
    }
    
    @objc private func btnSelectCancel_TouchUp(sender: Any) {
        if !isSelectingMode {
            //wejście w tryb zaznaczania
            UIView.performWithoutAnimation {
                btnAddDelete.setTitle(NSLocalizedString("del", comment: ""), for: .normal)
                btnAddDelete.layoutIfNeeded()
                btnSelectCancel.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
                btnSelectCancel.layoutIfNeeded()
            }
            lblSelectedCount.isHidden = false
            isSelectingMode = true
        }
        else {
            //wyjście z trybu zaznaczania
            UIView.performWithoutAnimation {
                btnAddDelete.setTitle(NSLocalizedString("add", comment: ""), for: .normal)
                btnAddDelete.layoutIfNeeded()
                btnSelectCancel.setTitle(NSLocalizedString("select", comment: ""), for: .normal)
                btnSelectCancel.layoutIfNeeded()
            }
            lblSelectedCount.isHidden = true
            lblSelectedCount.text = "0"
            isSelectingMode = false
            selectedCount = 0
        }
        
        //ustawienie wszystkich wierszy w tryb zaznaczania
        for i in 0..<elementsCount {
            let idxPath = IndexPath(row: i, section: 0)
            guard let cell = tableView.cellForRow(at: idxPath) as? PredefinedTableViewCell else {
                fatalError("Cell is not an instance of PredefinedTableViewCell (2)")
            }
            
            cell.setSelectionState(selecting: isSelectingMode)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PredefinedTableViewCell else {
            fatalError("Cell is not an instance of PredefinedTableViewCell (3)")
        }
        
        if !isSelectingMode {
            if viewMode == .incomes {
                editedIncome = StaticData.predefinedIncomes[indexPath.row]
            }
            else {
                editedOutgo = StaticData.predefinedOutgoings[indexPath.row]
            }
            
            performSegue(withIdentifier: "predefEdit", sender: nil)
        }
        else {
            cell.changeChosenState()
            
            if cell.isChosen {
                selectedCount += 1
            }
            else {
                selectedCount -= 1
            }
            
            lblSelectedCount.text = String(selectedCount)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elementsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "predefCell") as? PredefinedTableViewCell else {
            fatalError("Cell is not an instance of PredefinedTableViewCell")
        }
        
        let idx = indexPath.row
        
        switch viewMode {
        case .incomes:
            cell.lblName.text = StaticData.predefinedIncomes[idx].name
            cell.imgIcon.image = Categories.getIncomeIconBy(index: StaticData.predefinedIncomes[idx].category)
        case .outgoings:
            cell.lblName.text = StaticData.predefinedOutgoings[idx].name
            cell.imgIcon.image = Categories.getOutgoIconBy(index: StaticData.predefinedOutgoings[idx].category)
        case .none:
            print("none...")
        }
        
        cell.selectionStyle = .none
//        cell.lblName.text = "Test"
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predefEdit" {
            guard let predefEdit = segue.destination as? PredefEditViewController else {
                fatalError("Segue destination is not PredefEditViewController")
            }
            
            predefEdit.viewMode = .edit
            
            if viewMode == .incomes {
                predefEdit.dataKind = .income
                predefEdit.startingName = editedIncome?.name
                predefEdit.chosenCategoryValue = Int(editedIncome!.category)
            }
            else {
                predefEdit.dataKind = .outgo
                predefEdit.startingName = editedOutgo?.name
                predefEdit.chosenCategoryValue = Int(editedOutgo!.category)
            }
            
            goneEditing = true
        }
    }
    
    @IBAction func unwindNewPredef(s: UIStoryboardSegue) {
        guard let predefEdit = s.source as? PredefEditViewController else {
            fatalError("Unwind source is not PredefEditViewController.")
        }
        
        if editedOutgo == nil && editedIncome == nil {
            switch viewMode {
            case .incomes:
                editedIncome = PredefIncome(context: AppDelegate.managedContext!)
            case .outgoings:
                editedOutgo = PredefOutgo(context: AppDelegate.managedContext!)
            default:
                print("none...")
            }
        }
        
        if editedOutgo != nil {
            editedOutgo?.name = predefEdit.txtName.text
            editedOutgo?.category = Int16(exactly: predefEdit.chosenCategoryValue)!
        }
        else if editedIncome != nil {
            editedIncome?.name = predefEdit.txtName.text
            editedIncome?.category = Int16(exactly: predefEdit.chosenCategoryValue)!
        }
        
        do {
            try AppDelegate.managedContext?.save()
        }
        catch {
            fatalError("Predefined saving error: \(error)")
        }
        
        switch viewMode {
        case .incomes:
            loadPredefIncomes()
        case .outgoings:
            loadPredefOutgoings()
        case .none:
            print("none...")
        }
    }
}
