//
//  CalendarViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var dateTitle: UILabel!
    @IBOutlet private weak var nextMonthButton: UIButton!
    @IBOutlet private weak var lastMonthButton: UIButton!
    @IBOutlet private weak var cardCollectionView: UICollectionView!
    @IBOutlet private weak var calendarTableView: UITableView!
    @IBOutlet private weak var incomeLabel: UILabel! // 収入ラベル
    @IBOutlet private weak var expenseLabel: UILabel! // 支出ラベル
    @IBOutlet private weak var balanceLabel: UILabel! // 収支ラベル
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var noDataLabel: UILabel!
    @IBOutlet private weak var inputButton: UIButton!

    private let viewModel: CalendarViewModelType = CalendarViewModel()
    private let disposeBag = DisposeBag()
    private var cardCollectionViewItems: [Date] = []
    private var selectedItem: CalendarItem?
    private var selectedCardIndexPath: IndexPath = []

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupCollectionView() // collectionViewの設定をするメソッド
        setupTableView() // tableViewの設定をするメソッド
        viewModel.inputs.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.onViewWillApper()
    }

    // swiftlint:disable:next function_body_length
    private func setupBinding() {
        nextMonthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // 次のカードがない場合、何もしない
                guard let self = self,
                      self.selectedCardIndexPath.row != self.cardCollectionViewItems.count - 1 else {
                    return
                }
                self.showNextMonth()
            })
            .disposed(by: disposeBag)

        lastMonthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                // 前のカードがない場合、何もしない
                guard let self = self, self.selectedCardIndexPath.row != 0 else { return }
                self.showLastMonth()
            })
            .disposed(by: disposeBag)

        inputButton.rx.tap
            .subscribe { [weak self] _ in
                self?.viewModel.inputs.didTapInputButton(date: self?.selectedItem?.date)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.collectionViewItemsObservable
            .subscribe(onNext: { [weak self] cardCollectionViewItems in
                guard let strongSelf = self else { return }
                strongSelf.cardCollectionViewItems = cardCollectionViewItems
                strongSelf.cardCollectionView.reloadData()
                if !cardCollectionViewItems.isEmpty {
                    strongSelf.selectedCardIndexPath = IndexPath(row: cardCollectionViewItems.count / 2, section: 0)
                    strongSelf.cardCollectionView.scrollToItem(
                        at: strongSelf.selectedCardIndexPath,
                        at: .centeredHorizontally,
                        animated: false)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.navigationTitle
            .drive(dateTitle.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.incomeText
            .drive(incomeLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.expenseText
            .drive(expenseLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.balanceTxet
            .drive(balanceLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.isAnimatedIndicator
            .drive(onNext: animateActivityIndicatorView(isAnimated:))
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive { [weak self] event in
                switch event {
                case .selectedAdd, .selectedEdit:
                    self?.selectedInputVC(event: event)
                case .showErrorAlert:
                    self?.showErrorAlert()
                case .reloadData:
                    self?.cardCollectionView.reloadData()
                    self?.calendarTableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }

    private func animateActivityIndicatorView(isAnimated: Bool) {
        if isAnimated {
            showProgress()
        } else {
            hideProgress()
        }
    }

    // InputViewControllerへ画面遷移
    private func selectedInputVC(event: CalendarViewModel.Event) {
        guard let inputViewController = R.storyboard.input().instantiateInitialViewController() as? InputViewController else {
            return
        }
        switch event {
        case .selectedAdd(let date):
            inputViewController.inject(mode: .add(date))
        case .selectedEdit(let kakeiboData, let categoryData):
            inputViewController.inject(mode: .edit(kakeiboData, categoryData), isHiddenButtomToolbar: false)
        default:
            return
        }
        inputViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(inputViewController, animated: true)
    }

    // collectionViewの設定
    private func setupCollectionView() {
        cardCollectionView.register(
            CardCollectionViewCell.nib,
            forCellWithReuseIdentifier: CardCollectionViewCell.identifier
        )
        cardCollectionView.dataSource = self
        cardCollectionView.delegate = self
        let layout = CardCollectionViewFlowLayout()
        layout.delegate = self
        cardCollectionView.collectionViewLayout = layout
        cardCollectionView.decelerationRate = .fast
    }

    // tableViewの設定
    private func setupTableView() {
        calendarTableView.register(
            CalendarTableViewCell.nib,
            forCellReuseIdentifier: CalendarTableViewCell.identifier
        )
        calendarTableView.register(
            CalendarTableViewHeaderCell.nib,
            forCellReuseIdentifier: CalendarTableViewHeaderCell.identifier
        )
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
    }

    private func showNextMonth() {
        viewModel.inputs.didActionNextMonth()
        selectedCardIndexPath.formIndex(&selectedCardIndexPath.row, offsetBy: 1)
        cardCollectionView.scrollToItem(
            at: selectedCardIndexPath,
            at: .centeredHorizontally,
            animated: true
        )
        setBarButtonItem()
    }

    private func showLastMonth() {
        viewModel.inputs.didActionLastMonth()
        selectedCardIndexPath.formIndex(&selectedCardIndexPath.row, offsetBy: -1)
        cardCollectionView.scrollToItem(
            at: selectedCardIndexPath,
            at: .centeredHorizontally,
            animated: true
        )
        setBarButtonItem()
    }

    private func setBarButtonItem() {
        if selectedCardIndexPath.row == cardCollectionViewItems.count - 1 {
            nextMonthButton.isHidden = true
        } else {
            nextMonthButton.isHidden = false
        }

        if selectedCardIndexPath.row == 0 {
            lastMonthButton.isHidden = true
        } else {
            lastMonthButton.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 52, height: 315)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView,
        let layout = collectionView.collectionViewLayout as? CardCollectionViewFlowLayout else {
            return
        }
        layout.prepareForPaging()
    }
}

// MARK: - UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cardCollectionViewItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath
        ) as? CardCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(
            displayDate: cardCollectionViewItems[indexPath.row],
            selectedItem: selectedItem,
            items: viewModel.outputs.loadCalendarItems(date: cardCollectionViewItems[indexPath.row])
        )
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedItem = selectedItem else {
            return
        }
        let didSelectData = viewModel.outputs.loadCalendarItem(date: selectedItem.date).dataArray[indexPath.row - 1]
        viewModel.inputs.didSelectRowAt(kakeiboData: didSelectData.1, categoryData: didSelectData.0)
    }
}

// MARK: - UITableViewDataSource
extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedItem = selectedItem,
              !viewModel.outputs.loadCalendarItem(date: selectedItem.date).dataArray.isEmpty else {
            noDataLabel.isHidden = false
            footerView.frame.size.height = 91
            return 0
        }
        noDataLabel.isHidden = true
        footerView.frame.size.height = 57
        return (viewModel.outputs.loadCalendarItem(date: selectedItem.date).dataArray.count) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CalendarTableViewHeaderCell.identifier
            ) as? CalendarTableViewHeaderCell,
                  let selectedItem = selectedItem else {
                return UITableViewCell()
            }
            cell.configure(calendarItem: viewModel.outputs.loadCalendarItem(date: selectedItem.date))
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CalendarTableViewCell.identifier
            ) as? CalendarTableViewCell,
                  let selectedItem = selectedItem else {
                return UITableViewCell()
            }
            cell.configure(data: viewModel.outputs.loadCalendarItem(date: selectedItem.date).dataArray[indexPath.row - 1])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row != 0 else {
            return false
        }
        return true // cellの変更を許可
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let selectedItem = selectedItem {
            let calendarItem = viewModel.outputs.loadCalendarItem(date: selectedItem.date)
            viewModel.inputs.didDeleateCell(kakeiboData: calendarItem.dataArray[indexPath.row - 1].1)
        }
    }
}

// MARK: - CardCollectionViewFlowLayoutDelegate
extension CalendarViewController: CardCollectionViewFlowLayoutDelegate {
    func didSwipeCard(displayCardIndexPath: IndexPath) {
        let distance = selectedCardIndexPath.distance(from: selectedCardIndexPath.row, to: displayCardIndexPath.row)
        if distance > 0 {
            showNextMonth()
        } else if distance < 0 {
            showLastMonth()
        }
    }
}

// MARK: - CardCollectionViewCellDelegate
extension CalendarViewController: CardCollectionViewCellDelegate {
    func didSelectItemAt(calendarItem: CalendarItem) {
        selectedItem = calendarItem
        cardCollectionView.visibleCells.forEach { cell in
            if let cardCollectionViewCell = cell as? CardCollectionViewCell {
                cardCollectionViewCell.reloadSelectedItem(selectedItem: calendarItem)
            }
        }
        calendarTableView.reloadData()
    }
}
