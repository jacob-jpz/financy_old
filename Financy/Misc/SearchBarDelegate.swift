//
//  SearchBarDelegate.swift
//  Financy
//
//  Created by Jakub Pazik on 08/01/2020.
//  Copyright © 2020 Jakub Pazik. All rights reserved.
//

import UIKit

protocol SearchBarDelegate {
    func searchTextDidChange(searchText: String)
    func searchDidBegin()
    func searchDidCancel()
}
