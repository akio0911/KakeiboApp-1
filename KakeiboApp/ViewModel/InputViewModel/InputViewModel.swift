//
//  InputViewModel.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/09/07.
//

import RxSwift
import RxCocoa

protocol InputViewModelInput {
    func didTapSaveButton(dateText: String, categoryText: String,
                          balanceText: String, segmentIndex: Int, memo: String)
    func didTapCancelButton()
}

protocol InputViewModelOutput {
    var event: Driver<InputViewModel.Event> { get }
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
        case edit(Int)
    }

    private let mode: Mode
    private let model: KakeiboModelProtocol
    private let disposeBag = DisposeBag()
    private let eventRelay = PublishRelay<Event>()

    init(model: KakeiboModelProtocol = ModelLocator.shared.model,
         mode: Mode) {
        self.model = model
        self.mode = mode
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapSaveButton(dateText: String, categoryText: String,
                          balanceText: String, segmentIndex: Int, memo: String) {
        let balance: Balance
        switch segmentIndex {
        case 0:
            balance = Balance(expense: balanceText)
        case 1:
            balance = Balance(income: balanceText)
        default:
            fatalError("segmentIndexで想定していないIndex")
        }

        let kakeiboData = KakeiboData(
            stringDate: dateText, category: categoryText, balance: balance, memo: memo
        )

        switch mode {
        case .add:
            model.addData(data: kakeiboData)
        case .edit(let index):
            model.updateData(index: index, data: kakeiboData)
        }
        eventRelay.accept(.dismiss)
    }

    func didTapCancelButton() {
        eventRelay.accept(.dismiss)
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
