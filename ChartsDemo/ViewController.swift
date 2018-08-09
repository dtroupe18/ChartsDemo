//
//  ViewController.swift
//  ChartsDemo
//
//  Created by Dave on 7/20/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    private let graphOneName: String = "Graph 1"
    private let graphTwoName: String = "Graph 2"
    
    @IBOutlet weak var graphOneLabel: UILabel!
    @IBOutlet weak var graphTwoLabel: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    // sample hardcoded values
    let monthLabels = ["Jan" , "Feb", "Mar", "Apr", "May", "June", "July", "August", "Sept", "Oct", "Nov", "Dec"]
    let dollars =  [1453.0, 2352, 5431, 1442, 5451, 6486, 1173, 5678, 9234, 1345, 9411, 2212]
    let otherDollars = [1200.0, 2500, 4000, 1800, 3500, 5500, 1000, 4000, 8000, 1800, 9700, 2700]
    
    var showingSmoothGraph: Bool = true
    var lineChartDataSet = LineChartDataSet()
    var otherLineChartDataSet = LineChartDataSet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.delegate = self
        styleChart()
        setupChart()
    }
    
    private func styleChart() {
        lineChartView.layer.borderWidth = 1.0
        lineChartView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupChart() {
        var lineChartDataEnteries = [ChartDataEntry]()
        var otherLineChartDataEnteries = [ChartDataEntry]()
        
        for (index, val) in dollars.enumerated() {
            lineChartDataEnteries.append(ChartDataEntry(x: Double(index), y: val))
        }
        
        for (index, val) in otherDollars.enumerated() {
            otherLineChartDataEnteries.append((ChartDataEntry(x: Double(index), y: val)))
        }
    
        lineChartDataSet = LineChartDataSet(values: lineChartDataEnteries, label: graphOneName)
        lineChartDataSet.colors = [UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        lineChartDataSet.circleColors = [UIColor(red: 0, green: 153/255, blue: 1, alpha: 1)]
        lineChartDataSet.axisDependency = .left
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = UIColor.black
        lineChartDataSet.mode = .cubicBezier
        
        otherLineChartDataSet = LineChartDataSet(values: otherLineChartDataEnteries, label: graphTwoName)
        otherLineChartDataSet.colors = [UIColor(red: 0, green: 0, blue: 1, alpha: 1)]
        otherLineChartDataSet.axisDependency = .left
        otherLineChartDataSet.drawCirclesEnabled = false
        otherLineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        otherLineChartDataSet.highlightColor = UIColor.black
        otherLineChartDataSet.mode = .cubicBezier
        
        let lineChartData = LineChartData(dataSets: [lineChartDataSet, otherLineChartDataSet])
        lineChartData.setDrawValues(false)
        
        lineChartView.data = lineChartData
        lineChartView.chartDescription?.text = ""
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.animate(yAxisDuration: 1.0)
        
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateLabels(with entry: ChartDataEntry) {
        guard let dataSets = lineChartView.data?.dataSets else { return }
        guard !dataSets.isEmpty else { return }
        
        if dataSets.count > 1 {
            let set1 = dataSets[0]
            let set2 = dataSets[1]
            
            guard let label1 = set1.label else { return }
            guard let yValue1 = set1.entryForIndex(Int(entry.x))?.y else { return }
            guard let yValue2 = set2.entryForIndex(Int(entry.x))?.y else { return }
            
            if label1 == graphOneName {
                graphOneLabel.text = "\(yValue1) dollars"
                graphTwoLabel.text = "\(yValue2) dollars"
            } else {
                graphOneLabel.text = "\(yValue2) dollars"
                graphTwoLabel.text = "\(yValue1) dollars"
            }
        }
    }
    
    private func smoothGraph() {
        lineChartDataSet.mode = .cubicBezier
        otherLineChartDataSet.mode = .cubicBezier
        showingSmoothGraph = true
        lineChartView.highlightValue(nil)
        lineChartView.animate(xAxisDuration: 0.5)
        lineChartView.notifyDataSetChanged()
    }
    
    private func linearizeGraph() {
        lineChartDataSet.mode = .linear
        otherLineChartDataSet.mode = .linear
        showingSmoothGraph = false
        lineChartView.animate(xAxisDuration: 0.5)
        lineChartView.notifyDataSetChanged()
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            smoothGraph()
        } else {
            linearizeGraph()
        }
    }
}

extension ViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if showingSmoothGraph {
            linearizeGraph()
        }
        updateLabels(with: entry)
    }
    
    func panGestureEnded(_ chartView: ChartViewBase) {
        smoothGraph()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




