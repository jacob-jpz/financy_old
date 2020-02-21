//
//  SearchBar.swift
//  Financy
//
//  Created by Jakub Pazik on 08/01/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

@IBDesignable class SearchBar: UIView, UITextFieldDelegate {
    @IBInspectable var placeholder: String = "" {
        didSet {
            txtSearch.placeholder = placeholder
        }
    }
    
    var txtSearch: CustomTextField = CustomTextField()
    private var imgSearch: UIImageView = UIImageView(image: UIImage(named: "SearchIcon"))
    private var btnCancel: UIButton = UIButton(type: .system)
    private var rightTxtConstraint: NSLayoutConstraint?
    
    private let activeSearchConstraintValue: CGFloat = -78
    private let inactiveSearchConstraintValue: CGFloat = -10
    
    var delegate: SearchBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepareBar()
    }
    
    private func prepareBar() {
        let mainFontColor = UIColor(named: "mainFontColor")
        
        backgroundColor = .clear
        
        txtSearch.translatesAutoresizingMaskIntoConstraints = false
        txtSearch.backgroundColor = UIColor(named: "txtBckg")
        txtSearch.xOffset = 36
        txtSearch.placeholder = placeholder
        txtSearch.font = UIFont(name: "OpenSans-Regular", size: 17)
        txtSearch.textColor = UIColor(named: "secondFontColor")
        txtSearch.tintColor = mainFontColor
        txtSearch.returnKeyType = .done
        
        txtSearch.addTarget(self, action: #selector(searchEditBegin(_:)), for: .editingDidBegin)
        txtSearch.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        txtSearch.delegate = self
        
        addSubview(txtSearch)
        
        txtSearch.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        txtSearch.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        rightTxtConstraint = txtSearch.rightAnchor.constraint(equalTo: rightAnchor, constant: inactiveSearchConstraintValue)
        rightTxtConstraint?.isActive = true
        txtSearch.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        
        imgSearch.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imgSearch)
        
        imgSearch.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        imgSearch.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 18)
        btnCancel.tintColor = mainFontColor
        btnCancel.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        btnCancel.alpha = 0
        
        btnCancel.addTarget(self, action: #selector(cancelSearch(_:)), for: .touchUpInside)
        
        addSubview(btnCancel)
        
        btnCancel.leftAnchor.constraint(equalTo: txtSearch.rightAnchor, constant: 12).isActive = true
        btnCancel.widthAnchor.constraint(equalToConstant: 56).isActive = true
        btnCancel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
    }
    
    @objc private func searchEditBegin(_ sender: Any) {
        if rightTxtConstraint!.constant == inactiveSearchConstraintValue {
            searchingActivate()
        }
    }
    
    @objc private func searchChanged(_ sender: Any) {
        if delegate != nil {
            delegate!.searchTextDidChange(searchText: (txtSearch.text ?? "").lowercased())
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.resignFirstResponder()
        }
        else {
            searchingDeactivate()
        }
        
        return true
    }
    
    @objc private func cancelSearch(_ sender: Any) {
        txtSearch.text = ""
        searchingDeactivate()
    }
    
    private func searchingActivate() {
        if delegate != nil {
            delegate!.searchDidBegin()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.rightTxtConstraint?.constant = self.activeSearchConstraintValue
            self.layoutIfNeeded()
            self.btnCancel.alpha = 1
        }, completion: nil)
    }
    
    private func searchingDeactivate() {
        txtSearch.resignFirstResponder()
        
        if delegate != nil {
            delegate!.searchDidCancel()
        }
        
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: {
            self.rightTxtConstraint?.constant = self.inactiveSearchConstraintValue
            self.layoutIfNeeded()
            self.btnCancel.alpha = 0
        }, completion: nil)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
