//
//  InputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import RxSwift
import RxCocoa

protocol InputViewModelInput {
    func didTapSaveButton(data: KakeiboData)
    func didTapCancelButton()
    func editData(data: KakeiboData)
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
    var mode: InputViewModel.Mode { get }
    var date: Driver<String> { get }
    var category: Driver<String> { get }
    var segmentIndex: Driver<Int> { get }
    var balance: Driver<String> { get }
    var memo: Driver<String> { get }
}

protocol InputViewModelType {
    var inputs: InputViewModelInput { get }
    var outputs: InputViewModelOutput { get }
}

final class InputViewModel: InputViewModelInput, InputViewModelOutput {
    enum Event {
        case dismiss
    }

    enum Mode {
        case add
        case edit(KakeiboData)
    }

    let mode: Mode
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let eventRelay = PublishRelay<Event>()
    private var kakeiboDataArray: [KakeiboData] = []
    private let dateRelay = PublishRelay<String>()
    private let categoryRelay = PublishRelay<String>()
    private let segmentIndexRelay = PublishRelay<Int>()
    private let balanceRelay = PublishRelay<String>()
    private let memoRelay = PublishRelay<String>()

    init(model: KakeiboModelProtocol = ModelLocator.shared.model,
         mode: Mode) {
        self.model = model
        self.mode = mode
        setupBinding()
    }

    private func setupBinding() {
        model.dataObservable
            .subscribe(onNext: { [weak self] kakeiboDataArray in
                guard let self = self else { return }
                self.kakeiboDataArray = kakeiboDataArray
            })
            .disposed(by: disposeBag)
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    var date: Driver<String> {
        dateRelay.asDriver(onErrorDriveWith: .empty())
    }

    var category: Driver<String> {
        categoryRelay.asDriver(onErrorDriveWith: .empty())
    }

    var segmentIndex: Driver<Int> {
        segmentIndexRelay.asDriver(onErrorDriveWith: .empty())
    }

    var balance: Driver<String> {
        balanceRelay.asDriver(onErrorDriveWith: .empty())
    }

    var memo: Driver<String> {
        memoRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapSaveButton(data: KakeiboData) {
        switch mode {
        case .add:
            model.addData(data: data)
        case .edit(let beforeData):
            if let firstIndex = kakeiboDataArray.firstIndex(where: { $0 == beforeData }) {
                model.updateData(index: firstIndex, data: data)
            }
        }
        eventRelay.accept(.dismiss)
    }

    func didTapCancelButton() {
        eventRelay.accept(.dismiss)
    }

    func editData(data: KakeiboData) {
        dateRelay.accept(DateUtility.stringFromDate(date: data.date, format: "YYYY年MM月dd日"))
        categoryRelay.accept(data.category.rawValue)
        switch data.balance {
        case .income(let income):
            segmentIndexRelay.accept(1)
            balanceRelay.accept(String(income))
        case .expense(let expense):
            segmentIndexRelay.accept(0)
            balanceRelay.accept(String(expense))
        }
        memoRelay.accept(data.memo)
    }
}

// MARK: - InputViewModelType
extension InputViewModel: InputViewModelType {
    var inputs: InputViewModelInput {
        return self
    }

    var outputs: InputViewModelOutput {
        return self
    }
}
