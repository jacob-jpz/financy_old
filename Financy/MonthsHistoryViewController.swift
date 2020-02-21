//
//  MonthsHistoryViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 01/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class MonthsHistoryViewController: SwipeBackViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, DataReloadDelegate {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var modalBckgView: UIView!
    @IBOutlet weak var modalHeight: NSLayoutConstraint!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var modalContainer: UIView!
    @IBOutlet weak var modalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var loading: LoadingCircle!
    @IBOutlet weak var tableView: UITableView!
    
    private var btnCloseBehavior: ImageButtonBehavior?
    private var modalViewPanBeginning: CGFloat = -10
    private var pickYearModal: PickYearViewController?
    private var acceptBtnBehavior: ImageButtonBehavior?
    private var closeBtnBehavior: ImageButtonBehavior?
    private var isFirstShowDone = false
    private var isDelegated = false
    
    private var monthsIncomes = [NSDecimalNumber]()
    private var monthsOutgoings = [NSDecimalNumber]()
    private var monthsSummary = [String]()
    private var formatter = NumberFormatter()
    private var shouldReloadData = false
    
    var currentYear: Int = 0
    var currentMonth: Int = 0
    private let minYear = 2010
    private var chosenYear: Int = 0
    private var chosenMonth: Int = 0 //wybrany miesiąc do podglądu
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = false
        
        if currentYear == 0 {
            fatalError("Current year has not been provided.")
        }
        if currentMonth == 0 {
            fatalError("Current month has not been provided.")
        }
        
        chosenYear = currentYear
        lblYear.text = "\(currentYear)"
        btnYear.addTarget(self, action: #selector(chooseYear(_:)), for: .touchUpInside)
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.navigationController?.popViewController(animated: true)
        })
        
        modalHeight.constant = UIScreen.main.bounds.height + 50
        modalContainer.layer.cornerRadius = 11
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        view.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstShowDone {
            isFirstShowDone = true
            loadChosenYearData()
        }
    }
    
    func reloadData() {
        if chosenMonth == currentMonth && chosenYear == currentYear {
            //wymuszenie przeładowania tylko jeśli były zmiany w danych obecnego miesiąca
            AppDelegate.shouldReloadData = true
        }
        loadChosenYearData()
    }
    
    private func loadChosenYearData() {
        if !loading.isAnimating {
            view.isUserInteractionEnabled = false
            tableView.isHidden = true
            loading.isAnimating = true
        }
        
        DispatchQueue.global().async {
            if self.chosenYear != self.currentYear {
                for x in 1...12 {
                    self.getDataForMonth(month: x)
                }
            }
            else {
                for x in 1...self.currentMonth {
                    self.getDataForMonth(month: x)
                }
            }
            
            DispatchQueue.main.async {
                self.showLoadedData()
            }
        }
    }
    
    private func getDataForMonth(month: Int) {
        let outgoings = StaticData.getOutgoings(forMonth: month, forYear: self.chosenYear)
        let incomes = StaticData.getIncomes(forMonth: month, forYear: self.chosenYear)
        
        //przychody
        if monthsIncomes.count < month {
            monthsIncomes.append(0)
        }
        else {
            monthsIncomes[month - 1] = 0
        }
        
        var tempIncomes: Decimal = 0
        for income in incomes {
            tempIncomes += income.amount!.decimalValue
        }
        monthsIncomes[month - 1] = NSDecimalNumber(decimal: tempIncomes)
        
        //wydatki
        if monthsOutgoings.count < month {
            monthsOutgoings.append(0)
        }
        else {
            monthsOutgoings[month - 1] = 0
        }
        
        var tempOutgoings: Decimal = 0
        for outgo in outgoings {
            tempOutgoings += outgo.amount!.decimalValue
        }
        monthsOutgoings[month - 1] = NSDecimalNumber(decimal: tempOutgoings)
        
        //suma
        if monthsSummary.count < month {
            monthsSummary.append(formatter.string(from: NSDecimalNumber(decimal: tempIncomes - tempOutgoings))!)
        }
        else {
            monthsSummary[month - 1] = formatter.string(from: NSDecimalNumber(decimal: tempIncomes - tempOutgoings))!
        }
        
        if !monthsSummary[month - 1].hasPrefix("-") {
            monthsSummary[month - 1] = "+" + monthsSummary[month - 1]
        }
    }
    
    private func showLoadedData() {
        view.isUserInteractionEnabled = true
        tableView.alpha = 0
        tableView.isHidden = false
        loading.isAnimating = false
        
        if !isDelegated {
            tableView.delegate = self
            tableView.dataSource = self
        }
        
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.alpha = 1
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentYear != chosenYear {
            return 12
        }
        else {
            return currentMonth
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "histCell") as? HistoryCellTableViewCell else {
            fatalError("Error on creating cell 'histCell'")
        }
        
        cell.selectionStyle = .none
        
        let row = indexPath.row
        cell.lblMonthName.text = StaticData.months[row]
        cell.lblIncomes.text = "+" + formatter.string(from: monthsIncomes[row])!
        cell.lblOutgoings.text = "-" + formatter.string(from: monthsOutgoings[row])!
        cell.lblSummary.text = monthsSummary[row]
        cell.chart.showBars(incomeValue: monthsIncomes[row].decimalValue, outgoValue: monthsOutgoings[row].decimalValue, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "transHistory", sender: indexPath.row)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                tableView.deselectRow(at: indexPath, animated: false)
            })
        }
    }
    
    @objc private func chooseYear(_ sender: Any) {
        modalBckgView.alpha = 0
        modalBckgView.isHidden = false
        modalContainer.isHidden = false
        
        if pickYearModal == nil {
            guard let pickYearModal = storyboard?.instantiateViewController(withIdentifier: "pickYear") as? PickYearViewController else {
                fatalError("Pick year view is not instance of PickYearViewController")
            }
            self.pickYearModal = pickYearModal
            
            modalContainer.addSubview(pickYearModal.view)
            pickYearModal.view.frame = CGRect(x: 0, y: 0, width: modalContainer.frame.width, height: modalContainer.frame.height)
            
            closeBtnBehavior = ImageButtonBehavior(pickYearModal.btnClose, onTouch: {
                self.hideChooseYearModal(nil)
            })
            acceptBtnBehavior = ImageButtonBehavior(pickYearModal.btnAccept, onTouch: {
                self.chosenYear = self.currentYear - self.pickYearModal!.picker.selectedRow(inComponent: 0)
                self.lblYear.text = "\(self.chosenYear)"
                self.hideChooseYearModal({
                    self.loadChosenYearData()
                })
            })
            
            pickYearModal.picker.dataSource = self
            pickYearModal.picker.delegate = self
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckgView.alpha = 0.2
            self.modalBottomConstraint.constant = 40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideChooseYearModal(_ completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.19, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckgView.alpha = 0
            self.modalBottomConstraint.constant = 310
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.modalBckgView.isHidden = true
            self.modalContainer.isHidden = true
            self.pickYearModal?.picker.selectRow(self.currentYear - self.chosenYear, inComponent: 0, animated: false)
            if completion != nil {
                completion!()
            }
        })
    }
    
    @IBAction func modalBckgTap(_ sender: Any) {
        hideChooseYearModal(nil)
    }
    
    @IBAction func modalPan(_ sender: UIPanGestureRecognizer) {
        let currentY = sender.location(in: view).y
        
        if sender.state == .began {
            if sender.location(in: modalContainer).y <= 64 {
                modalViewPanBeginning = currentY
            }
        }
        else if modalViewPanBeginning > -10 {
            if sender.state == .changed {
                let diff = currentY - modalViewPanBeginning
                
                if diff > 0 {
                    modalBottomConstraint.constant = 40 + diff
                }
                else if diff < 0 {
                    modalBottomConstraint.constant = 40
                }
            }
            else if sender.state == .ended {
                if currentY - modalViewPanBeginning >= modalContainer.frame.height * 0.33 {
                    hideChooseYearModal(nil)
                }
                else {
                    if sender.velocity(in: view).y > 1000 {
                        //prędkość przesunięcia odpowiednio szybka sugeruje żeby ukryć
                        hideChooseYearModal(nil)
                    }
                    else {
                        //powrót na początkowe miejsce
                        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut, animations: {
                            self.modalBottomConstraint.constant = 40
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                }
                
                modalViewPanBeginning = -10
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentYear - minYear + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(currentYear - row)"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transHistory" {
            guard let chosenMonth = sender as? Int else {
                fatalError("Sender of transHistory segue is not an Int")
            }
            
            guard let historyController = segue.destination as? HistoryViewController else {
                fatalError("transHistory destination in not an instance of HistoryViewController")
            }
            
            self.chosenMonth = chosenMonth + 1
            historyController.chosenMonth = self.chosenMonth
            historyController.chosenYear = chosenYear
            historyController.dataReloadDelegate = self
        }
    }

}
