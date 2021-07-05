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
    @IBOutlet private weak var pieChartSegmentedControl: UISegmentedControl!
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
        graphTableView.register(GraphTableViewHeaderFooterView.nib,
                                forHeaderFooterViewReuseIdentifier: GraphTableViewHeaderFooterView.identifier)
    }

    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dataRepository.loadData()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        switch pieChartSegmentedControl.tag {
        case 0:
            settingExpensesPieChart()
        default:
            settingIncomePieChart()
        }
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }

    // 支出グラフの設定
    private func settingExpensesPieChart() {
        var chartDataEntry = [ChartDataEntry]()
        pieChartData.forEach {
            if $0.expenses != 0 { chartDataEntry.append(
                PieChartDataEntry(value: Double($0.expenses),
                                  label: $0.category.rawValue,
                                  data: $0.expenses)
            ) }
        }
        let pieChartDataSet = PieChartDataSet(entries: chartDataEntry)
        categoryPieChartView.data = PieChartData(dataSet: pieChartDataSet)
        
        var colors = [UIColor]()
        pieChartData.forEach {
            if $0.expenses != 0 { colors.append($0.category.color) }
        }
        pieChartDataSet.colors = colors
        categoryPieChartView.legend.enabled = false
    }

    // 収入グラフの設定
    private func settingIncomePieChart() {
        var chartDataEntry = [ChartDataEntry]()
        pieChartData.forEach {
            if $0.income != 0 { chartDataEntry.append(
                PieChartDataEntry(value: Double($0.income),
                                  label: $0.category.rawValue,
                                  data: $0.income)
            ) }
        }
        let pieChartDataSet = PieChartDataSet(entries: chartDataEntry)
        categoryPieChartView.data = PieChartData(dataSet: pieChartDataSet)

        var colors = [UIColor]()
        pieChartData.forEach {
            if $0.income != 0 { colors.append($0.category.color) }
            }
        pieChartDataSet.colors = colors
        categoryPieChartView.legend.enabled = false
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryPieChartView.frame = CGRect(x: view.safeAreaInsets.left + 30,
                                            y: view.safeAreaInsets.top + 50,
                                            width: view.frame.width - 60,
                                            height: view.frame.width - 60)
        graphTableView.frame = CGRect(x: view.frame.minX,
                                      y: categoryPieChartView.frame.maxY + 8,
                                      width: view.frame.width,
                                      height: view.frame.height
                                        - view.safeAreaInsets.top
                                        - categoryPieChartView.frame.height)
    }

    // MARK: - @IBAction
    @IBAction private func nextMonth(_ sender: Any) {
        calendarDate.nextMonth()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        switch pieChartSegmentedControl.tag {
        case 0:
            settingExpensesPieChart()
        default:
            settingIncomePieChart()
        }
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }

    @IBAction private func lastMonth(_ sender: Any) {
        calendarDate.lastMonth()
        pieChartData = dataRepository.presentCategoryData(
            monthFirstDay: calendarDate.firstDay)
        switch pieChartSegmentedControl.tag {
        case 0:
            settingExpensesPieChart()
        default:
            settingIncomePieChart()
        }
        graphNavigationItem.title =
            calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        graphTableView.reloadData()
    }

    @IBAction private func pieChartSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            settingExpensesPieChart()
        default:
            settingIncomePieChart()
        }
        pieChartSegmentedControl.tag = sender.selectedSegmentIndex
        graphTableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch pieChartSegmentedControl.tag {
        case 0:
            pieChartData.forEach {
                if $0.expenses != 0 { numberOfRowsInSection += 1 }
            }
        default:
            pieChartData.forEach {
                if $0.income != 0 { numberOfRowsInSection += 1 }
            }
        }
        return numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphTableViewCell.identifier)
            as! GraphTableViewCell // swiftlint:disable:this force_cast
        cell.configure(graphData: pieChartData[indexPath.row], segmentedNumber: pieChartSegmentedControl.tag)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: GraphTableViewHeaderFooterView.identifier)
            as? GraphTableViewHeaderFooterView else { return nil }
        headerView.configure(segmentIndex: pieChartSegmentedControl.tag,
                             pieChartData: pieChartData,
                             monthFirstDay: calendarDate.firstDay)
        return headerView
    }
}
