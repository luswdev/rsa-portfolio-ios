//
//  AssertView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/25.
//

import Foundation
import SwiftUI
import Charts
import SwiftUIPullToRefresh
import Combine

struct PositionTabView: View {
    var API: PortfolioAPI
    
    @State private var showDetail = false
    @State private var showNew = false
    @State private var clickIndex: Int = 0
    @State private var showIndex: Int = 0
    @Binding private var trendStyle: Bool
    
    @State private var height1: CGFloat = .zero
    @State private var height2: CGFloat = .zero

    @Binding private var positions: [PositionStruct]
    @Binding private var twdusd: Decimal
    
    @State private var selectedName: String?
    @State private var selectedAngle: Decimal?
    @State private var selectedValue: Float?
    
    @Binding private var selectedCurrency: CurrencyBase
    
    var totalValue: Decimal {
        positions.reduce(into: Decimal(0)) { (result, position) in
            result += position.getValue(selectedCurrency: selectedCurrency, twdusd: twdusd)
        }
    }

    var totalCost: Decimal {
        positions.reduce(into: Decimal(0)) { (result, position) in
            result += position.getCost(selectedCurrency: selectedCurrency, twdusd: twdusd)
        }
    }

    var gainLoss: Decimal {
        totalValue - totalCost
    }

    var gainLossRate: Float {
        Float(truncating: (gainLoss / totalCost) * 100 as NSNumber)
    }

    var body: some View {
        NavigationStack {
            VStack() {
                HStack() {
                    VStack(alignment: .leading) {
                        Text(totalValue, format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
                            .font(.system(size: 45, weight: .bold, design: Font.Design.rounded))
                            .foregroundColor(trendColor(trend: (totalValue >= totalCost), trendStyle: trendStyle))

                        HStack {
                            Text(gainLoss, format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue))
                                .foregroundColor(trendColor(trend: (totalValue >= totalCost), trendStyle: trendStyle))
                            Text("(\(gainLossRate, specifier: "%.2f")%)")
                                .foregroundColor(trendColor(trend: (totalValue >= totalCost), trendStyle: trendStyle))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity,  alignment: .topLeading)

                Chart(positions) { position in
                    SectorMark(
                        angle: .value("Assert", position.getValue(selectedCurrency: selectedCurrency, twdusd: twdusd)),
                        innerRadius: .ratio(0.625),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(hex2color(hex: position.color)!)
                    .opacity((selectedName == nil) ? 1.0 : ((position.ticker == selectedName) ? 1.0 : 0.3))
                }
                .chartAngleSelection(value: $selectedAngle)
                .chartXSelection(value: $selectedName)
                .onChange(of: selectedAngle, initial: false) { oldValue, newValue in
                    if let newValue {
                        selectedName = findSelectedSector(value: newValue)?.ticker
                        selectedValue = calcSelectedPercent(position: findSelectedSector(value: newValue)!)
                    } else {
                        selectedName = nil
                    }
                }
                .chartBackground { chartProxy in
                    if selectedName != nil && selectedValue != nil {
                        VStack {
                            Text(selectedName!)
                                .foregroundStyle(.secondary)
                            Text("\(selectedValue!, specifier: "%.2f")%")
                                .font(.system(size: 24, weight: .bold, design: Font.Design.rounded))
                        }
                    }
                }
                .padding()

                GeometryReader { geometry in
                    RefreshableScrollView(onRefresh: { done in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            reload()
                            done()
                        }
                    }) {
                        Form {
                            Section(header: Text("Holds")) {
                                ForEach (Array(positions.enumerated()), id: \.offset) { index, position in
                                    HStack {
                                        AsyncImage(url: URL(string: API.API_BASE + "/images/stocks/" + position.ticker + ".png")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .cornerRadius(100)
                                        } placeholder: {
                                            // ProgressView()
                                        }.frame(width: 30.0, height: 30.0)

                                        VStack(alignment: .leading) {
                                            Text(position.ticker)
                                            Text(position.name)
                                                .font(.system(size:12))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(
                                            position.getValue(selectedCurrency: selectedCurrency, twdusd: twdusd),
                                            format: Decimal.FormatStyle.Currency(code: selectedCurrency.rawValue)
                                        )
                                            .foregroundColor(
                                                trendColor(
                                                    trend: (position.current * position.quantity >= position.cost),
                                                    trendStyle: trendStyle
                                                )
                                            )
                                            .font(.system(size: 20, weight: .bold, design: Font.Design.rounded))
                                    }.onTapGesture {
                                        clickIndex = index
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
            }
            .onChange(of: clickIndex) {
                showIndex = clickIndex
                showDetail = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("Positions")
            .toolbar {
                Button {
                   showNew = true
               } label: {
                   HStack {
                       Image(systemName: "plus.circle.fill")
                           .foregroundStyle(Color("Main"))
                       Text("New Hold")
                           .font(.system(.body, design: .rounded).bold())
                           .foregroundStyle(Color("Main"))
                   }
               }
               .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showDetail) {
            StockDetailView(
                position: positions[clickIndex],
                trendStyle: $trendStyle
            )
        }
        .sheet(isPresented: $showNew) {
            StockEditorView(position: PositionStruct(ticker: "", name: "", quantity: 0, cost: 0, color: "#0369A1"))
        }
    }

    init(
        positions: Binding<[PositionStruct]>,
        twdusd: Binding<Decimal>,
        selectedCurrency: Binding<CurrencyBase>,
        trendStyle: Binding<Bool>,
        API: PortfolioAPI = PortfolioAPI()
    ) {
        self.API = API
        self._twdusd = twdusd
        self._selectedCurrency = selectedCurrency
        self._positions = positions
        self._trendStyle = trendStyle
    }

    private func findSelectedSector(value: Decimal) -> PositionStruct? {
        var accumulatedCount:Decimal = 0
     
        let position = positions.first { position in
            accumulatedCount += position.getValue(selectedCurrency: selectedCurrency, twdusd: twdusd)
            return value <= accumulatedCount
        }
     
        return position
    }

    private func calcSelectedPercent(position: PositionStruct) -> Float {
        var percent: Float
        let value = position.getValue(selectedCurrency: selectedCurrency, twdusd: twdusd)
        percent = Float(truncating: (value / totalValue) as NSNumber)
        return percent * 100
    }

    func reload() {
        for index in positions.indices {
            API.getStock(ticker: positions[index].ticker) { [self] info in
                guard info != nil else {
                    return
                }
                
                positions[index].current = info!.current
                positions[index].last = info!.last
            }
        }
        
        API.getCurrency(ticker: "TWD") { [self] info in
            guard info != nil else {
                return
            }
            
            twdusd = info!.current
        }
    }
}

var positions = [
    PositionStruct(ticker: "QQQ", name: "Invesco QQQ Trust", quantity: 0.67, cost: 300, color: "#4db6ac"),
    PositionStruct(ticker: "IWY", name: "iShares Russell Top 200 Growth", quantity: 1.51, cost: 300, color: "#26a69a")
]

#Preview {
    PositionTabView(
        positions: .constant(positions),
        twdusd: .constant(30),
        selectedCurrency: .constant(CurrencyBase.twd),
        trendStyle: .constant(false)
    )
}
