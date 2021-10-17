//
//  AppDelegate.swift
//  Financy
//
//  Created by Jakub Pazik on 25/11/2019.
//  Copyright © 2019 Jakub Pazik. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var managedContext: NSManagedObjectContext?
    static var shouldReloadData: Bool = false
    static var mainController: ViewController?
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        AppDelegate.managedContext = self.persistentContainer.viewContext
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneWillResignActive
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneDidEnterBackground
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneWillEnterForeground
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneDidBecomeActive
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if AppDelegate.mainController != nil {
            AppDelegate.mainController?.viewDidAppear(false)
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Financy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let command = message["cmd"] as? String {
            switch command {
            case "getBalance":
                var data = getCurrentMonthBalance()
                data["cmd"] = "balance"
                replyHandler(data)
            case "getHistory":
                var data = getCurrentMonthHistory()
                data["cmd"] = "history"
                replyHandler(data)
            case "updBalance":
                if let mainController = AppDelegate.mainController, mainController.reloadedSinceLastWatchUpdate {
                    mainController.reloadedSinceLastWatchUpdate = false
                    var data = getCurrentMonthBalance()
                    data["cmd"] = "balance"
                    replyHandler(data)
                }
                else {
                    replyHandler(["ok" : "ok"])
                }
            default:
                return
            }
        }
    }
    
    func pushCurrentBalanceToWatch() {
        print("pushing current balance...")
        var data = getCurrentMonthBalance()
        data["cmd"] = "setBalance"
        
        WCSession.default.sendMessage(data, replyHandler: { data in
            if let msg = data["msg"] as? String, msg == "ok" {
                AppDelegate.mainController?.reloadedSinceLastWatchUpdate = false
            }
        }, errorHandler: nil)
    }
    
    private func getCurrentMonthHistory() -> [String : Any] {
        var data: [String : Any] = [:]
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let todayComponents = Calendar.current.dateComponents([.month, .year], from: Date())
        let outgoings = StaticData.getOutgoings(forMonth: todayComponents.month!, forYear: todayComponents.year!, sorted: false)
        var names = [String]()
        var amounts = [String]()
        
        for item in outgoings {
            if let name = item.name, let amount = item.amount {
                names.insert(name, at: 0)
                amounts.insert("-\(formatter.string(from: amount)!)", at: 0)
            }
        }
        
        data["names"] = names
        data["amounts"] = amounts
        
        return data
    }
    
    private func getCurrentMonthBalance() -> [String : Any] {
        var data: [String : Any] = [:]
        
        let userDefaults = UserDefaults()
        if let monthName = userDefaults.string(forKey: "month"), let balance = userDefaults.string(forKey: "balance") {
            data["month"] = monthName
            data["balance"] = balance
        }
        else {
            let (monthName, balance) = countCurrentMonthBalance()
            data["month"] = monthName
            data["balance"] = balance
        }
            
        return data
    }
    
    private func countCurrentMonthBalance() -> (String, String) {
        let calendar = Calendar.current
        let date = Date()
        let currentMonthNumber = calendar.component(.month, from: date) - 1
        let currentYear = calendar.component(.year, from: date)
        let currentMonthName = StaticData.months[currentMonthNumber]
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        //wydatki
        var currentOutgoings: Decimal = 0
        let outgoings = StaticData.getOutgoings(forMonth: currentMonthNumber + 1, forYear: currentYear)
        
        for item in outgoings {
            currentOutgoings += item.amount!.decimalValue
        }
        
        //przychody
        var currentIncomes: Decimal = 0
        let incomes = StaticData.getIncomes(forMonth: currentMonthNumber + 1, forYear: currentYear)
        
        for item in incomes {
            currentIncomes += item.amount!.decimalValue
        }
        
        let currentBalance: Decimal = currentIncomes - currentOutgoings
        let currentMonthBalance = (currentBalance > 0 ? "+" : "") + formatter.string(from: NSDecimalNumber(decimal: currentBalance))!
        
        return ("\(currentMonthName) \(currentYear):", currentMonthBalance)
    }
}
