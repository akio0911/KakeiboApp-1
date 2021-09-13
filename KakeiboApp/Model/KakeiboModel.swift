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
    func addData(data: KakeiboData)
    func deleateData(index: Int)
    func updateData(index: Int, data: KakeiboData)
}

final class KakeiboModel: KakeiboModelProtocol {

    private let dataRelay = BehaviorRelay<[KakeiboData]>(value: [])
    private let repository: DataRepositoryProtocol

    init(repository: DataRepositoryProtocol = KakeiboDataRepository()) {
        self.repository = repository
        repository.loadData { [weak self] kakeiboData in
            guard let self = self else { return }
            self.dataRelay.accept(kakeiboData)
        }
    }

    var dataObservable: Observable<[KakeiboData]> {
        dataRelay.asObservable()
    }

    func addData(data: KakeiboData) {
        var kakeiboData = dataRelay.value
        kakeiboData.append(data)
        dataRelay.accept(kakeiboData)
        repository.addData(data: data)
    }

    func deleateData(index: Int) {
        var kakeiboData = dataRelay.value
        let data = kakeiboData[index]
        repository.deleteData(data: data)
        kakeiboData.remove(at: index)
        dataRelay.accept(kakeiboData)
    }

    func updateData(index: Int, data: KakeiboData) {
        var kakeiboData = dataRelay.value
        let beforeData = kakeiboData[index]
        kakeiboData[index] = data
        dataRelay.accept(kakeiboData)
        repository.deleteData(data: beforeData)
        repository.addData(data: data)
    }
}
