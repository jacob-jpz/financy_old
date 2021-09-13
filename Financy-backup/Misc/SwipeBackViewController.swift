//
//  SwipeBackViewController.swift
//  Financy
//
//  Created by Jakub Pazik on 27/11/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit

class SwipeBackViewController: UIViewController {
    private var startingXCoord: CGFloat = -1
    private var panGestureAdded = false
    
    var isModal = false {
        didSet {
            if isModal {
                if #available(iOS 13.0, *) {
                    //tutaj nic nie trzeba...
                }
                else {
                    attachPanGestureRecognizer() //dla 12.0 dodaję swipe back dla okna modalnego
                }
            }
            else {
                attachPanGestureRecognizer()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func attachPanGestureRecognizer() {
        if panGestureAdded {
            return
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        view.addGestureRecognizer(panGesture)
        
        panGestureAdded = true
    }
    
    @objc private func panGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            let currentLocation = sender.location(in: view)
            if currentLocation.x <= 65 {
                startingXCoord = currentLocation.x
            }
        }
        else if sender.state == .ended || sender.state == .cancelled {
            if startingXCoord > -1 && sender.location(in: view).x - startingXCoord > 55 {
                if isModal {
                    dismiss(animated: true, completion: nil)
                }
                else {
                    navigationController?.popViewController(animated: true)
                }
            }
            else {
                startingXCoord = -1
            }
        }
    }
}
