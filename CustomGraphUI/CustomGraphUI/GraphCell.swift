//
//  GraphCell.swift
//  CustomGraphUI
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit

protocol GraphCellDelegate: AnyObject {

    func didSelected(_ cell: GraphCell)
}

final class GraphCell: UICollectionViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    private let selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    private lazy var prevLineLayer: CAShapeLayer = { getLineLayer() }()
    private lazy var nextLineLayer: CAShapeLayer = { getLineLayer() }()
    private lazy var animationLayer1: CAShapeLayer = { getAnimationLayer() }()
    private lazy var animationLayer2: CAShapeLayer = { getAnimationLayer() }()
    private lazy var centerYConstraint = selectionView.centerYAnchor.constraint(equalTo: contentView.topAnchor)
    weak var delegate: GraphCellDelegate?
    
    override var isSelected: Bool {
        didSet { animate(isAnimate: isSelected) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.layer.addSublayer(animationLayer1)
        contentView.layer.addSublayer(animationLayer2)
        contentView.layer.addSublayer(prevLineLayer)
        contentView.layer.addSublayer(nextLineLayer)

        contentView.addSubview(selectionView)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerYConstraint,
            selectionView.widthAnchor.constraint(equalToConstant: 10),
            selectionView.heightAnchor.constraint(equalToConstant: 10),
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.bottomAnchor.constraint(equalTo: selectionView.topAnchor, constant: -10).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor).isActive = true

        contentView.transform = CGAffineTransform(rotationAngle: .pi)
    }

    private func getLineLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.withAlphaComponent(0.2).cgColor
        layer.lineWidth = 3
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }

    private func getAnimationLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.red.withAlphaComponent(0.5).cgColor
        layer.isHidden = true
        return layer
    }

    private func animate(isAnimate: Bool) {
        DispatchQueue.main.async {
            self.animationLayer1.isHidden = !self.isSelected
            self.animationLayer2.isHidden = !self.isSelected

            if isAnimate {
                for (index, layer) in [self.animationLayer1, self.animationLayer2].enumerated() {
                    layer.frame = CGRect(
                        x: self.selectionView.center.x - 5,
                        y: self.selectionView.center.y - 5,
                        width: 10,
                        height: 10
                    )
                    layer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: .init(width: 10, height: 10)), cornerRadius: 5).cgPath
                    layer.removeAllAnimations()

                    let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
                    animation.toValue = 7
                    animation.duration = 2
                    animation.beginTime = CACurrentMediaTime() + Double(index)
                    animation.isRemovedOnCompletion = true
                    animation.repeatCount = Float.greatestFiniteMagnitude
                    layer.add(animation, forKey: "scaleAnimation")

                    let alphaAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                    alphaAnimation.toValue = 0
                    alphaAnimation.duration = 2
                    alphaAnimation.beginTime = CACurrentMediaTime() + Double(index)
                    alphaAnimation.isRemovedOnCompletion = true
                    alphaAnimation.repeatCount = Float.greatestFiniteMagnitude
                    layer.add(alphaAnimation, forKey: "opacityAnimation")
                }
            } else {
                self.animationLayer1.removeAllAnimations()
                self.animationLayer2.removeAllAnimations()
            }
        }
    }
    
    @objc private func setSelected() {
        delegate?.didSelected(self)
    }
    
    func setGraphValue(_ prev: CGFloat?, _ current: CGFloat, _ next: CGFloat?) {
        layoutIfNeeded()
        setLine(layer: prevLineLayer, currentValue: current, targetValue: prev)
        setLine(layer: nextLineLayer, currentValue: current, targetValue: next)
        centerYConstraint.constant = (1 - current) * frame.height
        textLabel.text = "\(Int(current * 100))"
    }

    private func setLine(layer: CAShapeLayer, currentValue: CGFloat, targetValue: CGFloat?) {
        layer.isHidden = targetValue == nil

        guard let targetValue = targetValue else { return }

        let centerX: CGFloat = frame.width / 2
        let centerY: CGFloat = (1 - currentValue) * frame.height
        let targetX: CGFloat = layer == prevLineLayer ? frame.width + frame.width / 2 : 0 - frame.width / 2
        let targetY: CGFloat = (1 - targetValue) * frame.height
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: centerX, y: centerY))
        linePath.addLine(to: CGPoint(x: targetX, y: targetY))
        layer.path = linePath.cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animationLayer1.isHidden = true
        animationLayer2.isHidden = true
    }
}
