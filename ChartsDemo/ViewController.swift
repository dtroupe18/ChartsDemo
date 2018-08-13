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
    @IBOutlet weak var classTypeLabel: UILabel!
    @IBOutlet weak var moreThanMethodLabel: UILabel!
    @IBOutlet weak var totalClassCountLabel: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    // sample hardcoded values
    let monthLabels = ["Jan" , "Feb", "Mar", "Apr", "May", "June", "July", "August", "Sept", "Oct", "Nov", "Dec"]
    let dollars =  [1453.0, 2352, 5431, 1442, 5451, 6486, 1173, 5678, 9234, 1345, 9411, 2212]
    let otherDollars = [1200.0, 2500, 4000, 1800, 3500, 5500, 1000, 4000, 8000, 1800, 9700, 2700]
    
    var showingSmoothGraph: Bool = true
    var lineChartDataSet = LineChartDataSet()
    var otherLineChartDataSet = LineChartDataSet()
    
    var allResults = [ClassResults]()
    var allUids = [Int]()
    var userResultsDict = [Int: [ClassResults]]()
    var dateLabels = [String]()
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChartView.delegate = self
        styleChart()
        loadDataFromJson()
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        if currentIndex < allUids.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        setupSingleChart()
    }
    
    @IBAction func lastPressed(_ sender: UIButton) {
        if currentIndex - 1 >= 0 {
            currentIndex -= 1
            setupSingleChart()
        }
    }
    
    private func loadDataFromJson() {
        let bundle: Bundle = Bundle(for: type(of: self))
        if let path: String = bundle.path(forResource: "powerScores", ofType: "json") {
            let url: URL = URL(fileURLWithPath: path)
            
            do {
                let simulatedJsonData: Data = try Data(contentsOf: url)
                print("simulated Data: \(simulatedJsonData)")
                allResults = try JSONDecoder().decode([ClassResults].self, from: simulatedJsonData)
                
                for result in allResults {
                    if userResultsDict[result.uid] != nil {
                        userResultsDict[result.uid]?.append(result)
                    } else {
                        userResultsDict[result.uid] = [result]
                    }
                    if !allUids.contains(result.uid) {
                        allUids.append(result.uid)
                    }
                }
                setupSingleChart()
                
            } catch {
                print("Error thrown: \(error)")
            }
        } else {
            print("could not load JSON data")
        }
    }
    
    private func styleChart() {
        lineChartView.layer.borderWidth = 1.0
        lineChartView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupSingleChart() {
        // create total power graph without regard to class type
        guard let currentResults = userResultsDict[allUids[currentIndex]] else { print("Nil in dict!"); return }
        totalClassCountLabel.text = "User: \(currentResults[0].uid) has \(currentResults.count) classes in June"
        var lineChartDataEnteries = [ChartDataEntry]()
        dateLabels.removeAll()
        
        var notMethodClassCount: Int = 0
        for (index, val) in currentResults.enumerated() {
            lineChartDataEnteries.append(ChartDataEntry(x: Double(index), y: Double(val.totalPower)))
            dateLabels.append(val.classDate)
            if val.classType != .method {
                notMethodClassCount += 1
            }
        }
        
        moreThanMethodLabel.text = "Has \(notMethodClassCount) non Method classes"
        if notMethodClassCount > 2 {
            moreThanMethodLabel.textColor = .red
        } else {
            moreThanMethodLabel.textColor = .black
        }
        
        if currentResults.count < 3 {
            print("less than 3!!!!!!!")
            lineChartView.noDataText = "Take more classes to see your results"
            clearLabels()
            lineChartView.data = nil
            lineChartView.notifyDataSetChanged()
            return
        }
        
        lineChartDataSet = LineChartDataSet(values: lineChartDataEnteries, label: graphOneName)
        lineChartDataSet.colors = [UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        lineChartDataSet.circleColors = [UIColor(red: 0, green: 153/255, blue: 1, alpha: 1)]
        lineChartDataSet.axisDependency = .left
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = UIColor.black
        lineChartDataSet.mode = .cubicBezier

        
        let lineChartData = LineChartData(dataSets: [lineChartDataSet, otherLineChartDataSet])
        lineChartData.setDrawValues(false)
        
        lineChartView.data = lineChartData
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
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
        lineChartView.animate(yAxisDuration: 0.4)
        
        lineChartView.notifyDataSetChanged()
        
    }
    
    private func oldSetupChart() {
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
        lineChartView.animate(yAxisDuration: 0.4)
        
        lineChartView.notifyDataSetChanged()
    }
    
    private func getBetterDateString(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: dateString) else { print("date nil"); return ""}
        
        dateFormatter.dateFormat = "MMM dd, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private func updateLabels(with entry: ChartDataEntry) {
        guard let dataSets = lineChartView.data?.dataSets else { print("4"); return }
        guard !dataSets.isEmpty else { print("5"); return }
        
        // print("dataSets.count: \(dataSets.count)")
        
        if dataSets.count > 0 {
            let xValue = Int(entry.x)
            let currentUid = allUids[currentIndex]
            guard let userResults = userResultsDict[currentUid] else { return }
            
            let currentClass = userResults[xValue]
            classTypeLabel.text = currentClass.classType.rawValue
            graphOneLabel.text = "\(getBetterDateString(dateString: currentClass.classDate))"
            graphTwoLabel.text = "Total Power: \(currentClass.totalPower)"
        }
    }
    
    private func clearLabels() {
        classTypeLabel.text = ""
        graphOneLabel.text = ""
        graphTwoLabel.text = ""
    }
    
    private func smoothGraph() {
        lineChartDataSet.mode = .cubicBezier
        otherLineChartDataSet.mode = .cubicBezier
        showingSmoothGraph = true
        lineChartView.highlightValue(nil)
        lineChartView.animate(xAxisDuration: 0.2)
        lineChartView.notifyDataSetChanged()
    }
    
    private func linearizeGraph() {
        lineChartDataSet.mode = .linear
        otherLineChartDataSet.mode = .linear
        showingSmoothGraph = false
        lineChartView.animate(xAxisDuration: 0.2)
        lineChartView.notifyDataSetChanged()
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
    
    // add tap gesture ended
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




