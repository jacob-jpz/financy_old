//
//  AboutViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 10/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class AboutViewController: SwipeBackViewController {
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblVersion: UILabel!
    
    private var btnCloseBehavior: ImageButtonBehavior?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isModal = true
        
        btnCloseBehavior = ImageButtonBehavior(btnClose, onTouch: {
            self.dismiss(animated: true, completion: nil)
        })
        
        lblVersion.text = NSLocalizedString("appVer", comment: "")
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
