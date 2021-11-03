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
    func addData(userId: String?, data: KakeiboData)
    func deleateData(userId: String?, index: Int)
    func updateData(userId: String?, index: Int, data: KakeiboData)
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

    // TODO: userIdがない場合の処理(アラート)
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

    // TODO: userIdがない場合の処理(アラート)
    func addData(userId: String?, data: KakeiboData) {
        guard let userId = userId else { return }
        var kakeiboData = dataRelay.value
        kakeiboData.append(data)
        dataRelay.accept(kakeiboData)
        repository.addData(userId: userId, data: data)
    }

    // TODO: userIdがない場合の処理(アラート)
    func deleateData(userId: String?, index: Int) {
        guard let userId = userId else { return }
        var kakeiboData = dataRelay.value
        let data = kakeiboData[index]
        repository.deleteData(userId: userId, data: data)
        kakeiboData.remove(at: index)
        dataRelay.accept(kakeiboData)
    }

    // TODO: userIdがない場合の処理(アラート)
    func updateData(userId: String?, index: Int, data: KakeiboData) {
        guard let userId = userId else { return }
        var kakeiboData = dataRelay.value
        let beforeData = kakeiboData[index]
        kakeiboData[index] = data
        dataRelay.accept(kakeiboData)
        repository.deleteData(userId: userId, data: beforeData)
        repository.addData(userId: userId, data: data)
    }
}
