//
//  AddNewViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 22/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class AddNewViewController: SwipeBackViewController, CategoryChooser, PredefinedChooser, UITextFieldDelegate {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var btnPredefined: UIButton!
    @IBOutlet weak var amountIcon: UIImageView!
    @IBOutlet weak var txtName: CustomTextField!
    @IBOutlet weak var txtAmount: CustomTextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var txtComment: CustomTextField!
    @IBOutlet weak var modalBckgHeight: NSLayoutConstraint!
    @IBOutlet weak var modalBckg: UIView!
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var modalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addAsPredefSwitch: UISwitch!
    
    private var scroll: UIScrollView!
    private var btnCloseBehavior: ImageButtonBehavior?
    private var btnAcceptBehavior: ImageButtonBehavior?
    private var firstShowDone = false
    private var amount: Decimal = 0
    private var chosenCategory = -1
    private var chosenDate = Date()
    private let dateFormatter = DateFormatter()
    private var addDatePickerViewController: AddDatePickerViewController?
    private var modalBtnCloseBehavior: ImageButtonBehavior?
    private var modalBtnAcceptBehavior: ImageButtonBehavior?
    private var modalViewPanBeginning: CGFloat = -10
    
    enum ViewMode {
        case none, income, outgo
    }
    var viewMode: ViewMode = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = true
        
        switch viewMode {
        case .income:
            lblTitle.text = NSLocalizedString("newInc", comment: "") //"Add an income"
            amountIcon.image = UIImage(named: "Income")
        case .outgo:
            lblTitle.text = NSLocalizedString("newOut", comment: "") //"Add an outgo"
            amountIcon.image = UIImage(named: "Outgo")
        default:
            fatalError("ViewMode not chosen.")
        }
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.dismiss(animated: true, completion: nil)
        })
        btnAcceptBehavior = ImageButtonBehavior(btnAccept, onTouch: {
            //pusto, accept podpięty pod unwind
        })
        
        txtName.delegate = self
        txtAmount.delegate = self
        txtComment.delegate = self
        
        let screenBounds = UIScreen.main.bounds
        scroll = UIScrollView(frame: CGRect(x: 0, y: 72, width: screenBounds.width, height: screenBounds.height - 72))
        scroll.delaysContentTouches = false
        view.addSubview(scroll)
        view.sendSubviewToBack(scroll)
        scroll.addSubview(contentContainer)
        contentContainer.frame = CGRect(x: 0, y: 0, width: contentContainer.frame.width, height: contentContainer.frame.height)
        scroll.contentSize = contentContainer.bounds.size
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        btnDate.setTitle(dateFormatter.string(from: chosenDate), for: .normal)
        btnDate.addTarget(self, action: #selector(chooseDateTouchUp(_:)), for: .touchUpInside)
        
        modalBckgHeight.constant = screenBounds.height + 50
        modalView.layer.cornerRadius = 11
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstShowDone {
            firstShowDone = true
            txtName.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc func chooseDateTouchUp(_ sender: Any) {
        modalBckg.alpha = 0
        modalBckg.isHidden = false
        modalView.isHidden = false
        
        if txtName.isFirstResponder {
            txtName.resignFirstResponder()
        }
        else if txtAmount.isFirstResponder {
            txtAmount.resignFirstResponder()
        }
        else if txtComment.isFirstResponder {
            txtComment.resignFirstResponder()
        }
        
        if addDatePickerViewController == nil {
            //tutaj należy wytworzyć viewController i dodać do widoku
            guard let addDatePickerViewController = storyboard?.instantiateViewController(withIdentifier: "datePicker") as? AddDatePickerViewController else {
                fatalError("datePicker view controller is not instance of AddDatePickerController.")
            }
            self.addDatePickerViewController = addDatePickerViewController
            
            modalView.addSubview(addDatePickerViewController.view)
            addDatePickerViewController.view.frame = CGRect(x: 0, y: 0, width: modalView.frame.width, height: modalView.frame.height)
            
            modalBtnCloseBehavior = ImageButtonBehavior(addDatePickerViewController.btnClose, onTouch: {
                self.hideMoreModal()
            })
            modalBtnAcceptBehavior = ImageButtonBehavior(addDatePickerViewController.btnAccept, onTouch: {
                self.chosenDate = self.addDatePickerViewController?.datePicker.date ?? self.chosenDate
                self.btnDate.setTitle(self.dateFormatter.string(from: self.chosenDate), for: .normal)
                self.hideMoreModal()
            })
            
            addDatePickerViewController.datePicker.maximumDate = Date()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckg.alpha = 0.2
            self.modalBottomConstraint.constant = -40
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func modalBckgTap(_ sender: Any) {
        hideMoreModal()
    }
    
    private func hideMoreModal() {
        UIView.animate(withDuration: 0.19, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckg.alpha = 0
            self.modalBottomConstraint.constant = -370
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.modalBckg.isHidden = true
            self.modalView.isHidden = true
            self.addDatePickerViewController?.datePicker.date = self.chosenDate
        })
    }
    
    @IBAction func modalPanDrag(_ sender: UIPanGestureRecognizer) {
        let currentY = sender.location(in: view).y
        
        if sender.state == .began {
            if sender.location(in: modalView).y <= 64 {
                modalViewPanBeginning = currentY
            }
        }
        else if modalViewPanBeginning > -10 {
            if sender.state == .changed {
                let diff = currentY - modalViewPanBeginning
                
                if diff > 0 {
                    modalBottomConstraint.constant = -40 - diff
                }
                else if diff < 0 {
                    modalBottomConstraint.constant = -40
                }
            }
            else if sender.state == .ended {
                if currentY - modalViewPanBeginning >= modalView.frame.height * 0.33 {
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
                            self.modalBottomConstraint.constant = -40
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                    }
                }
                
                modalViewPanBeginning = -10
            }
        }
    }
    
    @objc func keyboardShown(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        scroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.cgRectValue.height + 40, right: 0)
    }
    
    @objc func keyboardHide(_ notification: NSNotification) {
        scroll.contentInset = UIEdgeInsets.zero
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predefList" {
            guard let predefList = segue.destination as? PredefListViewController else {
                fatalError("Destination in not PredefListViewController")
            }
            
            if viewMode == .outgo {
                predefList.viewMode = .outgo
            }
            else {
                predefList.viewMode = .income
            }
            
            predefList.parentChooser = self
        }
        else if segue.identifier == "catList" {
            guard let catList = segue.destination as? CategoriesListViewController else {
                fatalError("Destination is not CategoriesListViewController")
            }
            
            if viewMode == .outgo {
                catList.viewMode = .outgo
            }
            else {
                catList.viewMode = .income
            }
            
            catList.parentChooser = self
        }
        else if segue.identifier == "unwind" {
            guard let mainView = segue.destination as? ViewController else {
                fatalError("Segue destination in not ViewController.")
            }
            
            //dodanie do bazy właściwego wydatku/przychodu
            if viewMode == .outgo {
                let outgo = OutgoEntry(context: AppDelegate.managedContext!)
                outgo.name = txtName.text
                outgo.amount = NSDecimalNumber(decimal: amount)
                outgo.category = Int16(chosenCategory)
                outgo.date = chosenDate
                outgo.comment = (txtComment.text ?? "").trimmingCharacters(in: .whitespaces)
            }
            else {
                let income = IncomeEntry(context: AppDelegate.managedContext!)
                income.name = txtName.text
                income.amount = NSDecimalNumber(decimal: amount)
                income.category = Int16(chosenCategory)
                income.date = chosenDate
                income.comment = (txtComment.text ?? "").trimmingCharacters(in: .whitespaces)
            }
            
            do {
                try AppDelegate.managedContext!.save()
            }
            catch {
                fatalError("Error on adding new outgo/income: \(error)")
            }
            
            //dodanie do bazy predefiniowanego wydatku/przychodu
            if addAsPredefSwitch.isOn {
                var sameNameIdx: Int? = -1
                let nameLower = txtName.text?.lowercased()
                
                if viewMode == .outgo {
                    sameNameIdx = StaticData.predefinedOutgoings.firstIndex(where: { outgo in outgo.name?.lowercased() == nameLower })
                    
                    if sameNameIdx == nil || sameNameIdx == -1 {
                        let newOutgo = PredefOutgo(context: AppDelegate.managedContext!)
                        newOutgo.name = txtName.text
                        newOutgo.category = Int16(exactly: chosenCategory)!
                        
                        do {
                            try AppDelegate.managedContext!.save()
                            mainView.predefinedOutgoAdded = true
                        }
                        catch {
                            fatalError("Error saving new predefined outgo: \(error)")
                        }
                    }
                }
                else {
                    sameNameIdx = StaticData.predefinedIncomes.firstIndex(where: { income in income.name?.lowercased() == nameLower })
                    
                    if sameNameIdx == nil || sameNameIdx == -1 {
                        let newIncome = PredefIncome(context: AppDelegate.managedContext!)
                        newIncome.name = txtName.text
                        newIncome.category = Int16(exactly: chosenCategory)!
                        
                        do {
                            try AppDelegate.managedContext!.save()
                            mainView.predefinedIncomeAdded = true
                        }
                        catch {
                            fatalError("Error saving new predefined income: \(error)")
                        }
                    }
                }
            }
        }
    }

    func categoryChosen(value: Int, isIncome: Bool) {
        if !isIncome {
            lblCategory.text = Categories.outgoNames[value]
            imgCategory.image = Categories.getOutgoIconBy(index: Int16(value))
        }
        else {
            lblCategory.text = Categories.incomeNames[value]
            imgCategory.image = Categories.getIncomeIconBy(index: Int16(value))
        }
        
        chosenCategory = value
    }
    
    func categoryListClosed(isIncome: Bool) {
        //nic nie robię
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtName {
            txtAmount.becomeFirstResponder()
        }
        else if textField == txtComment {
            txtComment.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAmount {
            if string == "," || string == "." {
                if txtAmount.text?.contains(".") ?? false || txtAmount.text?.contains(",") ?? false {
                    return false
                }
                else {
                    return true
                }
            }
        }
        
        return true
    }
    
    func predefinedChosen(index: Int, isIncome: Bool) {
        if !isIncome {
            let chosenOutgo = StaticData.predefinedOutgoings[index]
            
            txtName.text = chosenOutgo.name
            imgCategory.image = Categories.getOutgoIconBy(index: chosenOutgo.category)
            lblCategory.text = Categories.outgoNames[Int(chosenOutgo.category)]
            chosenCategory = Int(chosenOutgo.category)
        }
        else {
            let chosenIncome = StaticData.predefinedIncomes[index]
            
            txtName.text = chosenIncome.name
            imgCategory.image = Categories.getIncomeIconBy(index: chosenIncome.category)
            lblCategory.text = Categories.incomeNames[Int(chosenIncome.category)]
            chosenCategory = Int(chosenIncome.category)
        }
    }
    
    func predefinedListClosed(isIncome: Bool) {
        if txtAmount.text == "" {
            txtAmount.becomeFirstResponder()
        }
    }
    
    @IBAction func addAsPredefTap(_ sender: Any) {
        let feedBack = UIImpactFeedbackGenerator(style: .light)
        addAsPredefSwitch.setOn(!addAsPredefSwitch.isOn, animated: true)
        feedBack.impactOccurred()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwind" {
            let name = txtName.text?.trimmingCharacters(in: .whitespaces) ?? ""
            if name == "" {
                showStopAlert(message: NSLocalizedString("nameErr2", comment: ""), txtName)
                return false
            }
            txtName.text = name
            
            let amountTxt = txtAmount.text ?? ""
            if amountTxt == "" {
                showStopAlert(message: NSLocalizedString("amntErr", comment: ""), txtAmount)
                return false
            }
            
            amount = Decimal(string: amountTxt.replacingOccurrences(of: ",", with: "."))!
            if amount == 0 {
                showStopAlert(message: NSLocalizedString("amntErr2", comment: ""), txtAmount)
                return false
            }
            
            if chosenCategory == -1 {
                showStopAlert(message: NSLocalizedString("catErr2", comment: ""), nil)
                return false
            }
        }
        
        return true
    }
    
    private func showStopAlert(message: String, _ txtToBecomeFirstResponder: UITextField?) {
        let alertController = UIAlertController(title: "Stop", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: {
                if txtToBecomeFirstResponder != nil {
                    txtToBecomeFirstResponder?.becomeFirstResponder()
                }
            })
        }))
        alertController.view.tintColor = UIColor(named: "mainFontColor")
        
        present(alertController, animated: true)
    }
}
