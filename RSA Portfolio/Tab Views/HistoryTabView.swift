//
//  HistoryView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation
import SwiftUI
import Charts

struct HistoryTabView: View {
    @Binding private var histories: [HistoryStruct]
    
    @Binding private var twdusd: Decimal
    
    @State private var showDetail = false
    @State private var showEdit = false
    @State private var clickIndex: Int = 0
    @State private var showIndex: Int = 0

    @State private var newRecord: HistoryStruct = HistoryStruct(date: "", usCost: 0, usBalance: 0, twCost: 0, twBalance: 0)
    
    @State private var pickedMarket: [HistoryStruct.SubHistory]
    @State private var selectedMarket: Int = 0
    
    @Binding private var needUpload: Bool
    @State private var editSuccess: Bool = false
    
    var pickedMarkets: [[HistoryStruct.SubHistory]] {
        [
            histories.map(\.tw),
            histories.map(\.us),
            histories.map {
                HistoryStruct.SubHistory(
                    cost: $0.tw.getCost(selectedCurrency: selectedCurrency, twdusd: twdusd) + $0.us.getCost(selectedCurrency: selectedCurrency, twdusd: twdusd),
                    balance: $0.tw.getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd) + $0.us.getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd),
                    currency: selectedCurrency
                )
            }
        ]
    }
    
    var pickerMarketBalanceMin: Decimal {
        pickedMarket.count != 0 ?
        pickedMarket.map { $0.getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd) } .min()! : 0
    }
    var pickerMarketBalanceMax: Decimal {
        pickedMarket.count != 0 ?
        pickedMarket.map { $0.getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd) } .max()! : 10
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

    @Binding private var selectedCurrency: CurrencyBase
    
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
                Picker("History Market", selection: $selectedMarket) {
                    Text("Taiwan").tag(0)
                    Text("United States").tag(1)
                    Text("Total").tag(2)
                }
                .onChange(of: selectedMarket) {
                    updatePickedMarket()
                }
                .padding(.horizontal)
                .padding(.top)
                .pickerStyle(.segmented)

                if selectedRow != nil || histories.count == 0 || pickedMarket.count == 0{
                    VStack(alignment: .leading) {
                        Text("Balance")
                            .foregroundColor(.clear)
                            .font(.system(size: 14))
                        Spacer().frame(height: 2)
                        Text(0, format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
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
                        Text(pickedMarket.last!.getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd), format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
                            .font(.system(size: 22, weight: .bold, design: Font.Design.rounded))
                        Spacer().frame(height: 2)
                        Text(histories.last!.date)
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
                            y: .value("Balance", pickedMarket[index].getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd))
                        )
                        .symbol(.circle)
                        .symbolSize(75)
                        .foregroundStyle(Color("Main"))
                        .interpolationMethod(.linear)
                        
                        AreaMark(
                            x: .value("Month", str2date(dateString: history.date), unit: .month),
                            yStart: .value("Min Balance", pickerMarketBalanceDomain[0]),
                            yEnd: .value("Max Balance", pickedMarket[index].getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd))
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
                                Text(pickedMarket[findSelectedSectorIndex(value: selectedRow) ?? 0].getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd), format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
                                    .font(.system(size: 22, weight: .bold, design: Font.Design.rounded))
                                Spacer().frame(height: 2)
                                Text(selectedRow.date)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 2)
                            .background(RoundedCornersShape(tl: 3, tr: 3, bl: 3, br: 3).fill(Color(.secondarySystemBackground)))
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

                List {
                    Section(header: Text("History")) {
                        ForEach (Array(histories.enumerated()), id: \.offset) { index, history in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(history.date)
                                }
                                Spacer()
                                Text(pickedMarket[index].getBalance(selectedCurrency: selectedCurrency, twdusd: twdusd), format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 20, weight: .bold, design: Font.Design.rounded))
                            }.onTapGesture {
                                clickIndex = index
                            }
                        }
                        .onDelete(perform: { offsets in
                            histories.remove(atOffsets: offsets)
                            updatePickedMarket()
                            needUpload = true
                        })
                        .onMove(perform: { fromIdx, toIdx in
                            histories.move(fromOffsets: fromIdx, toOffset: toIdx)
                            updatePickedMarket()
                            needUpload = true
                        })
                    }
                }
            }
            .toolbar {
                Button {
                    newRecord = HistoryStruct(date: "", usCost: 0, usBalance: 0, twCost: 0, twBalance: 0)
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
            .onChange(of: clickIndex) {
                showIndex = clickIndex
                showDetail = true
            }
            .navigationTitle("Histories")
        }
        .sheet(isPresented: self.$showDetail) {
            HistoryDetailView(
                twdusd: twdusd,
                selectedCurrency: $selectedCurrency,
                history: $histories[clickIndex],
                historyIndex: clickIndex,
                needUpload: $needUpload
            )
        }
        .sheet(isPresented: $showEdit, onDismiss: {
            if !editSuccess {
                return
            }
            editSuccess = true
            
            histories.append(newRecord)
            updatePickedMarket()
            needUpload = true
        }) {
            HistoryEditorView(history: $newRecord, editSuccess: $editSuccess)
        }
    }
    
    init(
        histories:  Binding<[HistoryStruct]>,
        twdusd: Binding<Decimal>,
        selectedCurrency: Binding<CurrencyBase>,
        needUpload: Binding<Bool>
    ) {
        self._histories = histories
        self.pickedMarket = histories.wrappedValue.map { $0.tw }
        self._twdusd = twdusd
        self._selectedCurrency = selectedCurrency
        self._needUpload = needUpload
    }
    
    
    private func updatePickedMarket() {
        pickedMarket = pickedMarkets[selectedMarket]
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
    HistoryTabView(
        histories: .constant(histories),
        twdusd: .constant(30),
        selectedCurrency: .constant(CurrencyBase.usd),
        needUpload: .constant(false)
    )
}
