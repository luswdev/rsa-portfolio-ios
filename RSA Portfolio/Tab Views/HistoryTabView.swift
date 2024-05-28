//
//  HistoryView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation
import SwiftUI
import Charts

struct HistoryStruct: Identifiable {
    let id = UUID()

    struct SubHistory: Hashable {
        var cost: Decimal
        var balance: Decimal
        
        init(cost: Decimal, balance: Decimal) {
            self.cost = cost
            self.balance = balance
        }
        
        static func == (lhs: SubHistory, rhs: SubHistory) -> Bool {
            if lhs.cost != rhs.cost {
                return false
            }
            
            if lhs.balance != rhs.balance {
                return false
            }
            
            return true
        }
    }
    
    var date: String
    var us: SubHistory
    var tw: SubHistory

    init(date: String, usCost: Decimal, usBalance: Decimal, twCost: Decimal , twBalance: Decimal){
        self.date = date
        self.us = SubHistory(cost: usCost, balance: usBalance)
        self.tw = SubHistory(cost: twCost, balance: twBalance)
    }
    
    static func == (lhs: HistoryStruct, rhs: HistoryStruct) -> Bool {
        if lhs.date != rhs.date {
            return false
        }
        
        if lhs.tw != rhs.tw {
            return false
        }
        
        if lhs.us != rhs.us {
            return false
        }
        
        return true
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct HistoryTabView: View {
    var histories: [HistoryStruct]
    
    @Binding private var twdusd: Decimal
    
    @State private var showDetail = false
    @State private var showEdit = false
    @State private var clickIndex: Int = 0
    
    @State private var pickedMarket: [HistoryStruct.SubHistory]
    var pickerMarketBalanceMin: Decimal {
        pickedMarket.count != 0 ?
        pickedMarket.map(\.balance).min()! : 0
    }
    var pickerMarketBalanceMax: Decimal {
        pickedMarket.count != 0 ?
        pickedMarket.map(\.balance).max()! : 10
    }
    var pickerMarketBalanceScale: Decimal {
        (pickerMarketBalanceMax - pickerMarketBalanceMin) * 0.1
    }
    var pickerMarketBalanceDomain: [Decimal] {
        [
            pickerMarketBalanceMin - pickerMarketBalanceScale,
            pickerMarketBalanceMax + pickerMarketBalanceScale
        ]
    }
    
    @State private var selectedRow: HistoryStruct?
    @State private var rawSelectedDate: Date?
    
    let primaryColorGradient = LinearGradient(
        gradient: Gradient (
            colors: [
                Color("Main").opacity(0.5),
                Color("Main").opacity(0.2),
                Color("Main").opacity(0.05),
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        NavigationView {
            VStack {
                Picker("History Market", selection: $pickedMarket) {
                    Text("Taiwan").tag(histories.map { $0.tw })
                    Text("United State").tag(histories.map { $0.us })
                    Text("Total").tag(histories.map {
                        HistoryStruct.SubHistory(
                            cost: $0.tw.cost + $0.us.cost * twdusd,
                            balance: $0.tw.balance + $0.us.balance * twdusd
                        )
                    })
                }
                .padding(.horizontal)
                .padding(.top)
                .pickerStyle(.segmented)

                if selectedRow != nil || histories.count == 0 {
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .foregroundColor(.clear)
                            .font(.system(size: 14))
                        Spacer().frame(height: 2)
                        Text(0, format: Decimal.FormatStyle.Currency(code: "TWD"))
                            .foregroundColor(.clear)
                            .font(.system(size: 22, weight: .bold, design: Font.Design.rounded))
                        Spacer().frame(height: 2)
                        Text("-")
                            .foregroundColor(.clear)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                    .padding(.bottom, 0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                } else if histories.count > 0  {
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        Spacer().frame(height: 2)
                        Text((pickedMarket.last != nil) ? pickedMarket.last!.balance : 0, format: Decimal.FormatStyle.Currency(code: "TWD"))
                            .font(.system(size: 22, weight: .bold, design: Font.Design.rounded))
                        Spacer().frame(height: 2)
                        Text((histories.last != nil) ? histories.last!.date : "-")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                    .padding(.bottom, 0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                }
                
                Chart {
                    ForEach(Array(histories.enumerated()), id: \.offset) { index, history in
                        LineMark(
                            x: .value("Month", str2date(dateString: history.date), unit: .month),
                            y: .value("Balance", pickedMarket[index].balance)
                        )
                        .symbol(.circle)
                        .symbolSize(75)
                        .foregroundStyle(Color("Main"))
                        .interpolationMethod(.linear)
                        
                        AreaMark(
                            x: .value("Month", str2date(dateString: history.date), unit: .month),
                            yStart: .value("Min Balance", pickerMarketBalanceDomain[0]),
                            yEnd: .value("Max Balance", pickedMarket[index].balance)
                        )
                        .interpolationMethod(.linear)
                        .foregroundStyle(primaryColorGradient)
                    }
                    
                    if let selectedRow {
                      RuleMark(
                        x: .value("Selected Month", str2date(dateString: selectedRow.date), unit: .month)
                      )
                      .foregroundStyle(Color.gray.opacity(0.3))
                      .offset(yStart: -10)
                      .zIndex(-1)
                      .annotation(
                            position: .top, spacing: 0,
                            overflowResolution: .init(
                                  x: .fit(to: .chart),
                                  y: .disabled
                            )
                      ) {
                            VStack(alignment: .leading) {
                                Text("Balance")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                                Spacer().frame(height: 2)
                                Text(pickedMarket[findSelectedSectorIndex(value: selectedRow) ?? 0].balance, format: Decimal.FormatStyle.Currency(code: "TWD"))
                                    .font(.system(size: 22, weight: .bold, design: Font.Design.rounded))
                                Spacer().frame(height: 2)
                                Text(selectedRow.date)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 2)
                            .background(RoundedCorners(tl: 3, tr: 3, bl: 3, br: 3).fill(Color(.secondarySystemBackground)))
                        }
                    }
                }
                .chartXSelection(value: $rawSelectedDate)
                .onChange(of: rawSelectedDate, initial: false) { oldValue, newValue in
                    if let newValue {
                        selectedRow = findSelectedSector(value: newValue)
                    } else {
                        selectedRow = nil
                    }
                }
                .chartYScale(domain: pickerMarketBalanceDomain)
                .padding(.horizontal)

                Form {
                    Section(header: Text("History")) {
                        ForEach (Array(histories.enumerated()), id: \.offset) { index, history in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(history.date)
                                }
                                Spacer()
                                Text(pickedMarket[index].balance, format: Decimal.FormatStyle.Currency(code: "TWD"))
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 20, weight: .bold, design: Font.Design.rounded))
                            }.onTapGesture {
                                clickIndex = index
                                showDetail = true
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    showEdit = true
               } label: {
                   HStack {
                       Image(systemName: "plus.circle.fill")
                           .foregroundStyle(Color("Main"))
                       Text("New Record")
                           .font(.system(.body, design: .rounded).bold())
                           .foregroundStyle(Color("Main"))
                   }
               }
               .buttonStyle(.plain)
            }
            .navigationTitle("Histories")
        }
        .sheet(isPresented: self.$showDetail) {
            HistoryDetailView(twdusd: twdusd, history: histories[clickIndex], historyIndex: clickIndex)
        }
        .sheet(isPresented: $showEdit) {
            HistoryEditorView(history: HistoryStruct(date: "", usCost: 0, usBalance: 0, twCost: 0, twBalance: 0))
        }
    }
    
    init(
        histories: [HistoryStruct] = [HistoryStruct](),
        twdusd: Binding<Decimal>
    ) {
        self.histories = histories
        self.pickedMarket = histories.map { $0.tw }
        self._twdusd = twdusd
    }
    
    private func findSelectedSector(value: Date) -> HistoryStruct? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        let valueMonth = dateFormatter.string(from: value)
        
        let history = histories.first { history in
            let historyMonth = dateFormatter.string(from: str2date(dateString: history.date))
            return historyMonth == valueMonth
        }
     
        return history
    }
    
    private func findSelectedSectorIndex(value: HistoryStruct) -> Int? {
        for index in histories.indices {
            if (histories[index] == value) {
                return index
            }
        }
        return nil
    }
}

var histories = [
    HistoryStruct(date: "Apr 2024", usCost: 900, usBalance: 900, twCost: 43381, twBalance: 43381),
    HistoryStruct(date: "May 2024", usCost: 900, usBalance: 904.86, twCost: 43381, twBalance: 43880),
    HistoryStruct(date: "Jun 2024", usCost: 1200, usBalance: 1204.86, twCost: 63381, twBalance: 43880),
]

#Preview {
    HistoryTabView(twdusd: .constant(30))
}
