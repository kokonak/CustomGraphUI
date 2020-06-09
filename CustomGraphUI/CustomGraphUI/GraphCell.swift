//
//  GraphCell.swift
//  CustomGraphUI
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

import UIKit


protocol GraphCellDelegate {
    func didSelected(_ cell: GraphCell)
}

class GraphCell: UICollectionViewCell {
    private let containerView: UIView = UIView()
    private let prevLineLayer: CAShapeLayer = CAShapeLayer()
    private let nextLineLayer: CAShapeLayer = CAShapeLayer()
    
    private let markLayer: CAShapeLayer = CAShapeLayer()
    private let selectButton: UIButton = UIButton()
    
    private let animationLayer1: CAShapeLayer = CAShapeLayer()
    private let animationLayer2: CAShapeLayer = CAShapeLayer()

    
    private let textLabel: UILabel = UILabel()
    
    private var prevValue: CGFloat? = nil
    private var nextValue: CGFloat? = nil
    private var currentValue: CGFloat = 0
    
    private let margin: CGFloat = 10
    private let markWidth: CGFloat = 10
    
    private let lineColor: UIColor = UIColor.red.withAlphaComponent(0.2)
    
    var delegate: GraphCellDelegate?
    
    override var isSelected: Bool {
        didSet {
            self.animationLayer1.isHidden = !isSelected
            self.animationLayer2.isHidden = !isSelected
            
            if isSelected {
                self.startSelectedAnimation()
            }
            else {
                self.stopAnimation()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initElements()
        
        self.selectButton.addTarget(self, action: #selector(selectButtonTouch(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initElements() {
        self.containerView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.containerView)
        
        // prevent isSelected state change when cell touched
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        self.contentView.addGestureRecognizer(tapGesture)
        
        for layer in [self.animationLayer1, self.animationLayer2] {
            layer.fillColor = UIColor.red.withAlphaComponent(0.5).cgColor
            layer.isHidden = true
            self.contentView.layer.addSublayer(layer)
        }
        for layer in [self.prevLineLayer, self.nextLineLayer] {
            layer.strokeColor = self.lineColor.cgColor
            layer.lineWidth = 1
            layer.fillColor = UIColor.clear.cgColor
            self.containerView.layer.addSublayer(layer)
        }
        
        self.markLayer.fillColor = UIColor.red.cgColor
        self.selectButton.layer.addSublayer(self.markLayer)
        self.contentView.addSubview(self.selectButton)
        
        self.textLabel.textColor = UIColor.red.withAlphaComponent(0.8)
        self.textLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        self.textLabel.textAlignment = .center
        self.contentView.addSubview(self.textLabel)
        
        self.contentView.transform = CGAffineTransform(rotationAngle: .pi)
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.frame = CGRect(x: 0, y: self.margin, width: self.frame.width, height: self.frame.height - self.margin * 2)
        
        self.prevLineLayer.frame = self.containerView.bounds
        self.setLineLayerPath(layer: self.prevLineLayer, isLeft: false, value: self.prevValue)
        
        self.nextLineLayer.frame = self.containerView.bounds
        self.setLineLayerPath(layer: self.nextLineLayer, isLeft: true, value: self.nextValue)
        
        for layer in [self.animationLayer1, self.animationLayer2] {
            layer.frame = CGRect(x: (self.containerView.frame.width - markWidth)/2, y: self.margin + self.currentValue - markWidth/2, width: markWidth, height: markWidth)
            layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.frame.height/2).cgPath
        }
        
        let selectionWidth: CGFloat = 50
        self.selectButton.frame = CGRect(x: (self.containerView.frame.width - selectionWidth)/2, y: self.margin + self.currentValue - selectionWidth/2, width: selectionWidth, height: selectionWidth)

        self.markLayer.frame = self.selectButton.bounds
        self.markLayer.path = UIBezierPath(roundedRect: CGRect(x: (selectionWidth - self.markWidth)/2, y: (selectionWidth - self.markWidth)/2, width: self.markWidth, height: self.markWidth), cornerRadius: self.markWidth/2).cgPath
        
        self.textLabel.frame = CGRect(x: 0, y: self.margin + self.currentValue - 13 - 12, width: self.frame.width, height: 13)
    }
    
    private func setLineLayerPath(layer: CAShapeLayer, isLeft: Bool, value: CGFloat?) {
        let rect: CGRect = UIScreen.main.bounds
        
        layer.frame = self.containerView.bounds
        let linePath: UIBezierPath = UIBezierPath()
        let endY: CGFloat = value ?? self.currentValue
        let endX: CGFloat = layer.frame.width/2 + (layer.frame.width + (value == nil ? rect.width : 0)) * (isLeft ? -1 : 1)
        linePath.move(to: CGPoint(x: layer.frame.width/2, y: self.currentValue))
        linePath.addLine(to: CGPoint(x: endX, y: endY))
        layer.lineDashPattern = value == nil ? [4, 4] : []
        layer.path = linePath.cgPath
    }

    private func startSelectedAnimation() {
        DispatchQueue.main.async {
            for (index, layer) in [self.animationLayer1, self.animationLayer2].enumerated() {
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
        }
    }
    
    private func stopAnimation() {
        DispatchQueue.main.async {
            self.animationLayer1.removeAllAnimations()
            self.animationLayer2.removeAllAnimations()
        }
    }
    
    @objc private func selectButtonTouch(_ sender: UIButton) {
        self.delegate?.didSelected(self)
    }
    
    func setGraphValue(_ prev: CGFloat?, _ current: CGFloat, _ next: CGFloat?, _ text: String) {
        self.prevValue = prev != nil ? ((1-prev!) * self.containerView.frame.height) : nil
        self.currentValue = (1-current) * self.containerView.frame.height
        self.nextValue = next != nil ? ((1-next!) * self.containerView.frame.height) : nil
        self.textLabel.text = text
        
        self.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.animationLayer1.isHidden = true
        self.animationLayer2.isHidden = true
    }
}
