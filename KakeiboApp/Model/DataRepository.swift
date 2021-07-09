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
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.data(forKey: dataKey) else { return }
        self.data.removeAll()
        if let incomeAndExpenditure = try? PropertyListDecoder().decode(Array<IncomeAndExpenditure>.self, from: data) {
            self.data += incomeAndExpenditure
        }
    }

    // UserDefaultにデータを保存する
    mutating func saveData(incomeAndExpenditure: IncomeAndExpenditure) {
        self.data.append(incomeAndExpenditure)
        self.data.sort { $0.date < $1.date }
        let userDefaluts = UserDefaults.standard
        let data = try? PropertyListEncoder().encode(self.data)
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
        return monthData.filter { !$0.isEmpty }
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

    // 日付の最初のデータを返す
    func fetchFirstDayData(monthFirstDay: Date, at section: Int) -> IncomeAndExpenditure {
        fetchMonthData(monthFirstDay: monthFirstDay)[section][0]
    }

    /* UITableViewDataSourceのtableView(_:,titleForHeaderInSection:)で呼ばれるメソッド
       日付をString型で返す*/
    func presentDateFormat(monthFirstDay: Date, at section: Int) -> String {
        fetchMonthData(monthFirstDay: monthFirstDay)[section][0].date.string(dateFormat: "YYYY年MM月dd日")
    }

    /*UICollectionViewDataSourceのcollectionView(_:,cellForItemAt)内で呼ばれるメソッド
     データから日付が一致する収支を合計*/
    func calcDateExpenses(date: Date) -> Int {
        var dateExpenses: Int
        let filteredData = data.filter { $0.date == date }
            dateExpenses = filteredData.reduce(0) { $0 + $1.expenses }
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
        // 配列dataを保存するメソッド
        func updateSaveData() {

            let userDefaluts = UserDefaults.standard
            let data = try? PropertyListEncoder().encode(self.data)
            userDefaluts.set(data, forKey: dataKey)
        }
    }

    /* tableViewで選択したデータと同じデータを変更し、
       変更内容をUserDefaultに保存するメソッド*/
    mutating func saveEditData(monthFirstDay: Date, at indexPath: IndexPath, saveData: IncomeAndExpenditure) {
        var count = -1
        let editingData = fetchDayData(monthFirstDay: monthFirstDay, at: indexPath)
        self.data.forEach {
            count += 1
            if $0 == editingData {
                self.data[count] = saveData // データを上書き
                // データを並び替えて保存
                self.data.sort { $0.date < $1.date }
                let userDefaluts = UserDefaults.standard
                let data = try? PropertyListEncoder().encode(self.data)
                userDefaluts.set(data, forKey: dataKey)
            }
        }
    }

    //　表示月のデータをカテゴリー別で返す
    private func presentCategoryMonthData(monthFirstDay: Date) -> [[IncomeAndExpenditure]] {
        var categoryMonthData = [[IncomeAndExpenditure]]()
        let monthData = data.filter {
            Calendar(identifier: .gregorian)
                .isDate($0.date, equalTo: monthFirstDay, toGranularity: .month)
        }
        let category = Category.allCases
        category.forEach {
            let category = $0
            categoryMonthData.append( monthData.filter { category == $0.category })
        }
        return categoryMonthData.filter { !$0.isEmpty }
    }

    /* 表示月のデータをカテゴリー別で分け、
       さらに、収入と支出で分ける*/
    func presentCategoryData(monthFirstDay: Date) -> [GraphData] {
        var categoryData = [GraphData]()
        let categoryMonthData = presentCategoryMonthData(monthFirstDay: monthFirstDay)
        categoryMonthData.forEach {
            let category = $0[0].category
            var income = 0 // 収入
            var expenses = 0 // 支出
            $0.forEach {
                if $0.expenses >= 0 {
                    income += $0.expenses
                } else {
                    expenses -= $0.expenses
                }
            }
            let graphData = GraphData(category: category,
                                      income: income,
                                      expenses: expenses)
            categoryData.append(graphData)
        }
        return categoryData
    }

    // 表示月のデータの収入、支出、合計を返す
    func presentCostValue(monthFirstDay: Date) -> [String: Int] {
        var income = 0
        var expense = 0
        var total: Int { income + expense }
        let filterData = data.filter { $0.date == monthFirstDay }
        filterData.forEach {
            if $0.expenses >= 0 {
                income += $0.expenses
            } else {
                expense += $0.expenses
            }
        }
        return ["income": income, "expense": expense, "total": total]
    }
}
