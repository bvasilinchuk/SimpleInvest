//
//  ChartView.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 15.04.2023.
//

import SwiftUI
import Charts

struct ChartView: View {
    let data: ChartViewData
    @ObservedObject var chartViewModel: ChartViewModel
    var body: some View {
        chart
            .chartXAxis{chartXAxis}
            .chartXScale(domain: data.xAxisData.axisStart...data.xAxisData.axisEnd)
            .chartYScale(domain: data.yAxisData.axisStart...data.yAxisData.axisEnd)
            .chartPlotStyle{chartPlotStyle($0)}
            .chartOverlay{ proxy in 
                GeometryReader{gProxy in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(LongPressGesture(minimumDuration: 0.2).sequenced(before: DragGesture(minimumDistance: 0)
                            .onChanged({onChangeDrag(value: $0, chartProxy: proxy, geometryProxy: gProxy)})
                            .onEnded({_ in chartViewModel.selectedX = nil})))
                }
            }
    }
    private var chart: some View{
        Chart{
            ForEach(Array(zip(data.items.indices, data.items)), id: \.0){ index, item in
                LineMark(x: .value("Time", index), y: .value("Price", item.value))
                    .foregroundStyle(chartViewModel.foregroundMarkColor)
                AreaMark(x: .value("Time", index), yStart: .value("Min", data.yAxisData.axisStart ), yEnd: .value("Max", item.value))
                    .foregroundStyle(.linearGradient(Gradient(colors: [chartViewModel.foregroundMarkColor, .clear]), startPoint: .top, endPoint: .bottom)).opacity(0.4)
                
                if let (selectedX) = chartViewModel.selectedXDateAndPriceText?.value{
                    RuleMark(x: .value("Selected timestamp", selectedX))
                        .lineStyle(.init(lineWidth: 1))
                        .foregroundStyle(chartViewModel.foregroundMarkColor)
                }
            }
            }
    }
    
    private var chartXAxis: some AxisContent{
        AxisMarks(values: .stride(by: data.xAxisData.strideBy)){
            value in
            if let text = data.xAxisData.map[String(value.index)]{
                AxisGridLine(stroke: .init(lineWidth: 0.3))
                AxisTick(stroke: .init(lineWidth: 0.3))
                AxisValueLabel(collisionResolution: .greedy()){
                    Text(text)
                }
            }
        }
    }
    
    private func chartPlotStyle(_ plotContent: ChartPlotContent) -> some View {
        plotContent
            .frame(height: 200)
            .overlay {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5))
                    .mask(ZStack{
                        VStack{
                            Spacer()
                            Rectangle().frame(height: 0.5)
                        }
                        HStack{
                            Spacer()
                            Rectangle().frame(width: 0.5)
                        }
                    })
            }
    }
    private func onChangeDrag(value: DragGesture.Value, chartProxy: ChartProxy, geometryProxy: GeometryProxy){
        let xCurrent = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x
        if let index: Double = chartProxy.value(atX: xCurrent),
           index >= 0,
           Int(index) <= data.items.count - 1 {
            self.chartViewModel.selectedX = Int(index)
        }
    }
    }


struct ChartView_Previews: PreviewProvider {
    
    static let allRanges = ChartRange.allCases
    static let oneDayOngoing = ChartData.stub1DOngoing
    
    static var previews: some View {
        ForEach(allRanges) {
            ChartContainerView_Previews(vm: chartViewModel(range: $0, stub: $0.stubs), title: $0.title)
        }
        
        ChartContainerView_Previews(vm: chartViewModel(range: .oneDay, stub: oneDayOngoing), title: "1D Ongoing")
        
    }
    
    static func chartViewModel(range: ChartRange, stub: ChartData) -> ChartViewModel {
        var mockStocksAPI = MockStocksAPI()
        mockStocksAPI.stubbedFetchChartDataCallback = { _ in stub }
        let chartVM = ChartViewModel(stock: Stock.previewStocks.first!)
        chartVM.selectedRange = range
        return chartVM
    }
    
}

#if DEBUG
struct ChartContainerView_Previews: View {
    
    @StateObject var vm: ChartViewModel
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .padding(.bottom)
            if let chartViewData = vm.chart {
                ChartView(data: chartViewData, chartViewModel: ChartViewModel(stock: Stock.previewStocks.first!))
            }
        }
        .padding()
        .frame(maxHeight: 272)
        .previewLayout(.sizeThatFits)
        .previewDisplayName(title)
        .task { await vm.fetchData() }
    }
    
}

#endif

