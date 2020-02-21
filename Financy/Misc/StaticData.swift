//
//  StaticData.swift
//  Financy
//
//  Created by Jakub Pazik on 03/12/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import Foundation
import CoreData

class StaticData {
    static let months = [NSLocalizedString("m01", comment: ""), NSLocalizedString("m02", comment: ""),
                         NSLocalizedString("m03", comment: ""), NSLocalizedString("m04", comment: ""),
                         NSLocalizedString("m05", comment: ""), NSLocalizedString("m06", comment: ""),
                         NSLocalizedString("m07", comment: ""), NSLocalizedString("m08", comment: ""),
                         NSLocalizedString("m09", comment: ""), NSLocalizedString("m10", comment: ""),
                         NSLocalizedString("m11", comment: ""), NSLocalizedString("m12", comment: "")]
    
    static var predefinedIncomes = [PredefIncome]()
    static var isIncomesLoaded = false
    static var predefinedOutgoings = [PredefOutgo]()
    static var isOutgoingsLoaded = false
    
    static func loadPredefinedIncomes(completion: (() -> Void)?) {
        DispatchQueue.global().async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PredefIncome")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let result = try AppDelegate.managedContext?.fetch(fetchRequest)
                
                predefinedIncomes = [PredefIncome]()
                
                if result != nil {
                    if result!.count > 0 {
                        predefinedIncomes = result as! [PredefIncome]
                    }
                }
                
                isIncomesLoaded = true
                
                if completion != nil {
                    DispatchQueue.main.async {
                        completion!()
                    }
                }
            }
            catch {
                fatalError("Loading predefined incomes error: \(error)")
            }
        }
    }
    
    static func loadPredefinedOutgoings(completion: (() -> Void)?) {
        DispatchQueue.global().async {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PredefOutgo")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let result = try AppDelegate.managedContext?.fetch(fetchRequest)
                
                predefinedOutgoings = [PredefOutgo]()
                
                if result != nil {
                    if result!.count > 0 {
                        predefinedOutgoings = result as! [PredefOutgo]
                    }
                }
                
                isOutgoingsLoaded = true
                
                if completion != nil {
                    DispatchQueue.main.async {
                        completion!()
                    }
                }
            }
            catch {
                fatalError("Loading predefined outgoings error: \(error)")
            }
        }
    }
    
    static func getOutgoings(forMonth: Int, forYear: Int, sorted: Bool = false) -> [OutgoEntry] {
        let (dateFirstOfMonth, dateLastOfMonth) = getFirstLastOfMonth(month: forMonth, year: forYear)

        //pobranie wydatków
        let outgoingsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "OutgoEntry")
        outgoingsFetch.predicate = NSPredicate(format: "date >= %@ AND date <= %@", dateFirstOfMonth as NSDate, dateLastOfMonth as NSDate)
        
        if sorted {
            outgoingsFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        }
        
        do {
            let result = try AppDelegate.managedContext!.fetch(outgoingsFetch)
            return result as! [OutgoEntry]
        }
        catch {
            fatalError("Error fetching outgo entries: \(error)")
        }
    }
    
    static func getIncomes(forMonth: Int, forYear: Int, sorted: Bool = false) -> [IncomeEntry] {
        let (dateFirstOfMonth, dateLastOfMonth) = getFirstLastOfMonth(month: forMonth, year: forYear)
        
        //pobranie przychodów
        let incomesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "IncomeEntry")
        incomesFetch.predicate = NSPredicate(format: "date >= %@ AND date <= %@", dateFirstOfMonth as NSDate, dateLastOfMonth as NSDate)
        
        if sorted {
            incomesFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        }
        
        do {
            let result = try AppDelegate.managedContext!.fetch(incomesFetch)
            return result as! [IncomeEntry]
        }
        catch {
            fatalError("Error fetching income entries: \(error)")
        }
    }
    
    private static func getFirstLastOfMonth(month: Int, year: Int) -> (dateFirst: Date, dateLast: Date) {
        //ustawienie dat granicznych danego miesąca
        let dateFormatter = ISO8601DateFormatter()
        let dateFirstOfMonth = dateFormatter.date(from: "\(year)-\(month)-01T00:00:00+0000")
        
        var compomentLastDay = DateComponents()
        compomentLastDay.setValue(1, for: .month)
        compomentLastDay.setValue(-1, for: .day)
        
        let dateLastOfMonth = Calendar.current.date(byAdding: compomentLastDay, to: dateFirstOfMonth!)
        
        return (dateFirstOfMonth!, dateLastOfMonth!)
    }
}
