//
//  GraphViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/02.
//

import UIKit
import Charts

final class GraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var graphNavigationItem: UINavigationItem!
    @IBOutlet private weak var categoryPieChartView: PieChartView!
    @IBOutlet private weak var graphTableView: UITableView!

    private var calendarDate: CalendarDate!
    private var dataRepository = DataRepository()
    private var pieChartData = [GraphData]()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        settingCalendarData() // CalendarViewControllerからcalendarDateを取り出す
        settingGraphTableView()
    }

    // CalendarViewControllerからcalendarDateを取り出す
    private func settingCalendarData() {
        let navigationController = tabBarController?.viewControllers?[0]
            as! UINavigationController // swiftlint:disable:this force_cast
        let calendarViewController = navigationController.topViewController
            as! CalendarViewController // swiftlint:disable:this force_cast
        calendarDate = calendarViewController.calendarDate
    }

    private func settingGraphTableView() {
        graphTableView.delegate = self
        graphTableView.dataSource = self
        graphTableView.register(GraphTableViewCell.nib,
                                forCellReuseIdentifier: GraphTableViewCell.identifier)
    }

    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataRepository.loadData()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        settingPieChart()
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }
    
    private func settingPieChart() {
        var chartDataEntry = [ChartDataEntry]()
        pieChartData.forEach {
            chartDataEntry.append(
                PieChartDataEntry(value: Double($0.expenses),
                                  label: $0.category.rawValue,
                                  data: $0.expenses)
            )
        }
        let pieChartDataSet = PieChartDataSet(entries: chartDataEntry)
        categoryPieChartView.data = PieChartData(dataSet: pieChartDataSet)
        
        var colors = [UIColor]()
        pieChartData.forEach {
            colors.append($0.category.color)
        }
        pieChartDataSet.colors = colors
        categoryPieChartView.legend.enabled = false
    }

    @IBAction func nextMonth(_ sender: Any) {
        calendarDate.nextMonth()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        settingPieChart()
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }

    @IBAction func lastMonth(_ sender: Any) {
        calendarDate.lastMonth()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        settingPieChart()
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pieChartData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphTableViewCell.identifier)
            as! GraphTableViewCell // swiftlint:disable:this force_cast
        cell.configure(graphData: pieChartData[indexPath.row])
        return cell
    }
}
