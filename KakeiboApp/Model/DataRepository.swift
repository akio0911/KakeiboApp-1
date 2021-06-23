//
//  DataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/06/23.
//

import Foundation

struct DataRepository {

    private let dataKey = "kakeibo"
    private var data = [IncomeAndExpenditure]()

    // UserDefaultに保存されているデータを取り出す
    mutating func loadData() {
        data.removeAll()
        let userDefaluts = UserDefaults.standard
        let data = userDefaluts.object(forKey: dataKey) as? [[String : Any]]
        guard let data = data else { return }
        data.forEach {
            let incomeAndExpenditure = IncomeAndExpenditure(from: $0)
            self.data.append(incomeAndExpenditure)
        }
    }

    // UserDefaultにデータを保存する
    mutating func saveData(incomeAndExpenditure: IncomeAndExpenditure) {
        self.data.append(incomeAndExpenditure)
        self.data.sort { $0.date < $1.date}
        var data = [[String : Any]]()
        self.data.forEach {
            let dictionary: [String : Any] = [
                "date" : $0.date,
                "category" : $0.category,
                "expenses" : $0.expenses,
                "memo" : $0.memo
            ]
            data.append(dictionary)
        }

        let userDefaluts = UserDefaults.standard
        userDefaluts.set(data, forKey: dataKey)
    }



    /*月の初日を引数から受け取り、
      その月のデータを日付別に配列で返す*/
    private func fetchMonthData(monthFirstDay: Date) -> [[IncomeAndExpenditure]] {

        var monthData = [[IncomeAndExpenditure]]()
        let calendar = Calendar(identifier: .gregorian)
        for num in 0...30 {
            let day = calendar.date(byAdding: .day, value: num, to: monthFirstDay)
            monthData.append(data.filter { $0.date == day })
        }
        return monthData.filter{ !$0.isEmpty }
    }

    /* UITableViewDataSourceのnumberOfSections(in:) -> Intで呼ばれるメソッド
       月のデータ数をInt型で返す*/
    func countMonthData(monthFirstDay: Date) -> Int {
        fetchMonthData(monthFirstDay: monthFirstDay).count
    }

    /* UITableViewDataSourceのtableView(_:,numberOfRowsInSection:) -> Intで呼ばれるメソッド
       月の日付毎のデータ数をInt型で返す*/
    func countDayData(monthFirstDay: Date, at section: Int) -> Int {
        fetchMonthData(monthFirstDay: monthFirstDay)[section].count
    }

    /* UITableViewDataSourceのcellForRowAt内で呼ばれるメソッド
       indexPathで指定されたデータを返す*/
    func fetchDayData(monthFirstDay: Date, at indexPath: IndexPath) -> IncomeAndExpenditure {
        fetchMonthData(monthFirstDay: monthFirstDay)[indexPath.section][indexPath.row]
    }

    /* UITableViewDataSourceのtableView(_:,titleForHeaderInSection:)で呼ばれるメソッド
       日付をString型で返す*/
    func presentDateFormat(monthFirstDay: Date, at section: Int) -> String {
        fetchMonthData(monthFirstDay: monthFirstDay)[section][0].date.string(dateFormat: "YYYY年MM月dd日")
    }

    /*UICollectionViewDataSourceのcollectionView(_:,cellForItemAt)内で呼ばれるメソッド
     データから日付が一致する収支を合計*/
    func calcDateExpenses(date: Date) -> Int? {
        var dateExpenses: Int? = nil
        let filteredData = data.filter { $0.date == date }
        if !filteredData.isEmpty {
            dateExpenses = filteredData.reduce(0) { $0 + $1.expenses }
        }
        return dateExpenses
    }

    /* tableViewで削除したデータと同じデータを削除し、
       その内容をUserDefaultに保存するメソッド*/
    mutating func removeData(monthFirstDay: Date, at indexPath: IndexPath) {
        var count = -1
        let dayData = fetchDayData(monthFirstDay: monthFirstDay, at: indexPath)
        for data in data {
            count += 1
            if data == dayData {
                self.data.remove(at: count)
                updateSaveData()
                break
            }
        }
        func updateSaveData() {
            var data = [[String : Any]]()
            self.data.forEach {
                let dictionary: [String : Any] = [
                    "date" : $0.date,
                    "category" : $0.category,
                    "expenses" : $0.expenses,
                    "memo" : $0.memo
                ]
                data.append(dictionary)
            }
            let userDefaluts = UserDefaults.standard
            userDefaluts.set(data, forKey: dataKey)
        }
    }
}
