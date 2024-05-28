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

struct PositionStruct: Identifiable {
    let id = UUID()
    
    var color: String
    var ticker: String
    var name: String
    var current: Decimal
    var last: Decimal
    var quantity: Decimal
    var cost: Decimal
    
    init(ticker: String, name: String, quantity: Decimal, cost: Decimal, color: String){
        self.ticker = ticker
        self.name = name
        self.quantity = quantity
        self.cost = cost
        self.color = color
        self.current = 457.95
        self.last =  455.71
    }
}

struct PositionRowView: View {
    var position: PositionStruct
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                Text(position.ticker).foregroundStyle(.secondary)
                Text(position.current, format: Decimal.FormatStyle.Currency(code: "USD"))
                Text(position.quantity, format: Decimal.FormatStyle.Percent())
                Text(position.cost, format: Decimal.FormatStyle.Currency(code: "USD"))
                Text(position.current * position.quantity, format: Decimal.FormatStyle.Currency(code: "USD"))
            }
        }
    }
}

struct PositionView: View {
    var API: PortfolioAPI
    
    @State private var showDetail = false
    @State private var showNew = false
    @State private var clickIndex: Int = 0
    @Binding private var trendStyle: Bool
    
    @State private var height1: CGFloat = .zero
    @State private var height2: CGFloat = .zero

    @Binding private var positions: [PositionStruct]
    @Binding private var twdusd: Decimal
    
    @State private var selectedName: String?
    @State private var selectedAngle: Decimal?
    @State private var selectedValue: Float?
    
    var totalValue: Decimal {
        positions.reduce(into: Decimal(0)) { (result, position) in
            if position.ticker.rangeOfCharacter(from: .decimalDigits) != nil {
                result += position.current * position.quantity
            } else {
                result += position.current * position.quantity * self.twdusd
            }
        }
    }

    var totalCost: Decimal {
        positions.reduce(into: Decimal(0)) { (result, position) in
            if position.ticker.rangeOfCharacter(from: .decimalDigits) != nil {
                result += position.cost
            } else {
                result += position.cost * self.twdusd
            }
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
                        Text(totalValue, format: Decimal.FormatStyle.Currency(code: "TWD"))
                            .font(.system(size: 45, weight: .bold, design: Font.Design.rounded))
                            .foregroundColor(totalValue >= totalCost ? trendColor[trendStyle ? 1 : 0][0] : trendColor[trendStyle ? 1 : 0][1])
                        HStack {
                            Text(gainLoss, format: Decimal.FormatStyle.Currency(code: "TWD"))
                                .foregroundColor(totalValue >= totalCost ? trendColor[trendStyle ? 1 : 0][0] : trendColor[trendStyle ? 1 : 0][1])
                            Text("(\(gainLossRate, specifier: "%.2f")%)")
                                .foregroundColor(totalValue >= totalCost ? trendColor[trendStyle ? 1 : 0][0] : trendColor[trendStyle ? 1 : 0][1])
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity,  alignment: .topLeading)

                Chart(positions) { position in
                    SectorMark(
                        angle: .value("Assert", calcluateValue(position: position)),
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
                                            ProgressView()
                                        }.frame(width: 30.0, height: 30.0)

                                        VStack(alignment: .leading) {
                                            Text(position.ticker)
                                            Text(position.name)
                                                .font(.system(size:12))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(position.current * position.quantity, format: Decimal.FormatStyle.Currency(code: "TWD"))
                                            .foregroundColor(position.current * position.quantity >= position.cost ? trendColor[trendStyle ? 1 : 0][0] : trendColor[trendStyle ? 1 : 0][1])
                                            .font(.system(size: 20, weight: .bold, design: Font.Design.rounded))
                                    }.onTapGesture {
                                        clickIndex = index
                                        showDetail = true
                                    }
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                
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
            StockDetailView(position: positions[clickIndex], trendStyle: $trendStyle)
        }
        .sheet(isPresented: $showNew) {
            StockEditerView(position: PositionStruct(ticker: "", name: "", quantity: 0, cost: 0, color: "#0369A1"))
        }
    }
    
    init(
        positions: Binding<[PositionStruct]>,
        twdusd: Binding<Decimal>,
        trendStyle: Binding<Bool>,
        API: PortfolioAPI = PortfolioAPI()
    ) {
        self.API = API
        self._twdusd = twdusd
        self._positions = positions
        self._trendStyle = trendStyle
    }
    
    func calcluateValue(position: PositionStruct) -> Decimal {
        if position.ticker.rangeOfCharacter(from: .decimalDigits) != nil {
            return position.current * position.quantity
        } else {
            return position.current * position.quantity * twdusd
        }
    }
    
    private func findSelectedSector(value: Decimal) -> PositionStruct? {
        var accumulatedCount:Decimal = 0
     
        let position = positions.first { position in
            accumulatedCount += calcluateValue(position: position)
            return value <= accumulatedCount
        }
     
        return position
    }
    
    private func calcSelectedPercent(position: PositionStruct) -> Float {
        var percent: Float
        percent = Float(truncating: (calcluateValue(position: position) / totalValue) as NSNumber)
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
    PositionView(positions: .constant(positions), twdusd: .constant(30), trendStyle: .constant(false))
}
