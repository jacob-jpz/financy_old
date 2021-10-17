//
//  AppCommunication.swift
//  FinancyWatch Extension
//
//  Created by Jakub Pazik on 18/09/2021.
//  Copyright © 2021 Jakub Pazik. All rights reserved.
//

import Foundation
import WatchConnectivity

class AppCommunication: NSObject, WCSessionDelegate {
    let lock = NSLock()
    let session: WCSession
    
    var onBalanceReceived: ((_ month: String, _ balance: String) -> Void)?
    var onGotHistory: ((_ history: [HistoryEntry]) -> Void)?
    
    init(session: WCSession) {
        self.session = session
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("received message")
        if let command = message["cmd"] as? String {
            print("command: \(command)")
            
            switch command {
            case "setBalance":
                onBalanceReceived?(message["month"] as! String, message["balance"] as! String)
                replyHandler(["msg" : "ok"])
            default:
                return
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
    func askForCurrentBalance() {
        print("asking for balance...")
        let message = ["cmd" : "getBalance"]
        session.sendMessage(message, replyHandler: replyHandler(message:), errorHandler: nil)
    }
    
    func askForCurrentBalanceUpdate() {
        print("asking for update...")
        let message = ["cmd" : "updBalance"]
        session.sendMessage(message, replyHandler: replyHandler(message:), errorHandler: nil)
    }
    
    func askForHistory() {
        let message = ["cmd" : "getHistory"]
        session.sendMessage(message, replyHandler: replyHandler(message:), errorHandler: nil)
    }
    
    private func replyHandler(message: [String : Any]) {
        print("got reply!")
        
        if let command = message["cmd"] as? String {
            print("command: \(command)")
            
            switch command {
            case "balance":
                onBalanceReceived?(message["month"] as! String, message["balance"] as! String)
            case "history":
                invokeHistoryHanlder(message: message)
            default:
                return
            }
        }
        else {
            print("no command...")
        }
    }
    
    private func invokeHistoryHanlder(message: [String : Any]) {
        defer {
            lock.unlock()
        }
        
        lock.lock()
        if let gotHistory = onGotHistory {
            var history = [HistoryEntry]()
            
            if let names = message["names"] as? [String] {
                if let amounts = message["amounts"] as? [String] {
                    if names.count == amounts.count {
                        for x in 0..<names.count {
                            let entry = HistoryEntry(idx: x, name: names[x], amount: amounts[x])
                            history.append(entry)
                        }
                    }
                }
            }
            
            gotHistory(history)
        }
    }
    
    func clearEventHandlers() {
        defer {
            lock.unlock()
        }
        
        lock.lock()
        onGotHistory = nil
    }
}

class HistoryEntry: Hashable {
    static func == (lhs: HistoryEntry, rhs: HistoryEntry) -> Bool {
        lhs.idx == rhs.idx
    }
    
    let idx: Int
    let name: String
    let amount: String
    
    init(idx: Int, name: String, amount: String) {
        self.idx = idx
        self.name = name
        self.amount = amount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(idx)
    }
}
