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
                              UICollectionViewDelegateFlowLayout,
                              UITableViewDelegate,
                              CalendarTableViewDataSourceDelegate {

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
    private var tableViewHeaderData: [TableViewHeaderData] = []
    private var collectionViewNSLayoutConstraint: NSLayoutConstraint?

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
        setupCollectionView() // collectionViewの設定をするメソッド
        setupTableView() // tableViewの設定をするメソッド
    }

    private func setupBarButtonItem() {
        let nextBarButton =
            UIBarButtonItem(
                image:UIImage(systemName: "chevron.right"),
                style: .plain,
                target: self,
                action: #selector(didTapNextBarButton)
            )
        navigationItem.rightBarButtonItem = nextBarButton

        let lastBarButton =
            UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(didTapLastBarButton)
            )
        navigationItem.leftBarButtonItem = lastBarButton
    }

    private func setupBinding() {
        let collectionViewDataObservable = viewModel.outputs.collectionViewDataObservable
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
                    )
                self.collectionViewNSLayoutConstraint?.isActive = true
            })
            .disposed(by: disposeBag)

        viewModel.outputs.tableViewCellDataObservable
            .bind(to: calendarTableView.rx.items(dataSource: calendarTableViewDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.tableViewHeaderObservable
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.tableViewHeaderData = data
            })
            .disposed(by: disposeBag)

        viewModel.outputs.navigationTitle
            .drive(navigationItem.rx.title)
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
        calendarCollectionView.backgroundColor = UIColor(named: CalendarColorName.AtomicTangerine.rawValue)
    }

    // tableViewの設定
    private func setupTableView() {
        calendarTableView.register(
            CalendarTableViewCell.nib,
            forCellReuseIdentifier: CalendarTableViewCell.identifier
        )
        calendarTableView.rowHeight = 40 // TableViewのCellの高さを指定
        calendarTableView.register(
            CalendarTableViewHeaderFooterView.nib,
            forHeaderFooterViewReuseIdentifier: CalendarTableViewHeaderFooterView.identifier
        )
        calendarTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

    // MARK: - @objc(BarButtonItem)
    @objc private func didTapNextBarButton() {
        viewModel.inputs.didTapNextBarButton()
    }

    @objc private func didTapLastBarButton() {
        viewModel.inputs.didTapLastBarButton()
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    private let spaceOfCell: CGFloat = 1 // セルの間隔
    private let weekdayCellHeight: CGFloat = 20 // 週のセルの高さ
    private let dayCellHeight: CGFloat = 50 // 日付のセルの高さ
    private let numberOfDaysInWeek: CGFloat = 7 // 1週間の日数
    private let insetForSection = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
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
        let width: CGFloat = floor(totalItemWidth / numberOfDaysInWeek)

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
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let headerView = tableView.dequeueReusableHeaderFooterView(
//                withIdentifier: CalendarTableViewHeaderFooterView.identifier)
//                as? CalendarTableViewHeaderFooterView else { return nil }
//        headerView.configure(data: tableViewHeaderData[section])
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let navigationController = tabBarController?.viewControllers?[1]
//            as! UINavigationController // swiftlint:disable:this force_cast
//        let inputViewController = navigationController.topViewController
//            as! InputViewController // swiftlint:disable:this force_cast
//
//        inputViewController.mode = .edit
//        inputViewController.editingIndexpath = indexPath
//        inputViewController.editingFirstDay = calendarDate.firstDay
//        tabBarController?.selectedViewController = navigationController // 画面遷移
//    }

    // MARK: - CalendarTableViewDataSourceDelegate
    // 自作delegate
    func didDeleteCell(indexRow: Int) {
    }
}
