//
//  CategoryChooser.swift
//  Financy
//
//  Created by Jakub Pazik on 14/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import Foundation

public protocol CategoryChooser {
    func categoryChosen(value: Int, isIncome: Bool)
    func categoryListClosed(isIncome: Bool)
}
