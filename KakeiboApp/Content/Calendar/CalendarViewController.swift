//
//  CalendarViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

class CalendarViewController: UIViewController,
                              UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout,
                              UITableViewDataSource,
                              UITableViewDelegate,
                              CalendarFrameDelegate {

    @IBOutlet private weak var calendarNavigationItem: UINavigationItem!
    @IBOutlet private weak var calendarCollectionView: UICollectionView!
    @IBOutlet private weak var calendarTableView: UITableView!

    let calendarDate = CalendarDate()
    var dataRepository = DataRepository()
    private let calendarCellLayout = CalendarCellLayout()
    private enum Weeks {

        // calendarHeightsのキー
        static let six = 6
        static let five = 5
        static let four = 4
    }

    // 週の数によってカレンダーの高さを変更するためのDictionary型
    private lazy var calendarHeights: [Int : NSLayoutConstraint] = {
        [Weeks.six : calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.sixWeeksHeight),
         Weeks.five : calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fiveWeeksHeight),
         Weeks.four : calendarCollectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fourWeeksHeight)]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarDate.delegate = self
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
        calendarNavigationItem.title = calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
        UserDefaults.standard.removeAll()
        calendarCollectionView.backgroundColor = UIColor.atomicTangerine
        calendarHeights[calendarDate.numberOfWeeks]?.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataRepository.loadData()
        calendarCollectionView.reloadData()
        calendarTableView.reloadData()
    }
    
    @IBAction private func nextMonth(_ sender: Any) {
        calendarDate.nextMonth()
        calendarCollectionView.reloadData()
        calendarTableView.reloadData()
        calendarNavigationItem.title = calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
    }
    
    @IBAction private func lastMonth(_ sender: Any) {
        calendarDate.lastMonth()
        calendarCollectionView.reloadData()
        calendarTableView.reloadData()
        calendarNavigationItem.title = calendarDate.convertStringFirstDay(dateFormat: "YYYY年MM日")
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        calendarDate.countSectionItems(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell!
        var label: UILabel!
        
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekdayCell", for: indexPath)
            label = cell.contentView.viewWithTag(3) as? UILabel
            label.text = calendarDate.presentWeekday(at: indexPath.row)
        } else if indexPath.section == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
            label = cell.contentView.viewWithTag(1) as? UILabel
            let date = calendarDate.presentDate(at: indexPath.row)
            label.text = date.string(dateFormat: "d")
            let expensesLabel = cell.contentView.viewWithTag(2) as? UILabel
            if let expenses = dataRepository.calcDateExpenses(date: date) {
                expensesLabel?.text = String(expenses)
                expensesLabel?.textColor = UIColor.orangeRedCrayola
            } else {
                expensesLabel?.text = ""
            }
        }
        switch indexPath.row % 7 {
        case 0:
            label.textColor = UIColor.orangeRedCrayola
        case 6:
            label.textColor = UIColor.celadonBlue
        default:
            label.textColor = UIColor.spaceCadet
        }
        if indexPath.section == 1, calendarDate.convertStringFirstDay(dateFormat: "MM") !=
            calendarDate.presentDate(at: indexPath.row).string(dateFormat: "MM"){
            label.textColor = .gray
        }

        
        cell.backgroundColor = UIColor.cultured
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let weekdayCount:CGFloat = CGFloat(calendarDate.countWeekday())
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return calendarCellLayout.insetForSection
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calendarCellLayout.spaceOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let data = dataRepository.fetchDayData(monthFirstDay: calendarDate.firstDay, at: indexPath)
        cell.textLabel?.text = data.category
        cell.detailTextLabel?.text = "\(data.expenses):\(data.memo)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataRepository.presentDateFormat(monthFirstDay: calendarDate.firstDay, at: section)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            dataRepository.removeData(monthFirstDay: calendarDate.firstDay, at: indexPath)
            calendarTableView.reloadData()
            calendarCollectionView.reloadData()
        }
    }
}





