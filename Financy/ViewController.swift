//
//  ViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 25/11/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DataReloadDelegate {
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgHistory: UIImageView!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var imgOther: UIImageView!
    @IBOutlet weak var btnOther: UIButton!
    @IBOutlet weak var bottomButtonsContainer: UIView!
    @IBOutlet weak var rectLower: UIImageView!
    @IBOutlet weak var loadingCircle: LoadingCircle!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblMonthName: UILabel!
    @IBOutlet weak var modalBckg: UIView!
    @IBOutlet weak var modalBckgHeight: NSLayoutConstraint!
    @IBOutlet weak var viewEmbedMore: UIView!
    @IBOutlet weak var viewEmbedBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTotalIncomes: UILabel!
    @IBOutlet weak var lblTotalOutgoings: UILabel!
    @IBOutlet weak var rectDivisionBckg: UIImageView!
    
    @IBOutlet weak var lblNoTransactions: UILabel!
    @IBOutlet weak var divisionChart: TwoBarChart!
    @IBOutlet weak var viewTransactionsDivision: UIView!
    
    var predefinedOutgoAdded = false
    var predefinedIncomeAdded = false
    var reloadedSinceLastBackground = false
    var reloadedSinceLastWatchUpdate = false
    
    private var moreViewController: EmbedMoreViewController?
    private var moreViewPanBeginning: CGFloat = -10
    private let viewMoreBottomConstant: CGFloat = -34
    private var buttonImageConnections = [ButtonImageConnection]()
    private var btnCloseEmbedMore: ImageButtonBehavior?
    private let addAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private var isFirstTimeDataShowing = true
    private var isFirstAppearDone = false
    private var predefinedType = "" //"outgo" / "income"
    
    private var currentMonthName = ""
    private var currentMonthNumber = -1
    private var currentYear = 0
    private let formatter = NumberFormatter()
    private var currentMonthBalance = ""
    private var currentMonthIncomes = ""
    private var currentMonthOutgoings = ""
    private var currentIncomes: Decimal = 0
    private var currentOutgoings: Decimal = 0
    
    private let imgIncome = UIImage(named: "Income")
    private let imgOutgo = UIImage(named: "Outgo")
    private let imgInfo = UIImage(named: "Info")
    private let imgRecurring = UIImage(named: "Recurring")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //połączenia pomiędzy buttonami a ich obrazkami (efekt dotknięcia)
        buttonImageConnections.append(ButtonImageConnection(btn: btnAdd, img: imgAdd))
        buttonImageConnections.append(ButtonImageConnection(btn: btnHistory, img: imgHistory))
        buttonImageConnections.append(ButtonImageConnection(btn: btnOther, img: imgOther))
        
        btnAdd.addTarget(self, action: #selector(btnAddTouchUpInside(sender:)), for: .touchUpInside)
        btnHistory.addTarget(self, action: #selector(btnHistoryTouchUpInside(sender:)), for: .touchUpInside)
        btnOther.addTarget(self, action: #selector(btnMoreTouchUpInside(sender:)), for: .touchUpInside)
        
        //przygotowanie UI przed pierwszym załadowaniem danych
        rectLower.frame.origin.y -= 36
        rectLower.alpha = 0
        rectDivisionBckg.alpha = 0
        
        //jeśli to iPhone z gestami to przenieść kontener dolnych przycisków trochę wyżej
        let screenHeight = UIScreen.main.nativeBounds.height
        
        if (screenHeight == 1792 || screenHeight >= 2436) {
            bottomButtonsContainer.frame.origin.y -= 18
        }
        
        //przygotowanie listy wyboru dodawania wydatków i przychodów
        addAlert.addAction(UIAlertAction(title: NSLocalizedString("addNewOut", comment: ""), style: .default, handler: { _ in
            self.performSegue(withIdentifier: "addNew", sender: "outgo")
            self.addAlert.dismiss(animated: false, completion: nil)
        }))
        addAlert.addAction(UIAlertAction(title: NSLocalizedString("addNewInc", comment: ""), style: .default, handler: { _ in
            self.performSegue(withIdentifier: "addNew", sender: "income")
            self.addAlert.dismiss(animated: false, completion: nil)
        }))
        addAlert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { _ in
            self.addAlert.dismiss(animated: true, completion: nil)
        }))
        addAlert.view.tintColor = UIColor(named: "mainFontColor")
        
        //załącznie embed more view controller
        modalBckgHeight.constant = UIScreen.main.bounds.height + 10
        moreViewController = storyboard?.instantiateViewController(withIdentifier: "embedMore") as? EmbedMoreViewController
        viewEmbedMore.addSubview(moreViewController!.view)
        viewEmbedMore.layer.cornerRadius = 11
        moreViewController?.view.frame = CGRect(x: 0, y: 0, width: viewEmbedMore.frame.width, height: viewEmbedMore.frame.height)
        btnCloseEmbedMore = ImageButtonBehavior(moreViewController!.btnClose, onTouch: {
            self.hideMoreModal()
        })
        moreViewController?.tableView.delegate = self
        moreViewController?.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstAppearDone && !AppDelegate.shouldReloadData {
            //sprawdzenie czy należy przeładować dane (zmiana miesiąca)
            if Calendar.current.component(.month, from: Date()) - 1 != currentMonthNumber {
                loadDataForCurrentMonth()
            }
            
            return
        }
        
        isFirstAppearDone = true
        AppDelegate.shouldReloadData = false
        AppDelegate.mainController = self
        
        loadDataForCurrentMonth()
    }
    
    func reloadData() {
        loadDataForCurrentMonth()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goPredefined" {
            guard let destination = segue.destination as? PredefinedViewController else {
                fatalError("Segue destination is not instance of PredefinedViewController")
            }
            
            if predefinedType == "outgo" {
                destination.viewMode = .outgoings
            }
            else {
                destination.viewMode = .incomes
            }
        }
        else if segue.identifier == "addNew" {
            guard let destination = segue.destination as? AddNewViewController else {
                fatalError("Destination is not an instance of AddNewViewController")
            }
            
            let type = sender as? String
            if type == "income" {
                destination.viewMode = .income
            }
            else {
                destination.viewMode = .outgo
            }
        }
        else if segue.identifier == "showHistory" {
            guard let historyController = segue.destination as? MonthsHistoryViewController else {
                fatalError("Destination is not an instance of HistoryViewController")
            }
            
            historyController.currentYear = currentYear
            historyController.currentMonth = currentMonthNumber + 1
        }
        else if segue.identifier == "showDetail" {
            guard let historyDetail = segue.destination as? HistoryViewController else {
                fatalError("showDetail destination in not HistoryViewController")
            }
            
            historyDetail.chosenYear = currentYear
            historyDetail.chosenMonth = currentMonthNumber + 1
            historyDetail.dataReloadDelegate = self
        }
    }
    
    @objc private func btnAddTouchUpInside(sender: Any) {
        present(addAlert, animated: true, completion: nil)
    }
    
    @objc private func btnHistoryTouchUpInside(sender: Any) {
        performSegue(withIdentifier: "showHistory", sender: nil)
    }
    
    @objc private func btnMoreTouchUpInside(sender: Any) {
        modalBckg.alpha = 0
        modalBckg.isHidden = false
        viewEmbedMore.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckg.alpha = 0.2
            self.viewEmbedBottomConstraint.constant = self.viewMoreBottomConstant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func modalBckgTap(_ sender: Any) {
        hideMoreModal()
    }
    
    private func hideMoreModal(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.19, delay: 0, options: .curveEaseOut, animations: {
                self.modalBckg.alpha = 0
                self.viewEmbedBottomConstraint.constant = self.viewMoreBottomConstant - self.viewEmbedMore.frame.height
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.modalBckg.isHidden = true
                self.viewEmbedMore.isHidden = true
                
                guard let selectedRow = self.moreViewController?.tableView.indexPathForSelectedRow else {
                    return
                }
                
                self.moreViewController?.tableView.deselectRow(at: selectedRow, animated: false)
            })
        }
        else {
            modalBckg.alpha = 0
            viewEmbedBottomConstraint.constant = viewMoreBottomConstant - viewEmbedMore.frame.height
            modalBckg.isHidden = true
            viewEmbedMore.isHidden = true
            
            guard let selectedRow = moreViewController?.tableView.indexPathForSelectedRow else {
                return
            }
            
            moreViewController?.tableView.deselectRow(at: selectedRow, animated: false)
        }
    }
    
    private func loadDataForCurrentMonth() {
        view.isUserInteractionEnabled = false
        
        if !isFirstTimeDataShowing {
            //ustawienie UI pod ładowanie
            lblAmount.alpha = 0
            lblAmount.isHidden = true
            viewTransactionsDivision.isHidden = true
            divisionChart.clearBars()
            lblNoTransactions.isHidden = true
            loadingCircle.isAnimating = true
        }
        
        if predefinedOutgoAdded {
            predefinedOutgoAdded = false
            StaticData.loadPredefinedOutgoings(completion: nil)
        }
        else if predefinedIncomeAdded {
            predefinedIncomeAdded = false
            StaticData.loadPredefinedIncomes(completion: nil)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.countCurrentMonthBalance()
            
            self.saveCurrentMonthDataForWatch(balance: self.currentMonthBalance)
            self.reloadedSinceLastWatchUpdate = true
            (UIApplication.shared.delegate as! AppDelegate).pushCurrentBalanceToWatch()
            
            self.saveCurrentMonthDataForWidget(balance: self.currentMonthBalance)
            self.reloadedSinceLastBackground = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.showLoadedData()
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
    private func countCurrentMonthBalance() {
        if self.isFirstTimeDataShowing {
            let calendar = Calendar.current
            let date = Date()
            self.currentMonthNumber = calendar.component(.month, from: date) - 1
            self.currentYear = calendar.component(.year, from: date)
            self.currentMonthName = StaticData.months[self.currentMonthNumber]
            
            self.formatter.numberStyle = .decimal
            self.formatter.minimumFractionDigits = 2
            self.formatter.maximumFractionDigits = 2
        }
        
        //wydatki
        self.currentOutgoings = 0
        let outgoings = StaticData.getOutgoings(forMonth: self.currentMonthNumber + 1, forYear: self.currentYear)
        
        for item in outgoings {
            self.currentOutgoings += item.amount!.decimalValue
        }
        
        //przychody
        self.currentIncomes = 0
        let incomes = StaticData.getIncomes(forMonth: self.currentMonthNumber + 1, forYear: self.currentYear)
        
        for item in incomes {
            self.currentIncomes += item.amount!.decimalValue
        }
        
        let currentBalance: Decimal = self.currentIncomes - self.currentOutgoings
        self.currentMonthBalance = (currentBalance > 0 ? "+" : "") + self.formatter.string(from: NSDecimalNumber(decimal: currentBalance))!
        self.currentMonthIncomes = "+" + self.formatter.string(from: NSDecimalNumber(decimal: self.currentIncomes))!
        self.currentMonthOutgoings = "-" + self.formatter.string(from: NSDecimalNumber(decimal: self.currentOutgoings))!
    }
    
    private func saveCurrentMonthDataForWidget(balance: String) {
        if let commonUserDefaults = UserDefaults(suiteName: "group.com.financy") {
            commonUserDefaults.set(currentMonthName + " \(currentYear)", forKey: "month")
            commonUserDefaults.set(balance, forKey: "balance")
        }
    }
    
    private func saveCurrentMonthDataForWatch(balance: String) {
        let userDefaults = UserDefaults()
        userDefaults.set(currentMonthName + " \(currentYear):", forKey: "month")
        userDefaults.set(balance, forKey: "balance")
    }
    
    @IBAction func moreViewPan(_ sender: UIPanGestureRecognizer) {
        let currentY = sender.location(in: view).y
        
        if sender.state == .began {
            if sender.location(in: viewEmbedMore).y <= 64 {
                moreViewPanBeginning = currentY
            }
        }
        else if moreViewPanBeginning > -10 {
            if sender.state == .changed {
                let diff = currentY - moreViewPanBeginning
                
                if diff > 0 {
                    viewEmbedBottomConstraint.constant = viewMoreBottomConstant - diff
                }
                else if diff < 0 {
                    viewEmbedBottomConstraint.constant = viewMoreBottomConstant
                }
            }
            else if sender.state == .ended {
                if currentY - moreViewPanBeginning >= viewEmbedMore.frame.height * 0.33 {
                    hideMoreModal()
                }
                else {
                    if sender.velocity(in: view).y > 1000 {
                        //prędkość przesunięcia odpowiednio szybka sugeruje żeby ukryć
                        hideMoreModal()
                    }
                    else {
                        //powrót na początkowe miejsce
                        UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseOut, animations: {
                            self.viewEmbedBottomConstraint.constant = self.viewMoreBottomConstant
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                }
                
                moreViewPanBeginning = -10
            }
        }
    }
    
    private func showLoadedData() {
        if isFirstTimeDataShowing {
            isFirstTimeDataShowing = false
            
            UIView.animate(withDuration: 0.37, delay: 0, options: .curveEaseOut, animations: {
                self.rectLower.alpha = 1
                self.rectLower.frame.origin.y += 36
                self.rectDivisionBckg.alpha = 1
            }, completion: nil)
            
            lblMonthName.text = currentMonthName + " \(currentYear):"
        }
        
        let originalTransform = lblAmount.transform
        lblAmount.transform = originalTransform.scaledBy(x: 0.8, y: 1)
        UIView.performWithoutAnimation {
            self.lblAmount.text = self.currentMonthBalance
            self.lblTotalIncomes.text = self.currentMonthIncomes
            self.lblTotalOutgoings.text = self.currentMonthOutgoings
        }
        
        lblAmount.alpha = 0
        lblAmount.isHidden = false
        loadingCircle.isAnimating = false
        
        UIView.animate(withDuration: 0.36, delay: 0, options: .curveEaseOut, animations: {
            self.lblAmount.alpha = 1
            self.lblAmount.transform = originalTransform.scaledBy(x: 1, y: 1)
        }, completion: { _ in
            if self.currentOutgoings > 0 || self.currentIncomes > 0 {
                self.viewTransactionsDivision.isHidden = false
                self.divisionChart.showBars(incomeValue: self.currentIncomes, outgoValue: self.currentOutgoings, animated: true)
            }
            else {
                self.lblNoTransactions.isHidden = false
            }
        })
    }
    
    //MARK: metody tableView widoku More...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "moreRow") as? MoreTableViewCell else {
            fatalError("Cell is not an instance of MoreTableViewCell")
        }
        
        cell.selectionStyle = .none

        switch indexPath.row {
        case 0:
            cell.lblText.text = NSLocalizedString("predefInc", comment: "") //"Predefined incomes"
            cell.imgIcon.image = imgIncome
        case 1:
            cell.lblText.text = NSLocalizedString("predefOut", comment: "") //"Predefined outgoings"
            cell.imgIcon.image = imgOutgo
        case 2:
            cell.lblText.text = NSLocalizedString("recurring", comment: "")
            cell.imgIcon.image = imgRecurring
        case 3:
            cell.lblText.text = NSLocalizedString("about", comment: "") //"About"
            cell.imgIcon.image = imgInfo
        default:
            cell.lblText.text = "* Not recognized *"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            predefinedType = "income"
            performSegue(withIdentifier: "goPredefined", sender: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.68, execute: {
                self.hideMoreModal(animated: false)
            })
        case 1:
            predefinedType = "outgo"
            performSegue(withIdentifier: "goPredefined", sender: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.68, execute: {
                self.hideMoreModal(animated: false)
            })
        case 2:
            performSegue(withIdentifier: "recurring", sender: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.68, execute: {
                self.hideMoreModal(animated: false)
            })
        case 3:
            performSegue(withIdentifier: "aboutSegue", sender: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: {
                self.hideMoreModal(animated: false)
            })
        default:
            print("")
        }
    }
    
    @IBAction func addNewUnwind(s: UIStoryboardSegue) {
        loadDataForCurrentMonth()
    }
}

private class ButtonImageConnection {
    var btn: UIButton
    var img: UIImageView
    private var originalTransform: CGAffineTransform
    
    init(btn: UIButton, img: UIImageView) {
        self.btn = btn
        self.img = img
        originalTransform = img.transform
        
        btn.addTarget(self, action: #selector(setImageTouchDown(sender:)), for: .touchDown)
        btn.addTarget(self, action: #selector(setImageTouchCancel(sender:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(setImageTouchCancel(sender:)), for: .touchDragExit)
    }
    
    @objc func setImageTouchDown(sender: Any) {
        img.alpha = 0.28
        img.transform = originalTransform.scaledBy(x: 0.88, y: 0.88)
    }
    
    @objc func setImageTouchCancel(sender: Any) {
        UIView.animate(withDuration: 0.16, animations: {
            self.img.alpha = 1
            self.img.transform = self.originalTransform
        })
    }
}
