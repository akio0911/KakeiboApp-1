//
//  KakeiboModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxRelay

typealias KakeiboModelCompletion = (Error?) -> Void

protocol KakeiboModelProtocol {
    func setupData(userId: String?, completion: @escaping KakeiboModelCompletion)
    func loadDayData(date: Date) -> [KakeiboData]
    func loadMonthData(date: Date) -> [KakeiboData]
    func loadYearData(date: Date) -> [KakeiboData]
    func setData(userId: String, data: KakeiboData, completion: @escaping KakeiboModelCompletion)
    func deleateData(userId: String, data: KakeiboData, completion: @escaping KakeiboModelCompletion)
}

final class KakeiboModel: KakeiboModelProtocol {
    private let repository: DataRepositoryProtocol
    private var kakeiboDataArray: [KakeiboData] = []

    init(repository: DataRepositoryProtocol = KakeiboDataRepository()) {
        self.repository = repository
    }

    func setupData(userId: String?, completion: @escaping KakeiboModelCompletion) {
        guard let userId = userId else {
            kakeiboDataArray = []
            completion(nil)
            return
        }
        repository.loadData(userId: userId) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let kakeiboDataArray):
                strongSelf.kakeiboDataArray = kakeiboDataArray
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func loadDayData(date: Date) -> [KakeiboData] {
        let calendar = Calendar(identifier: .gregorian)
        return kakeiboDataArray.filter { kakeiboData in
            calendar.isDate(kakeiboData.date, equalTo: date, toGranularity: .day)
        }
    }

    func loadMonthData(date: Date) -> [KakeiboData] {
        let calendar = Calendar(identifier: .gregorian)
        return kakeiboDataArray.filter { kakeiboData in
            calendar.isDate(kakeiboData.date, equalTo: date, toGranularity: .month)
        }
    }

    func loadYearData(date: Date) -> [KakeiboData] {
        let calendar = Calendar(identifier: .gregorian)
        return kakeiboDataArray.filter { kakeiboData in
            calendar.isDate(kakeiboData.date, equalTo: date, toGranularity: .year)
        }
    }

    func setData(userId: String, data: KakeiboData, completion: @escaping KakeiboModelCompletion) {
        repository.setData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                if let index = strongSelf.kakeiboDataArray.firstIndex(where: { $0.instantiateTime == data.instantiateTime }) {
                    // 同じデータ作成日時があった場合、配列のデータを置き換え
                    strongSelf.kakeiboDataArray[index] = data
                } else {
                    // 同じデータ作成日時がなかった場合、配列にデータを追加
                    strongSelf.kakeiboDataArray.append(data)
                }
                completion(nil)
            }
        }
    }

    func deleateData(userId: String, data: KakeiboData, completion: @escaping KakeiboModelCompletion) {
        repository.deleteData(userId: userId, data: data) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                for (index, value) in strongSelf.kakeiboDataArray.enumerated() where value == data {
                    strongSelf.kakeiboDataArray.remove(at: index)
                    completion(nil)
                    return
                }
                completion(nil)
            }
        }
    }
}
