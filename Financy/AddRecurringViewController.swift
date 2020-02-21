//
//  AddRecurringViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 17/02/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

class AddRecurringViewController: UIViewController {
    @IBOutlet weak var txtName: CustomTextField!
    @IBOutlet weak var txtAmount: CustomTextField!
    @IBOutlet weak var txtDayOfMonth: CustomTextField!
    @IBOutlet weak var switchDayOfMonth: UISwitch!
    @IBOutlet weak var switchLastOfMonth: UISwitch!
    @IBOutlet weak var imgAmount: UIImageView!
    
    private var firstShowDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switchDayOfMonth.addTarget(self, action: #selector(switchDayOfMonthChanged(sender:)), for: .valueChanged)
        switchLastOfMonth.addTarget(self, action: #selector(switchLastOfMonthChanged(sender:)), for: .valueChanged)
        
        //TODO
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !firstShowDone {
            firstShowDone = true
            txtName.becomeFirstResponder()
        }
    }
    
    @objc private func switchDayOfMonthChanged(sender: Any) {
        switchLastOfMonth.setOn(!switchDayOfMonth.isOn, animated: true)
    }
    
    @objc private func switchLastOfMonthChanged(sender: Any) {
        switchDayOfMonth.setOn(!switchLastOfMonth.isOn, animated: true)
    }
    
    @IBAction func viewTap(_ sender: Any) {
        if txtName.isFirstResponder {
            txtName.resignFirstResponder()
        }
        else if txtAmount.isFirstResponder {
            txtAmount.resignFirstResponder()
        }
        else if txtDayOfMonth.isFirstResponder {
            txtDayOfMonth.resignFirstResponder()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
