//
//  CalendarViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class CalendarViewController: UIViewController,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout,
                                    UITableViewDelegate,
                                    CalendarTableViewDataSourceDelegate {

    @IBOutlet private weak var calendarNavigationItem: UINavigationItem!
    @IBOutlet private weak var nextBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var lastBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var calendarCollectionView: UICollectionView!
    @IBOutlet private weak var calendarTableView: UITableView!
    @IBOutlet private weak var incomeLabel: UILabel! // 収入ラベル
    @IBOutlet private weak var expenseLabel: UILabel! // 支出ラベル
    @IBOutlet private weak var balanceLabel: UILabel! // 収支ラベル
    @IBOutlet private var costView: [UIView]!

    private let viewModel: CalendarViewModelType
    private let disposeBag = DisposeBag()
    private let calendarCollectionViewDataSource = CalendarCollectionViewDataSource()
    private let calendarTableViewDataSource = CalendarTableViewDataSource()
    private var headerDataArray: [HeaderDateKakeiboData] = []
    private var collectionViewNSLayoutConstraint: NSLayoutConstraint?
    private var didHighlightItemIndexPath: IndexPath = []

    init(viewModel: CalendarViewModelType = CalendarViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupBarButtonItem()
        setupSwipeGestureRecognizer()
        setupCollectionView() // collectionViewの設定をするメソッド
        setupTableView() // tableViewの設定をするメソッド
        navigationItem.title = "カレンダー"
        calendarTableViewDataSource.delegate = self
    }

    private func setupBarButtonItem() {
        let nextBarButton =
            UIBarButtonItem(
                image:UIImage(systemName: "square.and.pencil"),
                style: .plain,
                target: self,
                action: #selector(didTapInputBarButton)
            )
        navigationItem.rightBarButtonItem = nextBarButton
    }

    private func setupSwipeGestureRecognizer() {
        let directionArray: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        directionArray.forEach {
            let swipeRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(collectionViewSwipeGesture(sender:))
            )
            swipeRecognizer.direction = $0
            calendarCollectionView.addGestureRecognizer(swipeRecognizer)
        }
    }

    private func setupBinding() {
        nextBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.didHighlightItemIndexPath = []
                self.viewModel.inputs.didTapNextBarButton()
            })
            .disposed(by: disposeBag)

        lastBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.didHighlightItemIndexPath = []
                self.viewModel.inputs.didTapLastBarButton()
            })
            .disposed(by: disposeBag)

        let collectionViewDataObservable = viewModel.outputs.dayItemDataObservable
            .share()

        collectionViewDataObservable
            .bind(to: calendarCollectionView.rx.items(dataSource: calendarCollectionViewDataSource))
            .disposed(by: disposeBag)

        collectionViewDataObservable
            .subscribe(onNext: { [weak self] secondSectionItemData in
                guard let self = self else { return }
                let numberOfWeeksInMonth: CGFloat = ceil(CGFloat(secondSectionItemData.count / 7))
                self.collectionViewNSLayoutConstraint?.isActive = false
                self.collectionViewNSLayoutConstraint =
                    self.calendarCollectionView.heightAnchor.constraint(
                        equalToConstant:
                            self.weekdayCellHeight
                            + self.dayCellHeight * numberOfWeeksInMonth
                            + self.spaceOfCell * (numberOfWeeksInMonth - 1)
                            + self.insetForSection.bottom * 2
                            + self.insetForSection.top * 2
                            + self.insetForSection.left * 2
                            + self.insetForSection.right * 2
                    )
                self.collectionViewNSLayoutConstraint?.isActive = true
            })
            .disposed(by: disposeBag)

        viewModel.outputs.cellDateDataObservable
            .bind(to: calendarTableView.rx.items(dataSource: calendarTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.headerDateDataObservable
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.headerDataArray = data
            })
            .disposed(by: disposeBag)

        viewModel.outputs.navigationTitle
            .drive(calendarNavigationItem.rx.title)
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

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                let inputViewController = InputViewController(
                    viewModel: InputViewModel(mode: InputViewModel.Mode(event: event))
                )
                let navigationController = UINavigationController(
                    rootViewController: inputViewController
                )
                self.present(navigationController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    // collectionViewの設定
    private func setupCollectionView() {
        calendarCollectionView.register(
            CalendarWeekdayCollectionViewCell.nib,
            forCellWithReuseIdentifier: CalendarWeekdayCollectionViewCell.identifier
        )
        calendarCollectionView.register(
            CalendarDayCollectionViewCell.nib,
            forCellWithReuseIdentifier: CalendarDayCollectionViewCell.identifier
        )
        calendarCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        calendarCollectionView.backgroundColor = UIColor.separator
    }

    // tableViewの設定
    private func setupTableView() {
        calendarTableView.register(
            CalendarTableViewCell.nib,
            forCellReuseIdentifier: CalendarTableViewCell.identifier
        )
        calendarTableView.register(
            CalendarTableViewHeaderFooterView.nib,
            forHeaderFooterViewReuseIdentifier: CalendarTableViewHeaderFooterView.identifier
        )
        if #available(iOS 15.0, *) {
            calendarTableView.sectionHeaderTopPadding = 0
        } 
        calendarTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    // MARK: - @objc(BarButtonItem)
    @objc private func didTapInputBarButton() {
        viewModel.inputs.didTapInputBarButton(didHighlightItem: didHighlightItemIndexPath)
        didHighlightItemIndexPath = []
    }

    // MARK: - @objc(SwipeGestureRecognizer)
    @objc private func collectionViewSwipeGesture(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            viewModel.inputs.didTapLastBarButton()
        case UISwipeGestureRecognizer.Direction.left:
            viewModel.inputs.didTapNextBarButton()
        default:
            break
        }
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemIndexPath = indexPath
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    private let spaceOfCell: CGFloat = 1 // セルの間隔
    private let weekdayCellHeight: CGFloat = 20 // 週のセルの高さ
    private let dayCellHeight: CGFloat = 40 // 日付のセルの高さ
    private let numberOfDaysInWeek: CGFloat = 7 // 1週間の日数
    private let insetForSection = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat
        switch indexPath.section {
        case 0:
            height = weekdayCellHeight
        case 1:
            height = dayCellHeight
        default:
            fatalError("collectionViewで想定していないsection")
        }
        
        let totalItemWidth: CGFloat
            = collectionView.bounds.width
            - spaceOfCell * (numberOfDaysInWeek - 1)
        let width: CGFloat = floor(totalItemWidth / numberOfDaysInWeek * 1000) / 1000

        return CGSize(
            width: width,
            height: height
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insetForSection
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spaceOfCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spaceOfCell
    }

    // MARK: - UITableViewDelegate
    // ヘッダーのタイトルを設定
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CalendarTableViewHeaderFooterView.identifier)
                as? CalendarTableViewHeaderFooterView else { return nil }
        headerView.configure(data: headerDataArray[section])
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(index: indexPath)
    }

    // MARK: - CalendarTableViewDataSourceDelegate
    // 自作delegate
    func didDeleteCell(index: IndexPath) {
        viewModel.inputs.didDeleateCell(index: index)
    }
}

// MARK: - extension InputViewModel.Mode
extension InputViewModel.Mode {
    init(event: CalendarViewModel.Event) {
        switch event {
        case .presentAdd(let date):
            self = .add(date)
        case .presentEdit(let data):
            self = .edit(data)
        }
    }
}
