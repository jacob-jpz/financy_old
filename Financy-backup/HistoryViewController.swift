//
//  HistoryViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 27/11/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class HistoryViewController: SwipeBackViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, FilterButtonsController {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnModeChange: UIButton!
    
    @IBOutlet weak var filterBckgAll: UIImageView!
    @IBOutlet weak var filterBtnAll: UIButton!
    @IBOutlet weak var filterImgAll: UIImageView!
    
    @IBOutlet weak var filterBckgOutgoings: UIImageView!
    @IBOutlet weak var filterBtnOutgoings: UIButton!
    @IBOutlet weak var filterImgOutgoings: UIImageView!
    
    @IBOutlet weak var filterBckgIncomes: UIImageView!
    @IBOutlet weak var filterBtnIncomes: UIButton!
    @IBOutlet weak var filterImgIncomes: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading: LoadingCircle!
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var modalBckg: UIView!
    @IBOutlet weak var modalBckgHeight: NSLayoutConstraint!
    @IBOutlet var modalTap: UITapGestureRecognizer!
    @IBOutlet weak var modalView: UIView!
    
    var dataReloadDelegate: DataReloadDelegate?
    private var shouldReloadData: Bool = false
    private var detailsViewController: DetailsViewController?
    
    private var btnCloseBehavior: ImageButtonBehavior?
    private var btnModeChangeBehaviour: ImageButtonBehavior?
    private var isFirstShownDone = false
    private var selectedTransaction: HistoryTransaction?
    
    private var itemsMode = ItemsMode.items
    private enum ItemsMode {
        case items, mostPopular
    }
    
    private var filterMode = FilterMode.all
    private enum FilterMode {
        case all, incomes, outgoings
    }
    
    //wszystkie transakcje
    private var transactions = [String: [HistoryTransaction]]()
    private var sectionHeaders = [String]()
    private var popularTransactions = [PopularTransaction]()
    private var popularLoaded = false
    //tylko wydatki
    private var outgoTransactions = [String: [HistoryTransaction]]()
    private var outgoSectionHeaders = [String]()
    private var popularOutgoings = [PopularTransaction]()
    //tylko przychody
    private var incomeTransactions = [String: [HistoryTransaction]]()
    private var incomeSectionHeaders = [String]()
    private var popularIncomes = [PopularTransaction]()
    //wyszukane transakcje
    private var isSearchActive = false
    private var searchTransactions = [String: [HistoryTransaction]]()
    private var searchSectionHeaders = [String]()
    private var searchPopularTransactions = [PopularTransaction]()
    
    private let numberFormatter = NumberFormatter()
    
    private let greenColor = UIColor(named: "greenBarColor")
    private let redColor = UIColor(named: "mainFontColor")
    
    var filterButtons = [FilterButton]()
    
    var chosenMonth: Int = 0
    var chosenYear: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = true
        
        if chosenMonth == 0 {
            fatalError("Missing chosenMonth parameter")
        }
        if chosenYear == 0 {
            fatalError("Missing chosenYear parameter")
        }
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.dismiss(animated: true, completion: nil)
        })
        
        btnModeChangeBehaviour = ImageButtonBehavior(btnModeChange, onTouch: {
            if self.itemsMode == .items {
                self.itemsMode = .mostPopular
                
                self.btnModeChange.setImage(UIImage(named: "HistItems"), for: .normal)
                self.loadMostPopularForMonth()
            }
            else {
                self.itemsMode = .items
                
                self.btnModeChange.setImage(UIImage(named: "HistTrending"), for: .normal)
                self.showLoadedData()
            }
        })
        
        filterButtons.append(FilterButton(bckg: filterBckgAll, btn: filterBtnAll, img: filterImgAll, initiallyChosen: true, parent: self,
            name: "All", onChoose: {
                self.filterMode = .all
                
                if !self.isSearchActive {
                    self.tableView.reloadData()
                }
                else {
                    self.searchTextDidChange(searchText: self.searchBar.txtSearch.text!.lowercased())
                }
        }))
        filterButtons.append(FilterButton(bckg: filterBckgOutgoings, btn: filterBtnOutgoings, img: filterImgOutgoings, initiallyChosen: false, parent: self,
            name: "Outgo", onChoose: {
                self.filterMode = .outgoings
                
                if !self.isSearchActive {
                    self.tableView.reloadData()
                }
                else {
                    self.searchTextDidChange(searchText: self.searchBar.txtSearch.text!.lowercased())
                }
        }))
        filterButtons.append(FilterButton(bckg: filterBckgIncomes, btn: filterBtnIncomes, img: filterImgIncomes, initiallyChosen: false, parent: self,
            name: "Income", onChoose: {
                self.filterMode = .incomes
                
                if !self.isSearchActive {
                    self.tableView.reloadData()
                }
                else {
                    self.searchTextDidChange(searchText: self.searchBar.txtSearch.text!.lowercased())
                }
        }))
        
        lblTitle.text = StaticData.months[chosenMonth - 1] + " \(chosenYear)"
        searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchBar.delegate = self
        
        modalBckgHeight.constant = UIScreen.main.bounds.height + 30
        modalView.layer.cornerRadius = 8
        
        view.isUserInteractionEnabled = false
    }
    
    func setAllButonsUnchosen() {
        for item in filterButtons {
            item.setUnchosen()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstShownDone {
            loading.isAnimating = true
            isFirstShownDone = true
            loadDataForMonth()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed && shouldReloadData && dataReloadDelegate != nil {
            dataReloadDelegate?.reloadData()
        }
    }
    
    private func loadDataForMonth() {
        DispatchQueue.global().async {
            self.numberFormatter.numberStyle = .decimal
            self.numberFormatter.minimumFractionDigits = 2
            self.numberFormatter.maximumFractionDigits = 2
            
            let outgoings = StaticData.getOutgoings(forMonth: self.chosenMonth, forYear: self.chosenYear, sorted: true)
            let incomes = StaticData.getIncomes(forMonth: self.chosenMonth, forYear: self.chosenYear, sorted: true)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var processingDate = Date()
            var dateString = ""
            var activeLoop = true
            var idxOutgoings = 0
            var idxIncomes = 0
            
            if outgoings.count > 0 && incomes.count > 0 {
                if outgoings[0].date! <= incomes[0].date! {
                    processingDate = outgoings[0].date!
                }
                else {
                    processingDate = incomes[0].date!
                }
            }
            else if outgoings.count > 0 {
                processingDate = outgoings[0].date!
            }
            else if incomes.count > 0 {
                processingDate = incomes[0].date!
            }
            else {
                activeLoop = false
            }
            
            self.transactions.removeAll()
            self.sectionHeaders.removeAll()
            self.outgoTransactions.removeAll()
            self.outgoSectionHeaders.removeAll()
            self.incomeTransactions.removeAll()
            self.incomeSectionHeaders.removeAll()
            self.popularLoaded = false
            
            while activeLoop {
                dateString = dateFormatter.string(from: processingDate)
                self.transactions[dateString] = [HistoryTransaction]()
                self.sectionHeaders.insert(dateString, at: 0)
                
                while outgoings.count > idxOutgoings && dateFormatter.string(from: outgoings[idxOutgoings].date!) == dateString {
                    let historyTrans = HistoryTransaction(income: nil, outgo: outgoings[idxOutgoings], amountString: self.numberFormatter.string(from: outgoings[idxOutgoings].amount!)!)
                    
                    self.transactions[dateString]?.append(historyTrans)
                    
                    if self.outgoTransactions.index(forKey: dateString) == nil {
                        self.outgoTransactions[dateString] = [HistoryTransaction]()
                        self.outgoSectionHeaders.insert(dateString, at: 0)
                    }
                    self.outgoTransactions[dateString]?.append(historyTrans)
                    
                    idxOutgoings += 1
                }
                while incomes.count > idxIncomes && dateFormatter.string(from: incomes[idxIncomes].date!) == dateString {
                    let historyTrans = HistoryTransaction(income: incomes[idxIncomes], outgo: nil, amountString: self.numberFormatter.string(from: incomes[idxIncomes].amount!)!)
                    
                    self.transactions[dateString]?.append(historyTrans)
                    
                    if self.incomeTransactions.index(forKey: dateString) == nil {
                        self.incomeTransactions[dateString] = [HistoryTransaction]()
                        self.incomeSectionHeaders.insert(dateString, at: 0)
                    }
                    self.incomeTransactions[dateString]?.append(historyTrans)
                    
                    idxIncomes += 1
                }
                
                if outgoings.count > idxOutgoings {
                    processingDate = outgoings[idxOutgoings].date!
                    
                    if incomes.count > idxIncomes && incomes[idxIncomes].date! < processingDate {
                        processingDate = incomes[idxIncomes].date!
                    }
                }
                else if incomes.count > idxIncomes {
                    processingDate = incomes[idxIncomes].date!
                }
                else {
                    activeLoop = false
                }
            }
            
            DispatchQueue.main.async {
                self.showLoadedData()
            }
        }
    }
    
    private func loadMostPopularForMonth() {
        if !popularLoaded {
            view.isUserInteractionEnabled = false
            
            tableView.isHidden = true
            loading.isAnimating = true
            
            DispatchQueue.global().async {
                var incomesTotal: Decimal = 0
                var outgoingsTotal: Decimal = 0
                
                let percentFormatter = NumberFormatter()
                percentFormatter.numberStyle = .percent
                percentFormatter.minimumFractionDigits = 2
                
                self.popularTransactions.removeAll()
                self.popularOutgoings.removeAll()
                self.popularIncomes.removeAll()
                
                for (_, val) in self.transactions {
                    for trans in val {
                        var popTrans: PopularTransaction
                        
                        if trans.income != nil {
                            let incomeIdx = self.popularTransactions.firstIndex(where: { $0.isIncome && $0.name == trans.income?.name })
                            
                            if incomeIdx != nil {
                                popTrans = self.popularTransactions[incomeIdx!]
                            }
                            else {
                                popTrans = PopularTransaction(name: trans.income!.name!, isIncome: true, category: trans.income!.category)
                                self.popularTransactions.append(popTrans)
                                self.popularIncomes.append(popTrans)
                            }
                            
                            popTrans.value += trans.income?.amount?.decimalValue ?? 0
                            incomesTotal += trans.income?.amount?.decimalValue ?? 0
                        }
                        else {
                            let outgoIdx = self.popularTransactions.firstIndex(where: { !$0.isIncome && $0.name == trans.outgo?.name })
                            
                            if outgoIdx != nil {
                                popTrans = self.popularTransactions[outgoIdx!]
                            }
                            else {
                                popTrans = PopularTransaction(name: trans.outgo!.name!, isIncome: false, category: trans.outgo!.category)
                                self.popularTransactions.append(popTrans)
                                self.popularOutgoings.append(popTrans)
                            }
                            
                            popTrans.value += trans.outgo?.amount?.decimalValue ?? 0
                            outgoingsTotal += trans.outgo?.amount?.decimalValue ?? 0
                        }
                    }
                }
                
                for popTrans in self.popularTransactions {
                    if popTrans.isIncome {
                        popTrans.percentageValue = popTrans.value / incomesTotal
                        popTrans.valueString = percentFormatter.string(from: NSDecimalNumber(decimal: popTrans.percentageValue))!
                        popTrans.valueString += " (+\(self.numberFormatter.string(from: NSDecimalNumber(decimal: popTrans.value))!))"
                    }
                    else {
                        popTrans.percentageValue = popTrans.value / outgoingsTotal
                        popTrans.valueString = percentFormatter.string(from: NSDecimalNumber(decimal: popTrans.percentageValue))!
                        popTrans.valueString += " (-\(self.numberFormatter.string(from: NSDecimalNumber(decimal: popTrans.value))!))"
                    }
                }
                
                self.popularTransactions.sort(by: { $0.percentageValue > $1.percentageValue })
                self.popularIncomes.sort(by: { $0.percentageValue > $1.percentageValue })
                self.popularOutgoings.sort(by: { $0.percentageValue > $1.percentageValue })
                
                DispatchQueue.main.async {
                    self.popularLoaded = true
                    self.showLoadedData()
                }
            }
        }
        else {
            showLoadedData()
        }
    }
    
    private func showLoadedData() {
        view.isUserInteractionEnabled = true
        
        loading.isAnimating = false
        tableView.alpha = 0
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        
        if !isSearchActive {
            tableView.reloadData()
        }
        else {
            searchTextDidChange(searchText: searchBar.txtSearch.text?.lowercased() ?? "")
        }
        
        UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.alpha = 1
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemsMode == .items {
            if !isSearchActive {
                switch filterMode {
                case .all:
                    return transactions[sectionHeaders[section]]!.count
                case .incomes:
                    return incomeTransactions[incomeSectionHeaders[section]]!.count
                case .outgoings:
                    return outgoTransactions[outgoSectionHeaders[section]]!.count
                }
            }
            else {
                return searchTransactions[searchSectionHeaders[section]]!.count
            }
        }
        else {
            if !isSearchActive {
                switch filterMode {
                case .all:
                    return popularTransactions.count
                case .incomes:
                    return popularIncomes.count
                case .outgoings:
                    return popularOutgoings.count
                }
            }
            else {
                return searchPopularTransactions.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as? HistoryDetailTableViewCell else {
            fatalError("Cell is not HistoryDetailTableViewCell")
        }
        
        cell.selectionStyle = .none
        
        if itemsMode == .items {
            let transaction = getHistoryTransaction(indexPath: indexPath)
            cell.canSelect = true
            
            if transaction.outgo != nil {
                cell.imgIcon.image = Categories.getOutgoIconBy(index: transaction.outgo!.category)
                cell.lblTitle.text = transaction.outgo?.name
                cell.lblAmount.text = "-" + transaction.amountString
                cell.lblAmount.textColor = redColor
            }
            else {
                cell.imgIcon.image = Categories.getIncomeIconBy(index: transaction.income!.category)
                cell.lblTitle.text = transaction.income?.name
                cell.lblAmount.text = "+" + transaction.amountString
                cell.lblAmount.textColor = greenColor
            }
        }
        else {
            let transaction = getPopularTransaction(indexPath: indexPath)
            cell.canSelect = false
            
            if !transaction.isIncome {
                cell.imgIcon.image = Categories.getOutgoIconBy(index: transaction.category)
                cell.lblTitle.text = transaction.name
                cell.lblAmount.text = transaction.valueString
                cell.lblAmount.textColor = redColor
            }
            else {
                cell.imgIcon.image = Categories.getIncomeIconBy(index: transaction.category)
                cell.lblTitle.text = transaction.name
                cell.lblAmount.text = transaction.valueString
                cell.lblAmount.textColor = greenColor
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if itemsMode == .items {
            if !isSearchActive {
                switch filterMode {
                case .all:
                    return sectionHeaders[section]
                case .incomes:
                    return incomeSectionHeaders[section]
                case .outgoings:
                    return outgoSectionHeaders[section]
                }
            }
            else {
                return searchSectionHeaders[section]
            }
        }
        else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemsMode == .mostPopular {
            return
        }
        
        if searchBar.txtSearch.isFirstResponder {
            searchBar.txtSearch.resignFirstResponder()
        }
        
        modalBckg.isHidden = false
        
        if detailsViewController == nil {
            guard let detailsViewController = storyboard?.instantiateViewController(withIdentifier: "details") as? DetailsViewController else {
                fatalError("View controller is not instance of DetailsViewController")
            }
            
            self.detailsViewController = detailsViewController
//            detailsViewController.view.translatesAutoresizingMaskIntoConstraints = false
            modalView.addSubview(detailsViewController.view)
            detailsViewController.view.frame = CGRect(x: 0, y: 0, width: modalView.frame.width, height: modalView.frame.height)
            detailsViewController.btnDelete.addTarget(self, action: #selector(deleteTransaction(sender:)), for: .touchUpInside)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedTransaction = getHistoryTransaction(indexPath: indexPath)
        
        if selectedTransaction?.outgo != nil {
            detailsViewController?.lblTitle.text = selectedTransaction?.outgo?.name
            detailsViewController?.imgImage.image = Categories.getOutgoIconBy(index: selectedTransaction!.outgo!.category)
            detailsViewController?.lblDate.text = dateFormatter.string(from: selectedTransaction!.outgo!.date!)
            detailsViewController?.lblAmount.text = "-"
            detailsViewController?.lblAmount.textColor = UIColor(named: "mainFontColor")
            detailsViewController?.lblComment.text = selectedTransaction?.outgo?.comment
        }
        else {
            detailsViewController?.lblTitle.text = selectedTransaction?.income?.name
            detailsViewController?.imgImage.image = Categories.getIncomeIconBy(index: selectedTransaction!.income!.category)
            detailsViewController?.lblDate.text = dateFormatter.string(from: selectedTransaction!.income!.date!)
            detailsViewController?.lblAmount.text = "+"
            detailsViewController?.lblAmount.textColor = UIColor(named: "greenBarColor")
            detailsViewController?.lblComment.text = selectedTransaction?.income?.comment
        }
        detailsViewController?.lblAmount.text! += selectedTransaction!.amountString
        
        modalView.alpha = 0
        modalView.isHidden = false
        let originalTransform = modalView.transform
        modalView.transform = originalTransform.scaledBy(x: 1.1, y: 1.1)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: {
                self.modalBckg.alpha = 0.2
                self.modalView.alpha = 1
                self.modalView.transform = originalTransform
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func deleteTransaction(sender: Any) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("delMsg3", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("del", comment: ""), style: .destructive, handler: { _ in
            DispatchQueue.global().async {
                if self.selectedTransaction?.outgo != nil {
                    AppDelegate.managedContext?.delete(self.selectedTransaction!.outgo!)
                }
                else {
                    AppDelegate.managedContext?.delete(self.selectedTransaction!.income!)
                }
                
                do {
                    try AppDelegate.managedContext?.save()
                    self.shouldReloadData = true
                }
                catch {
                    fatalError("Error on deleting transaction: \(error)")
                }
                
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = false
                    self.hideModal()
                    self.tableView.isHidden = true
                    self.loading.isAnimating = true
                    
                    self.loadDataForMonth()
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(named: "mainFontColor")
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getPopularTransaction(indexPath: IndexPath) -> PopularTransaction {
        if !isSearchActive {
            switch filterMode {
            case .all:
                return popularTransactions[indexPath.row]
            case .incomes:
                return popularIncomes[indexPath.row]
            case .outgoings:
                return popularOutgoings[indexPath.row]
            }
        }
        else {
            return searchPopularTransactions[indexPath.row]
        }
    }
    
    private func getHistoryTransaction(indexPath: IndexPath) -> HistoryTransaction {
        if !isSearchActive {
            switch filterMode {
            case .all:
                return transactions[sectionHeaders[indexPath.section]]![indexPath.row]
            case .incomes:
                return incomeTransactions[incomeSectionHeaders[indexPath.section]]![indexPath.row]
            case .outgoings:
                return outgoTransactions[outgoSectionHeaders[indexPath.section]]![indexPath.row]
            }
        }
        else {
            return searchTransactions[searchSectionHeaders[indexPath.section]]![indexPath.row]
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 28))
//        view.backgroundColor = .gray
//
//        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 28))
//        lbl.textColor = .black
//
//        if section == 0 {
//            lbl.text = "First section!"
//        }
//        else {
//            lbl.text = "Second one!"
//        }
//
//        view.addSubview(lbl)
//
//        return view
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if itemsMode == .items {
            if !isSearchActive {
                switch filterMode {
                case .all:
                    return sectionHeaders.count
                case .incomes:
                    return incomeSectionHeaders.count
                case .outgoings:
                    return outgoSectionHeaders.count
                }
            }
            else {
                return searchSectionHeaders.count
            }
        }
        else {
            return 1
        }
    }
    
    func searchTextDidChange(searchText: String) {
        DispatchQueue.global().async {
            if searchText != "" {
                self.isSearchActive = true
                
                if self.itemsMode == .items {
                    switch self.filterMode {
                    case .all:
                        self.filterTransactions(txt: searchText, dictionary: self.transactions)
                    case .incomes:
                        self.filterTransactions(txt: searchText, dictionary: self.incomeTransactions)
                    case .outgoings:
                        self.filterTransactions(txt: searchText, dictionary: self.outgoTransactions)
                    }
                }
                else {
                    switch self.filterMode {
                    case .all:
                        self.filterMostPopular(txt: searchText, array: self.popularTransactions)
                    case .incomes:
                        self.filterMostPopular(txt: searchText, array: self.popularIncomes)
                    case .outgoings:
                        self.filterMostPopular(txt: searchText, array: self.popularOutgoings)
                    }
                }
            }
            else {
                self.isSearchActive = false
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func filterTransactions(txt: String, dictionary: [String: [HistoryTransaction]]) {
        searchTransactions = [String: [HistoryTransaction]]()
        searchSectionHeaders = [String]()
        
        for (key, val) in dictionary {
            for trans in val {
                var name = ""
                if trans.outgo != nil {
                    name = (trans.outgo?.name ?? "").lowercased()
                }
                else {
                    name = (trans.income?.name ?? "").lowercased()
                }
                
                if name.hasPrefix(txt) || name.contains(txt) {
                    if searchTransactions.index(forKey: key) == nil {
                        searchTransactions[key] = [HistoryTransaction]()
                        searchSectionHeaders.append(key)
                    }
                    
                    searchTransactions[key]?.append(trans)
                }
            }
        }
        
        //posortowanie od najnowszej do nastarszej daty
        searchSectionHeaders.sort(by: { $0 > $1 })
    }
    
    private func filterMostPopular(txt: String, array: [PopularTransaction]) {
        searchPopularTransactions = [PopularTransaction]()
        
        for trans in array {
            let name = trans.name.lowercased()
            
            if name.hasPrefix(txt) || name.contains(txt) {
                searchPopularTransactions.append(trans)
            }
        }
        
        searchPopularTransactions.sort(by: { $0.percentageValue > $1.percentageValue })
    }
    
    func searchDidBegin() {
        
    }
    
    func searchDidCancel() {
        isSearchActive = false
        searchSectionHeaders.removeAll()
        searchTransactions.removeAll()
        tableView.reloadData()
    }
    
    @IBAction func modalTap(_ sender: Any) {
        hideModal()
    }
    
    private func hideModal() {
        if tableView.indexPathForSelectedRow != nil {
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
        }
        
        modalView.isHidden = true
        
        UIView.animate(withDuration: 0.19, delay: 0, options: .curveEaseOut, animations: {
            self.modalBckg.alpha = 0
        }, completion: { _ in
            self.modalBckg.isHidden = true
        })
    }
}

class HistoryTransaction {
    var income: IncomeEntry?
    var outgo: OutgoEntry?
    var amountString: String
    
    init(income: IncomeEntry?, outgo: OutgoEntry?, amountString: String) {
        self.income = income
        self.outgo = outgo
        self.amountString = amountString
    }
}

class PopularTransaction {
    var name: String
    var value: Decimal = 0
    var category: Int16
    var percentageValue: Decimal = 0
    var valueString: String = ""
    var isIncome: Bool
    
    init(name: String, isIncome: Bool, category: Int16) {
        self.name = name
        self.isIncome = isIncome
        self.category = category
    }
}
