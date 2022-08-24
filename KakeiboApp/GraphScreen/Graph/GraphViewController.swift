//
//  GraphViewController.swift
//  KakeiboApp
//
//  Created by 今村京平 on 2021/07/02.
//

import UIKit
import RxSwift
import RxCocoa

final class GraphViewController: UIViewController {
    @IBOutlet private weak var dateTitleLabel: UILabel!
    @IBOutlet private weak var nextMonthButton: UIButton!
    @IBOutlet private weak var lastMonthButton: UIButton!
    @IBOutlet private weak var graphCardCollectionView: UICollectionView!
    @IBOutlet private weak var graphTableView: UITableView!
    @IBOutlet private weak var termButton: UIBarButtonItem!

    private let viewModel: GraphViewModelType = GraphViewModel()
    private let disposeBag = DisposeBag()
    private var graphDataArray: [GraphData] = []
    private var selectedCardIndexPath = IndexPath(row: 120, section: 0)
    private var selectedSegmentIndex: Int = 0
    private var cardCount = 240

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupGraphTableView()
        setupGraphCardCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.onViewDidAppear()
    }

    private func setupBinding() {
        nextMonthButton.rx.tap
            .subscribe(onNext: showNextMonth)
            .disposed(by: disposeBag)

        lastMonthButton.rx.tap
            .subscribe(onNext: showLastMonth)
            .disposed(by: disposeBag)

        viewModel.outputs.dateTitle
            .drive(dateTitleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.leftBarButtonTitle
            .drive(termButton.rx.title)
            .disposed(by: disposeBag)

        termButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapTermButton)
            .disposed(by: disposeBag)

        viewModel.outputs.graphData
            .skip(1) // 初期値をスキップ
            .subscribe(
                onNext: { [weak self] graphData in
                    guard let self = self else { return }
                    self.graphDataArray = graphData.0
                    self.selectedSegmentIndex = graphData.SegmentIndex
                    self.graphTableView.reloadData()
                    self.graphCardCollectionView.reloadData()
                    self.scrollCurrentCard(animated: graphData.animated)
                    self.setBarButtonItem()
                }
            )
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .presentCategoryVC(let categoryData, let displayDate):
                    let categoryViewController = CategoryViewController(
                        viewModel: CategoryViewModel(categoryData: categoryData, displayDate: displayDate)
                    )
                    categoryViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(categoryViewController, animated: true)
                case .setTerm(selectedCardIndexPath: let selectedCardIndexPath,
                              selectedSegmentIndex: let selectedSegmentIndex,
                              cardCount: let cardCount):
                    self.selectedCardIndexPath = selectedCardIndexPath
                    self.selectedSegmentIndex = selectedSegmentIndex
                    self.cardCount = cardCount
                }
            })
            .disposed(by: disposeBag)
    }

    private func setupGraphTableView() {
        graphTableView.register(
            GraphTableViewCell.nib,
            forCellReuseIdentifier: GraphTableViewCell.identifier
        )
        graphTableView.dataSource = self
        graphTableView.delegate = self
    }

    private func setupGraphCardCollectionView() {
        graphCardCollectionView.register(
            GraphCardCollectionViewCell.nib,
            forCellWithReuseIdentifier: GraphCardCollectionViewCell.identifier
        )
        graphCardCollectionView.dataSource = self
        graphCardCollectionView.delegate = self
        let layout = CardCollectionViewFlowLayout()
        layout.delegate = self
        graphCardCollectionView.collectionViewLayout = layout
        graphCardCollectionView.decelerationRate = .fast
    }

    private func showNextMonth() {
        selectedCardIndexPath.formIndex(&selectedCardIndexPath.row, offsetBy: 1)
        viewModel.inputs.didActionNextMonth()
    }

    private func showLastMonth() {
        selectedCardIndexPath.formIndex(&selectedCardIndexPath.row, offsetBy: -1)
        viewModel.inputs.didActionLastMonth()
    }

    private func setBarButtonItem() {
        if selectedCardIndexPath.row == cardCount - 1 {
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

    private func scrollCurrentCard(animated: Bool) {
        graphCardCollectionView.scrollToItem(
            at: self.selectedCardIndexPath,
            at: .centeredHorizontally,
            animated: animated
        )
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GraphViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cardWidth: CGFloat = collectionView.frame.width - 52
        return CGSize(width: cardWidth, height: 270)
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
extension GraphViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GraphCardCollectionViewCell.identifier,
            for: indexPath
        ) as? GraphCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        if indexPath == selectedCardIndexPath {
            cell.configure(data: graphDataArray, segmentIndex: selectedSegmentIndex)
        } else {
            cell.hidePieChartView(segmentIndex: selectedSegmentIndex)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GraphViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(indexPath: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension GraphViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        graphDataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GraphTableViewCell.identifier,
            for: indexPath
        ) as? GraphTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(data: graphDataArray[indexPath.row])
        return cell
    }
}

// MARK: - CardCollectionViewFlowLayoutDelegate
extension GraphViewController: CardCollectionViewFlowLayoutDelegate {
    func didSwipeCard(displayCardIndexPath: IndexPath) {
        let distance = selectedCardIndexPath.distance(from: selectedCardIndexPath.row, to: displayCardIndexPath.row)
        if distance > 0 {
            showNextMonth()
        } else if distance < 0 {
            showLastMonth()
        }
    }
}

// MARK: - GraphCardCollectionViewCellDelegate
extension GraphViewController: GraphCardCollectionViewCellDelegate {
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        viewModel.inputs.didChangeSegmentIndex(index: selectedSegmentIndex)
    }
}
