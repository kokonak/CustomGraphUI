//
//  ViewController.swift
//  CustomGraphUI
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

private let cellIdentifier: String = "graphCellIdentifier"
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GraphCellDelegate {
    
    private let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let itemWidth: CGFloat = 80
    private let itemHeight: CGFloat = 300

    private var itemList: [(value: CGFloat, text: String)] = [
        (0.5, "50%"), (0.2, "20%"), (0.7, "70%"), (0.25, "25%"), (0.85, "85%"),
        (1, "100%"), (0.2, "20%"), (0.7, "70%"), (0, "0%"), (0.85, "85%"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        self.initElements()
        self.reloadData()
    }
    
    private func initElements() {
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: self.itemWidth, height: self.itemHeight)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets.zero
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(GraphCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.collectionView)
        
        self.collectionView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let frame = self.view.frame
        self.collectionView.frame = CGRect(x: 0, y: 100, width: frame.width, height: self.itemHeight)
    }
    
    private func reloadData() {
        let itemsWidth: CGFloat = self.itemWidth * CGFloat(self.itemList.count)
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let inset: CGFloat = self.view.frame.width - itemsWidth
        if inset > 0 {
            // for cell center alignment
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset/2, bottom: 0, right: inset/2)
        }
        else {
            flowLayout.sectionInset = UIEdgeInsets.zero
        }
        self.collectionView.reloadData()
    }
    
    private func loadMore() {
        if self.itemList.count >= 15 {
            return
        }

        var indexPaths: [IndexPath] = []
        for _ in 0..<5 {
            let value: Int = Int(arc4random_uniform(100))
            indexPaths.append(IndexPath(row: self.itemList.count, section: 0))
            self.itemList.append((value: CGFloat(value) * 0.01, text: "\(value)%"))
        }
        self.collectionView.insertItems(at: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GraphCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GraphCell
        cell.delegate = self
        
        if indexPath.row == self.itemList.count - 1 {
            self.loadMore()
        }
        
        let item = self.itemList[indexPath.row]
        let prevValue: CGFloat? = self.itemList[item: indexPath.row - 1] == nil ? nil : self.itemList[indexPath.row - 1].value
        let nextValue: CGFloat? = self.itemList[item: indexPath.row + 1] == nil ? nil : self.itemList[indexPath.row + 1].value

        cell.setGraphValue(prevValue, item.value, nextValue, item.text)

        return cell
    }
    
    func didSelected(_ cell: GraphCell) {
        for visibleCell in self.collectionView.visibleCells {
            visibleCell.isSelected = false
        }
        cell.isSelected = true
        if let indexPath: IndexPath = self.collectionView.indexPath(for: cell) {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }
}
