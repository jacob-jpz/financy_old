//
//  ContentView.swift
//  FinancyWatch Extension
//
//  Created by Jakub Pazik on 18/09/2021.
//  Copyright © 2021 Jakub Pazik. All rights reserved.
//

import SwiftUI
import WatchConnectivity

extension Color {
    static let financyColor = Color(red: 194 / 255, green: 24 / 255, blue: 92 / 255)
}

struct ContentView: View {
    static let appCommunication = AppCommunication(session: WCSession.default)
    
    @Environment (\.scenePhase) private var scenePhase
    
    @State private var isLoading = true
    @State private var monthText = "Sierpień 2020:"
    @State private var balanceText = "12 500 PLN"
    @State private var isHistoryVisible = false
    @State private var isAlert = false
    
    var body: some View {
        ZStack {
            MainInfo(isLoading: $isLoading, monthText: $monthText, balanceText: $balanceText)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 34, trailing: 0))
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    
                    HStack {
                        NavigationLink(
                            destination: Text("dd"),
                            isActive: .constant(false),
                            label: {
                                HStack {
                                    Image("add")
                                        .resizable()
                                        .frame(width: 18, height: 18, alignment: .center)
                                        .foregroundColor(.financyColor)
                                    Text("Dodaj")
                                }
                            })
                            .frame(width: geo.size.width * 0.47, height: 40, alignment: .center)
                            .disabled(isLoading)
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: HistoryView(),
                            isActive: $isHistoryVisible,
                            label: {
                                HStack {
                                    Image("history")
                                        .resizable()
                                        .frame(width: 20, height: 20, alignment: .center)
                                        .foregroundColor(.financyColor)
                                    Text("Hist.")
                                }
                            })
                            .frame(width: geo.size.width * 0.47, height: 40, alignment: .center)
                            .disabled(isLoading)
                    }
                    .opacity(isLoading ? 0 : 1)
                }
            }
        }
        .navigationBarTitle("Financy")
        .alert(isPresented: $isAlert, content: {
            Alert(title: Text("WC Session"),
                  message: Text("\(WCSession.isSupported() ? "YEP" : "NOPE")\n\(ContentView.appCommunication.session.isReachable ? "1" : "0")"),
                  dismissButton: .default(Text("OK")))
        })
        .onAppear(perform: {
            if ContentView.appCommunication.onBalanceReceived == nil {
                ContentView.appCommunication.onBalanceReceived = gotBalanceData(month:balance:)
                ContentView.appCommunication.session.delegate = ContentView.appCommunication
                ContentView.appCommunication.session.activate()
                
                isAlert = true
            }
            else {
                DispatchQueue.main.async {
                    ContentView.appCommunication.askForCurrentBalanceUpdate()
                }
                ContentView.appCommunication.clearEventHandlers()
            }
            
            if !isLoading {
                return
            }

            DispatchQueue.main.async {
                ContentView.appCommunication.askForCurrentBalance()
            }
        })
        .onChange(of: scenePhase, perform: { phase in
            switch phase {
            case .active:
                print("phase active!")
                DispatchQueue.main.async {
                    ContentView.appCommunication.askForCurrentBalanceUpdate()
                }
            default:
                break
            }
        })
    }
    
    private func gotBalanceData(month: String, balance: String) {
        DispatchQueue.main.async {
            self.monthText = month
            self.balanceText = balance
            
            withAnimation(.easeOut(duration: 0.3), {
                self.isLoading = false
            })
        }
    }
}

struct MainInfo: View {
    @Binding var isLoading: Bool
    @Binding var monthText: String
    @Binding var balanceText: String

    var body: some View {
        VStack {
            Text(isLoading ? "Ładowanie" : monthText)
            Text(isLoading ? "..." : balanceText)
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .foregroundColor(.financyColor)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
