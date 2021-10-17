//
//  HistoryView.swift
//  FinancyWatch Extension
//
//  Created by Jakub Pazik on 18/09/2021.
//  Copyright © 2021 Jakub Pazik. All rights reserved.
//

import SwiftUI

struct HistoryView: View {
    @State private var isLoadingHistory = true
    @State private var historyEntries: [HistoryEntry]!
    
    var body: some View {
        VStack {
            if isLoadingHistory {
                Text("Ładowanie historii...")
            }
            else {
                if historyEntries.count > 0 {
                    List {
                        ForEach(self.historyEntries, id: \.self, content: { elem in
                            HistoryEntryView(name: elem.name, amount: elem.amount)
                        })
                    }
                }
                else {
                    Text("Brak historii")
                }
            }
        }
        .navigationBarTitle("Historia")
        .onAppear(perform: {
            ContentView.appCommunication.onGotHistory = gotHistory(history:)
            ContentView.appCommunication.askForHistory()
        })
    }
    
    private func gotHistory(history: [HistoryEntry]) {
        self.historyEntries = history
        withAnimation(.easeOut(duration: 0.2)) {
            self.isLoadingHistory = false
        }
    }
}

struct HistoryEntryView: View {
    let name: String
    let amount: String
    
    var body: some View {
        VStack {
            Text(name)
                .lineLimit(1)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(amount)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundColor(.financyColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
