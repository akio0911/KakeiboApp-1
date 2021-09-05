//
//  CalendarViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

final class CalendarViewController: UIViewController,
                              UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout,
                              UITableViewDataSource,
                              UITableViewDelegate,
                              CalendarFrameDelegate {

    @IBOutlet private weak var calendarCollectionView: UICollectionView!
    @IBOutlet private weak var calendarTableView: UITableView!
    @IBOutlet private weak var incomeLabel: UILabel! // 収入ラベル
    @IBOutlet private weak var expenseLabel: UILabel! // 支出ラベル
    @IBOutlet private weak var totalLabel: UILabel! // 収支ラベル
    @IBOutlet var costView: [UIView]!

    private(set) var calendarDate = CalendarDate()
    private var dataRepository = DataRepository()
    private let calendarCellLayout = CalendarCellLayout()

    // calendarHeightsのキー
    private enum Weeks {
        static let six = 6
        static let five = 5
        static let four = 4
    }

    // カレンダーの高さを週の数によって変更するためのDictionary
    private lazy var calendarHeights: [Int: NSLayoutConstraint] = {
        [Weeks.six: calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.sixWeeksHeight),
         Weeks.five: calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fiveWeeksHeight),
         Weeks.four: calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fourWeeksHeight)]
    }()

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBarButtonItem()

        settingCollectionView() // collectionViewの設定をするメソッド
        settingTableView() // tableViewの設定をするメソッド
        calendarDate.delegate = self

        navigationItem.title = calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM月")
        UserDefaults.standard.removeAll()
        calendarCollectionView.backgroundColor = UIColor.atomicTangerine
        calendarHeights[calendarDate.numberOfWeeks]?.isActive = true
//        setBorderColorCostView()
    }
// TODO - ボーダーカラーを設定
//    private func setBorderColorCostView() {
//        costView.forEach {
//            $0.layer.borderWidth = 1
//            $0.layer.borderColor = UIColor.gray.cgColor
//        }
//    }

    private func setupBarButtonItem() {
        let nextBarButton =
            UIBarButtonItem(
                image:UIImage(systemName: "chevron.right"),
                style: .plain,
                target: self,
                action: #selector(didTapNextBarButton)
            )
        navigationItem.rightBarButtonItem = nextBarButton

        let lastBarButton =
            UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(didTapLastBarButton)
            )
        navigationItem.leftBarButtonItem = lastBarButton
    }

    // collectionViewの設定
    private func settingCollectionView() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarCollectionView.register(CalendarWeekdayCollectionViewCell.nib,
                                        forCellWithReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier)
        calendarCollectionView.register(CalendarDayCollectionViewCell.nib,
                                        forCellWithReuseIdentifier: CalendarDayCollectionViewCell.identifier)
    }

    // tableViewの設定
    private func settingTableView() {
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
        calendarTableView.register(CalendarTableViewCell.nib,
                                   forCellReuseIdentifier: CalendarTableViewCell.identifier)
        calendarTableView.rowHeight = 40 // TableViewのCellの高さを指定
        calendarTableView.register(CalendarTableViewHeaderFooterView.nib,
                                   forHeaderFooterViewReuseIdentifier: CalendarTableViewHeaderFooterView.identifier)
    }

    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataRepository.loadData()
        reloadCalendar()
        settingLabel()
    }

    private func settingLabel() {
        let cost = dataRepository.presentCostValue(monthFirstDay: calendarDate.firstDay)
        incomeLabel.text = String(cost["income"]!) + "円"
        incomeLabel.textColor = .celadonBlue
        expenseLabel.text = String(cost["expense"]!) + "円"
        expenseLabel.textColor = .orangeRedCrayola
        totalLabel.text = String(cost["total"]!) + "円"
    }

    @objc private func didTapNextBarButton() {
        calendarDate.nextMonth()
        reloadCalendar()
    }

    @objc private func didTapLastBarButton() {
        calendarDate.lastMonth()
        reloadCalendar()
    }

    private func reloadCalendar() {
        calendarCollectionView.reloadData()
        calendarTableView.reloadData()
        navigationItem.title = calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM月")
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarDate.countSectionItems(at: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarWeekdayCollectionViewCell // swiftlint:disable:this force_cast
            let weekday: String = calendarDate.presentWeekday(at: indexPath.row)
            cell.configure(weekday: weekday, at: indexPath.row)
            cell.backgroundColor = UIColor.cultured
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarDayCollectionViewCell.identifier,
                for: indexPath
            ) as! CalendarDayCollectionViewCell // swiftlint:disable:this force_cast
            let date = calendarDate.presentDate(at: indexPath.row)
            let expenses = dataRepository.calcDateExpenses(date: date)
            // 表示月と月が同じ場合trueを返す
            let isDisplayedMonth =
                Calendar(identifier: .gregorian)
                .isDate(calendarDate.firstDay, equalTo: date, toGranularity: .month)
            cell.configure(date: date,
                           expenses: expenses,
                           at: indexPath.row,
                           isDisplayedMonth: isDisplayedMonth)
            cell.backgroundColor = UIColor.cultured
            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let weekdayCount: CGFloat = CGFloat(calendarDate.countWeekday())
        var height: CGFloat
        switch indexPath.section {
        case 0:
            height = calendarCellLayout.weekdayCellHeight
        default:
            height = calendarCellLayout.daysCellHeight
        }
        let totalItemWidth: CGFloat
            = collectionView.bounds.width
            - calendarCellLayout.spaceOfCell * (weekdayCount - 1)
            - (calendarCellLayout.insetForSection.left + calendarCellLayout.insetForSection.right)
        let width: CGFloat = floor(totalItemWidth / weekdayCount)

        return CGSize(
            width: width,
            height: height
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return calendarCellLayout.insetForSection
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calendarCellLayout.spaceOfCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return calendarCellLayout.spaceOfCell
    }

    // MARK: - CalendarFrameDelegate
    func calendarHeight(beforeNumberOfWeeks: Int, afterNumberOfWeeks: Int) {
        calendarHeights[beforeNumberOfWeeks]?.isActive = false
        calendarHeights[afterNumberOfWeeks]?.isActive = true
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        dataRepository.countMonthData(monthFirstDay: calendarDate.firstDay)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataRepository.countDayData(monthFirstDay: calendarDate.firstDay, at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarTableViewCell.identifier)
            as! CalendarTableViewCell // swiftlint:disable:this force_cast
        let data = dataRepository.fetchDayData(monthFirstDay: calendarDate.firstDay, at: indexPath)
        cell.setCellObject(data: data)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            dataRepository.removeData(monthFirstDay: calendarDate.firstDay, at: indexPath)
            calendarTableView.reloadData()
            calendarCollectionView.reloadData()
        }
    }

    // ヘッダーのタイトルを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CalendarTableViewHeaderFooterView.identifier)
                as? CalendarTableViewHeaderFooterView else { return nil }
        let title = dataRepository.presentDateFormat(monthFirstDay: calendarDate.firstDay, at: section)
        let data = dataRepository.fetchFirstDayData(monthFirstDay: calendarDate.firstDay, at: section)
        let expenses = dataRepository.calcDateExpenses(date: data.date)
        if expenses != 0 { headerView.setObject(title: title, expenses: expenses) }
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigationController = tabBarController?.viewControllers?[1]
            as! UINavigationController // swiftlint:disable:this force_cast
        let inputViewController = navigationController.topViewController
            as! InputViewController // swiftlint:disable:this force_cast

        inputViewController.mode = .edit
        inputViewController.editingIndexpath = indexPath
        inputViewController.editingFirstDay = calendarDate.firstDay
        tabBarController?.selectedViewController = navigationController // 画面遷移
    }
}