//
//  KakeiboModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/05.
//

import RxSwift
import RxRelay

protocol KakeiboModelProtocol {
    var dataObservable: Observable<[KakeiboData]> { get }
    func loadData(userId: String?)
    func addData(userId: String, data: KakeiboData)
    func deleateData(userId: String, index: Int)
    func updateData(userId: String, index: Int, data: KakeiboData)
}

final class KakeiboModel: KakeiboModelProtocol {
    private let dataRelay = BehaviorRelay<[KakeiboData]>(value: [])
    private let repository: DataRepositoryProtocol

    init(repository: DataRepositoryProtocol = KakeiboDataRepository()) {
        self.repository = repository
    }

    var dataObservable: Observable<[KakeiboData]> {
        dataRelay.asObservable()
    }

    func loadData(userId: String?) {
        guard let userId = userId else {
            dataRelay.accept([])
            return
        }
        repository.loadData(userId: userId) { [weak self] kakeiboData in
            guard let strongSelf = self else { return }
            strongSelf.dataRelay.accept(kakeiboData)
        }
    }

    func addData(userId: String, data: KakeiboData) {
        var kakeiboData = dataRelay.value
        kakeiboData.append(data)
        dataRelay.accept(kakeiboData)
        repository.setData(userId: userId, data: data) { error in
            // TODO: 後でエラー処理を実装
        }
    }

    func deleateData(userId: String, index: Int) {
        var kakeiboData = dataRelay.value
        let data = kakeiboData[index]
        repository.deleteData(userId: userId, data: data) { error in
            // TODO: 後でエラー処理を実装
        }
        kakeiboData.remove(at: index)
        dataRelay.accept(kakeiboData)
    }

    func updateData(userId: String, index: Int, data: KakeiboData) {
        var kakeiboData = dataRelay.value
        let beforeData = kakeiboData[index]
        kakeiboData[index] = data
        dataRelay.accept(kakeiboData)
        repository.deleteData(userId: userId, data: beforeData) { error in
            // TODO: 後でエラー処理を実装
        }
        repository.setData(userId: userId, data: data) { error in
            // TODO: 後でエラー処理を実装
        }
    }
}
