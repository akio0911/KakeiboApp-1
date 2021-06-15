//
//  CalendarViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, CalendarFrameDelegate {
    
    @IBOutlet private weak var barTitle: UINavigationItem!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    
    let calendarDate = CalendarDate()
    var dataRepository = DataRepository()
    private let calendarCellLayout = CalendarCellLayout()
    private var calendarListLayout = CalendarListLayout()
    
    private var sixWeeksConstraint: NSLayoutConstraint!
    private var fiveWeeksConstraint: NSLayoutConstraint!
    private var fourWeeksConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        calendarDate.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        barTitle.title = calendarDate.carendarTitle
        UserDefaults.standard.removeAll()
        collectionView.backgroundColor = UIColor.atomicTangerine
        
        sixWeeksConstraint = collectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.sixNumberOfWeeksHeight
        )
        fiveWeeksConstraint = collectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fiveNumberOfWeeksHeight
        )
        fourWeeksConstraint = collectionView.heightAnchor.constraint(
            equalToConstant: calendarCellLayout.fourNumberOfWeeksHeight
        )
        
        switch calendarDate.nuberOfWeeks {
        case 6:
            sixWeeksConstraint.isActive = true
        case 5:
            fiveWeeksConstraint.isActive = true
        default:
            fourWeeksConstraint.isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataRepository.loadData()
        collectionView.reloadData()
        calendarListLayout.loadMonthData(firstDay: calendarDate.firstDay, data: dataRepository.data)
        tableView.reloadData()
    }
    
    @IBAction private func nextMonth(_ sender: Any) {
        calendarDate.nextMonth()
        collectionView.reloadData()
        calendarListLayout.loadMonthData(firstDay: calendarDate.firstDay, data: dataRepository.data)
        tableView.reloadData()
        barTitle.title = calendarDate.carendarTitle
    }
    
    @IBAction private func lastMonth(_ sender: Any) {
        calendarDate.lastMonth()
        collectionView.reloadData()
        calendarListLayout.loadMonthData(firstDay: calendarDate.firstDay, data: dataRepository.data)
        tableView.reloadData()
        barTitle.title = calendarDate.carendarTitle
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? calendarDate.weekday.count : calendarDate.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: UICollectionViewCell!
        var label: UILabel!
        
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekdayCell", for: indexPath)
            label = cell.contentView.viewWithTag(3) as? UILabel
            label.text = calendarDate.weekday[indexPath.row]
        } else if indexPath.section == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath)
            label = cell.contentView.viewWithTag(1) as? UILabel
            let date = calendarDate.days[indexPath.row]
            label.text = date.string(dateFormat: "d")
            let expensesLabel = cell.contentView.viewWithTag(2) as? UILabel
            if let expenses = calendarCellLayout.expenses(date: date, saveData: dataRepository.data) {
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
        if indexPath.section == 1 {
            if calendarDate.firstDay.string(dateFormat: "MM") !=
                calendarDate.days[indexPath.row].string(dateFormat: "MM"){
                label.textColor = .gray
            }
        }
        
        cell.backgroundColor = UIColor.cultured
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let weekdayCount:CGFloat = CGFloat(calendarDate.weekday.count)
        var height: CGFloat
        switch indexPath.section {
        case 0:
            height = calendarCellLayout.WeekdayCellHeight
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
    func calendarHeight(beforeNumberOfWeeks: Int, AfterNuberOfWeeks: Int) {
        
        switch beforeNumberOfWeeks {
        case 6:
            sixWeeksConstraint.isActive = false
        case 5:
            fiveWeeksConstraint.isActive = false
        default:
            fourWeeksConstraint.isActive = false
        }
        
        switch AfterNuberOfWeeks {
        case 6:
            sixWeeksConstraint.isActive = true
        case 5:
            fiveWeeksConstraint.isActive = true
        default:
            fourWeeksConstraint.isActive = true
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        calendarListLayout.monthData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        calendarListLayout.monthData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let data = calendarListLayout.monthData[indexPath.section][indexPath.row]
        cell.textLabel?.text = data.category
        cell.detailTextLabel?.text = "\(data.expenses):\(data.memo)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        calendarListLayout.monthData[section][safe:0]?.date.string(dateFormat: "YYYY年MM月dd日")
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            var count = -1
            let data = calendarListLayout.monthData[indexPath.section][indexPath.row]
            for d in dataRepository.data {
                count += 1
                if d.date == data.date {
                    count += indexPath.row
                    break
                }
            }
            dataRepository.data.remove(at: count)
            calendarListLayout.loadMonthData(firstDay: calendarDate.firstDay, data: dataRepository.data)
            tableView.reloadData()
            collectionView.reloadData()
            dataRepository.update()
        }
    }
}





