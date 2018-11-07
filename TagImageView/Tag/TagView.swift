//
//  TagView.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

protocol TagViewInputs {
    
    var tagInfo: PublishSubject<TagInfo> { get }
}

class TagView: UIView {

    var input: TagViewInputs { return self }
    let tagInfo = PublishSubject<TagInfo>()
    
    /// 白点
    private var pointLayer = CAShapeLayer()
    /// 白点阴影动画
    private var pointShadowLayer = CAShapeLayer()
    /// 白线
    private var lineLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayer()
        configureTagView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagView: TagViewInputs {}

private extension TagView {
    
    func addAnimation() {
        let cka = CAKeyframeAnimation(keyPath: "transform.scale")
//        cka.values = [0.7, 0.9, 0.9, 3.5, 0.9, 3.5]
        cka.values = [0.3, 0.5, 0.5, 1.0, 0.5, 0.5, 0.3]
//        cka.keyTimes = [0.0, 0.3, 0.3, 0.65, 0.65, 1]
        cka.repeatCount = MAXFLOAT
        cka.duration = 1.5
        pointShadowLayer.add(cka, forKey: "cka")
    }
    
    func removeAnimation() {
        pointShadowLayer.removeAnimation(forKey: "cka")
    }
}

private extension TagView {
    
    func configureTagView() {
        
        backgroundColor = .clear
        
        tagInfo
            .subscribe(onNext: { [unowned self] info in
                debugPrint(info)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureLayer() {
        
        pointShadowLayer.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
        pointShadowLayer.cornerRadius = 7
        pointShadowLayer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.addSublayer(pointShadowLayer)

        pointLayer.frame = CGRect(x: 4, y: 4, width: 6, height: 6)
        pointLayer.cornerRadius = 3
        pointLayer.backgroundColor = UIColor.white.cgColor
        pointLayer.shadowOffset = CGSize(width: 0, height: 1)
        pointLayer.shadowColor = UIColor.black.cgColor
        pointLayer.shadowRadius = 1.5
        pointLayer.shadowOpacity = 0.5
        layer.addSublayer(pointLayer)
        
        addAnimation()
    }
}
