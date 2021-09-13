//
//  PredefinedChooser.swift
//  Financy
//
//  Created by Jakub Pazik on 25/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import Foundation

public protocol PredefinedChooser {
    func predefinedChosen(index: Int, isIncome: Bool)
    func predefinedListClosed(isIncome: Bool)
}
