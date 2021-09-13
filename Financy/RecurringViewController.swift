//
//  RecurringViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 07/02/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

class RecurringViewController: SwipeBackViewController, FilterButtonsController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgIncomes: UIImageView!
    @IBOutlet weak var imgOutgoings: UIImageView!
    @IBOutlet weak var btnIncomes: UIButton!
    @IBOutlet weak var btnOutgoings: UIButton!
    @IBOutlet weak var bckgOutgoings: UIImageView!
    @IBOutlet weak var bckgIncomes: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var btnCloseBehavior: ImageButtonBehavior?
    private var filterButtons = [FilterButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isModal = false
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.navigationController?.popViewController(animated: true)
        })
        
        filterButtons.append(FilterButton(bckg: bckgOutgoings, btn: btnOutgoings, img: imgOutgoings, initiallyChosen: true, parent: self,
            name: "Outgo", onChoose: {
                //TODO
        }))
        
        filterButtons.append(FilterButton(bckg: bckgIncomes, btn: btnIncomes, img: imgIncomes, initiallyChosen: false, parent: self,
            name: "Income", onChoose: {
                //TODO
        }))
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setAllButonsUnchosen() {
        for item in filterButtons {
            item.setUnchosen()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recurringCell") as? RecurringTableViewCell else {
            fatalError("Cell is not RecurringTableViewCell")
        }
        
        cell.lblName.text = "todo"
        
        return cell
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
