//
//  ViewController.swift
//  CustomGraphUI
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    private let cellIdentifier: String = "graphCellIdentifier"
    private let itemSize: CGSize = CGSize(width: 80, height: 200)

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets.zero
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(GraphCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.transform = CGAffineTransform(rotationAngle: .pi)
        return collectionView
    }()

    private var items: [CGFloat] = [0.5, 0.2, 0.7, 0.25, 0.85, 1, 0.7, 0.2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupUI()
        reloadData()
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 300).isActive = true

        view.layoutIfNeeded()
    }
    
    private func reloadData() {
        let itemsWidth: CGFloat = itemSize.width * CGFloat(items.count)
        let remainWidth: CGFloat = collectionView.frame.width - itemsWidth

        let sectionInset: UIEdgeInsets
        if remainWidth > 0 {
            sectionInset = UIEdgeInsets(top: 0, left: remainWidth/2, bottom: 0, right: remainWidth/2)
        } else {
            sectionInset = .zero
        }
        flowLayout.sectionInset = sectionInset
        collectionView.reloadData()
    }
    
    private func loadMore() {
        guard items.count < 15 else { return }

        let newItems: [CGFloat] = (0..<5).map { _ in CGFloat(arc4random_uniform(100))/100 }
        let indexPaths: [IndexPath] = (items.count..<items.count + newItems.count).map { IndexPath(row: $0, section: 0) }
        items += newItems
        collectionView.insertItems(at: indexPaths)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeueCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        guard let cell = dequeueCell as? GraphCell,
              let item = items[safe: indexPath.row]
        else {
            return GraphCell()
        }

        let prevValue: CGFloat? = items[safe: indexPath.row - 1]
        let nextValue: CGFloat? = items[safe: indexPath.row + 1]
        cell.delegate = self
        cell.setGraphValue(prevValue, item, nextValue)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        flowLayout.itemSize
    }
}

// MARK: - GraphCellDelegate
extension ViewController: GraphCellDelegate {

    func didSelected(_ cell: GraphCell) {
        for visibleCell in collectionView.visibleCells {
            visibleCell.isSelected = false
        }
        cell.isSelected = true
        if let indexPath: IndexPath = collectionView.indexPath(for: cell) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }
}
