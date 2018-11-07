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
import SwifterSwift

protocol TagViewInputs {
    
    var tagInfo: PublishSubject<TagInfo> { get }
}

class TagView: UIView {

    var input: TagViewInputs { return self }
    let tagInfo = PublishSubject<TagInfo>()
    
    /// 白点
    private var pointView = UIView()
    /// 白点阴影
    private var pointShadowView = UIView()
    
    /// 内容部分
    private var containerView = UIView()
    private var lineView = UIView()
    private var titleLbl = UILabel()
    private var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTagInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight], cornerRadii: CGSize(width: 11, height: 11))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = visualEffectView.bounds
        maskLayer.path = maskPath.cgPath
        visualEffectView.layer.mask = maskLayer
    }
}

extension TagView: TagViewInputs {}

private extension TagView {
    
    func configureTagInfo() {
        
        tagInfo
            .subscribe(onNext: { [unowned self] info in
                self.configureTagView(info: info)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureTagView(info: TagInfo) {
        
        debugPrint(info)
        
        clipsToBounds = true
        
        /// 小黑点
        pointShadowView.frame = CGRect(x: 0, y: (height - 14) * 0.5, width: 14, height: 14)
        pointShadowView.cornerRadius = 7
        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addSubview(pointShadowView)

        /// 小白点
        pointView.frame = CGRect(x: 4, y: (height - 6) * 0.5, width: 6, height: 6)
        pointView.cornerRadius = 3
        pointView.backgroundColor = UIColor.white
        pointView.shadowOffset = CGSize(width: 0, height: 1)
        pointView.shadowColor = UIColor.black
        pointView.shadowRadius = 1.5
        pointView.shadowOpacity = 0.5
        addSubview(pointView)
        
        /// 容器 view
        containerView.isHidden = true
        containerView.left = pointView.right
        containerView.top = 0
        containerView.height = height
        containerView.width = 10
        addSubview(containerView)
        
        /// 横线
        lineView.frame = CGRect(x: 0, y: containerView.height * 0.5, width: 25, height: 1)
        lineView.backgroundColor = UIColor.white
        containerView.addSubview(lineView)
        
        /// 文字背景阴影
        visualEffectView.left = lineView.right
        visualEffectView.top = 0
        visualEffectView.height = 22
        containerView.addSubview(visualEffectView)
        
        /// 文字
        titleLbl.text = info.title
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        titleLbl.textColor = .white
        titleLbl.sizeToFit()
        titleLbl.left = lineView.right + 6
        titleLbl.centerY = lineView.centerY
        containerView.addSubview(titleLbl)

        visualEffectView.width = titleLbl.width + 12
        
        containerView.isHidden = false
        UIView.animate(withDuration: 0.7, animations: {
            self.containerView.width = 25 + self.visualEffectView.width
            self.width = self.pointShadowView.width + self.containerView.width
        }) { _ in
            debugPrint(self.containerView)
        }

        /// 在这里要计算是向右还是向左
        
        
    }
}





private extension TagView {
    
    func addAnimation() {
        let cka = CAKeyframeAnimation(keyPath: "transform.scale")
        //        cka.values = [0.7, 0.9, 0.9, 3.5, 0.9, 3.5]
        cka.values = [0.3, 0.5, 0.5, 1.0, 0.5, 0.5, 0.3]
        cka.keyTimes = [0.0, 0.3, 0.3, 0.65, 0.65, 1, 1]
        cka.repeatCount = MAXFLOAT
        cka.duration = 1.5
        pointShadowView.layer.add(cka, forKey: "cka")
    }
    
    func removeAnimation() {
        //        pointShadowView.removeAnimation(forKey: "cka")
    }
    
}

