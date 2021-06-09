//
//  DataRepository.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/30.
//

import Foundation

class DataRepository {
    
    private let dataKey = "kakeibo"
    var data = [IncomeAndExpenditure]()
    
    func loadData() {
        data.removeAll()
        let userDefaluts = UserDefaults.standard
        let data = userDefaluts.object(forKey: dataKey) as? [[String : Any]]
        guard let d = data else { return }
        for i in d {
            let incomeAndExpenditure = IncomeAndExpenditure(from: i)
            self.data.append(incomeAndExpenditure)
        }
    }
    
    func saveData(incomeAndExpenditure: IncomeAndExpenditure) {
        self.data.append(incomeAndExpenditure)
        self.data.sort { $0.date < $1.date}
        var data = [[String : Any]]()
        for i in self.data {
            let dictionaries: [String : Any] = [
                "date" : i.date,
                "category" : i.category,
                "expenses" : i.expenses,
                "memo" : i.memo
            ]
            data.append(dictionaries)
        }
        let userDefaluts = UserDefaults.standard
        userDefaluts.set(data, forKey: dataKey)
        userDefaluts.synchronize()
    }
    
    func update() {
        var data = [[String : Any]]()
        for i in self.data {
            let dictionaries: [String : Any] = [
                "date" : i.date,
                "category" : i.category,
                "expenses" : i.expenses,
                "memo" : i.memo
            ]
            data.append(dictionaries)
        }
        let userDefaluts = UserDefaults.standard
        userDefaluts.set(data, forKey: dataKey)
        userDefaluts.synchronize()
    }
}
