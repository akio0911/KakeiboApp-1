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
    private var headerDataArray: [CalendarItem] = []
    private var collectionViewNSLayoutConstraint: NSLayoutConstraint?
    private var didHighlightItemIndexPath: IndexPath = []
    private var activityIndicatorView: UIActivityIndicatorView!

    init(viewModel: CalendarViewModelType = CalendarViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicatorView()
        setupBinding()
        setupBarButtonItem()
        setupSwipeGestureRecognizer()
        setupCollectionView() // collectionViewの設定をするメソッド
        setupTableView() // tableViewの設定をするメソッド
        navigationItem.title = "カレンダー"
        calendarTableViewDataSource.delegate = self
        viewModel.inputs.onViewDidLoad()
    }

    // ActivityIndicatorViewを反映
    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.backgroundColor = .systemGray5.withAlphaComponent(0.6)
        activityIndicatorView.layer.cornerRadius = 10
        activityIndicatorView.layer.masksToBounds = true
        view.addSubview(activityIndicatorView)
    }

    private func setupBarButtonItem() {
        let nextBarButton =
        UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
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

    // swiftlint:disable:next function_body_length
    private func setupBinding() {
        nextBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.didHighlightItemIndexPath = []
                self.viewModel.inputs.didActionNextMonth()
            })
            .disposed(by: disposeBag)

        lastBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.didHighlightItemIndexPath = []
                self.viewModel.inputs.didActionLastMonth()
            })
            .disposed(by: disposeBag)

        let collectionViewDataObservable = viewModel.outputs.collectionViewItemObservable
            .share()

        collectionViewDataObservable
            .bind(to: calendarCollectionView.rx.items(dataSource: calendarCollectionViewDataSource))
            .disposed(by: disposeBag)

        collectionViewDataObservable
            .subscribe(onNext: setupCollectionViewNSLayoutConstraint(secondSectionItemData:))
            .disposed(by: disposeBag)

        viewModel.outputs.tableViewItemObservable
            .bind(to: calendarTableView.rx.items(dataSource: calendarTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.tableViewItemObservable
            .subscribe(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.headerDataArray = data
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

        viewModel.outputs.isAnimatedIndicator
            .drive(onNext: animateActivityIndicatorView(isAnimated:))
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: presentInputVC(event:))
            .disposed(by: disposeBag)
    }

    private func setupCollectionViewNSLayoutConstraint(secondSectionItemData: [CalendarItem]) {
        let numberOfWeeksInMonth: CGFloat = ceil(CGFloat(secondSectionItemData.count / 7))
        collectionViewNSLayoutConstraint?.isActive = false
        collectionViewNSLayoutConstraint =
        calendarCollectionView.heightAnchor.constraint(
            equalToConstant:
                weekdayCellHeight
            + dayCellHeight * numberOfWeeksInMonth
            + spaceOfCell * (numberOfWeeksInMonth - 1)
            + insetForSection.bottom * 2
            + insetForSection.top * 2
        )
        collectionViewNSLayoutConstraint?.isActive = true
    }

    private func animateActivityIndicatorView(isAnimated: Bool) {
        if isAnimated {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    // InputViewControllerへ画面遷移
    private func presentInputVC(event: CalendarViewModel.Event) {
        let viewModel: InputViewModel
        switch event {
        case .presentAdd(let date):
            viewModel = InputViewModel(mode: .add(date))
        case .presentEdit(let kakeiboData):
            viewModel = InputViewModel(mode: .edit(kakeiboData))
        default:
            return
        }
        let inputViewController = InputViewController(viewModel: viewModel)
        let navigationController =
        UINavigationController(rootViewController: inputViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
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

    // MARK: - viewDidLayoutSubviews()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicatorView.center = view.center
    }

    // MARK: - @objc(BarButtonItem)
    @objc private func didTapInputBarButton() {
        viewModel.inputs.didTapInputBarButton(didHighlightItem: didHighlightItemIndexPath)
    }

    // MARK: - @objc(SwipeGestureRecognizer)
    @objc private func collectionViewSwipeGesture(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            viewModel.inputs.didActionLastMonth()
        case UISwipeGestureRecognizer.Direction.left:
            viewModel.inputs.didActionNextMonth()
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

        let totalItemWidth: CGFloat =
        collectionView.bounds.width
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
        headerView.tintColor = .systemGray.withAlphaComponent(0.1)
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(indexPath: indexPath)
    }

    // MARK: - CalendarTableViewDataSourceDelegate
    // 自作delegate
    func didDeleteCell(index: IndexPath) {
        viewModel.inputs.didDeleateCell(indexPath: index)
    }
}
