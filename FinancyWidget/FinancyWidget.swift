//
//  FinancyWidget.swift
//  FinancyWidget
//
//  Created by Jakub Pazik on 13/09/2021.
//  Copyright © 2021 Jakub Pazik. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(balanceMonth: "Styczeń 2020", balanceTxt: "5000", context: context)
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> ()) {
        let (balanceMonth, balanceTxt) = getCurrentData()
        let entry = BalanceEntry(balanceMonth: balanceMonth, balanceTxt: balanceTxt, context: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> ()) {
        let (balanceMonth, balanceTxt) = getCurrentData()
        let entry = BalanceEntry(balanceMonth: balanceMonth, balanceTxt: balanceTxt, context: context)

        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    private func getCurrentData() -> (String, String) {
        var monthName = "Styczeń 2000"
        var balanceTxt = "2400"
        
        if let commonUserDefaults = UserDefaults(suiteName: "group.com.financy") {
            if let month = commonUserDefaults.string(forKey: "month") {
                monthName = month
            }
            if let balance = commonUserDefaults.string(forKey: "balance") {
                balanceTxt = balance
            }
        }
        
        return (monthName, balanceTxt)
    }
}

class BalanceEntry: TimelineEntry {
    var date: Date
    let balanceMonth: String
    var monthTextSize: CGFloat = -1
    let balanceTxt: String
    var balanceTextSize: CGFloat = -1
    
    init(balanceMonth: String, balanceTxt: String, context: TimelineProviderContext?) {
        date = Date()
        self.balanceMonth = balanceMonth
        self.balanceTxt = balanceTxt
        
        if let context = context {
            setTextSizes(dependingOn: context.family)
        }
    }
    
    func setTextSizes(dependingOn family: WidgetFamily) {
        if family == .systemSmall {
            monthTextSize = 16
            balanceTextSize = 19
        }
        else {
            monthTextSize = 20
            balanceTextSize = 27
        }
    }
}

struct FinancyWidgetEntryView : View {
    private let color1 = Color(red: 106 / 255, green: 27 / 255, blue: 154 / 255)
    private let color2 = Color(red: 236 / 255, green: 64 / 255, blue: 121 / 255)
    
    var entry: Provider.Entry
    private var widgetFamily: WidgetFamily?
    
    init(entry: Provider.Entry, family: WidgetFamily? = nil) {
        self.entry = entry
        widgetFamily = family
    }

    var body: some View {
        if let family = widgetFamily {
            entry.setTextSizes(dependingOn: family)
        }
        
        return VStack(spacing: 5) {
            Text(entry.balanceMonth)
                .font(.system(size: entry.monthTextSize))
                .foregroundColor(.white)
            Text("\(entry.balanceTxt) PLN")
                .font(.system(size: entry.balanceTextSize, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [color1, color2, color2, .white]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

@main
struct FinancyWidget: Widget {
    let kind: String = "FinancyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FinancyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Financy Widget")
        .description("Preview of your current balance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FinancyWidget_Previews: PreviewProvider {
    static var previews: some View {
        let family = WidgetFamily.systemSmall
        
        FinancyWidgetEntryView(entry: BalanceEntry(balanceMonth: "Grudzień 2000", balanceTxt: "-13 045,55", context: nil), family: family)
            .previewContext(WidgetPreviewContext(family: family))
    }
}
