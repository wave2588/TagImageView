//
//  TagView.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SwifterSwift

enum TagDirection {
    case left
    case right
}

protocol TagViewInputs {
    
    /// tag 信息
    var tagInfo: PublishSubject<TagInfo> { get }
}

class TagView: UIView {

    var input: TagViewInputs { return self }
    let tagInfo = PublishSubject<TagInfo>()
    
    /// 白点
    private var pointCenterView = UIView()
    /// 白点阴影
    private var pointShadowView = UIView()
    
    private var tagViewW: CGFloat = 0
    
    private var contentView = TagContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureTagInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagView: TagViewInputs {}

private extension TagView {

    func changeLocationOrigin(gesture: UIPanGestureRecognizer) {
        self.origin = gesture.location(in: self.superview)
        
    }
    
    func update(direction: TagDirection, info: TagInfo) {
        
        width = tagViewW

        contentView.top = 0
        contentView.height = 22

        contentView.updateContentView(direction: direction, info: info)
        
        if direction == .left {
            left = left - tagViewW
            pointShadowView.right = tagViewW
            pointCenterView.center = pointShadowView.center

            contentView.right = pointCenterView.left

            UIView.animate(withDuration: 0.7) {
                self.contentView.left = 4
                self.contentView.width = self.tagViewW - self.pointShadowView.width
            }
        } else {
            contentView.left = pointShadowView.right - 4
            UIView.animate(withDuration: 0.7) {
                self.contentView.width = self.tagViewW - self.pointShadowView.width
            }
        }
        /// 4 是 想让小白点和白线链接起来        pointShadowView.right - 4   self.contentView.left = 4
    }
}

private extension TagView {
    
    func configureTagInfo() {
        
        tagInfo
            .subscribe(onNext: { [unowned self] info in
                self.configureTagView(info: info)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func configureTagView(info: TagInfo) {

        clipsToBounds = true
        
        /// 小黑点
        pointShadowView.frame = CGRect(x: 0, y: (height - 14) * 0.5, width: 14, height: 14)
        pointShadowView.cornerRadius = 7
        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addSubview(pointShadowView)

        /// 小白点
        pointCenterView.size = CGSize(width: 6, height: 6)
        pointCenterView.center = pointShadowView.center
        pointCenterView.cornerRadius = 3
        pointCenterView.backgroundColor = UIColor.white
        pointCenterView.shadowOffset = CGSize(width: 0, height: 1)
        pointCenterView.shadowColor = UIColor.black
        pointCenterView.shadowRadius = 1.5
        pointCenterView.shadowOpacity = 0.5
        addSubview(pointCenterView)

        let titleLbl = UILabel()
        titleLbl.text = info.title
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        titleLbl.sizeToFit()
        
        let contentViewW = 25 + titleLbl.width + 12               /// 25 是白线的宽度  12是白线和文字的间距 + 文字最后的间距
        tagViewW = pointShadowView.width + contentViewW
        
        guard let superViewW = superview?.width,
              let _ = superview?.height else {
                return
        }
        
        addSubview(contentView)

        if left + tagViewW > superViewW {
            update(direction: .left, info: info)
        } else {
            update(direction: .right, info: info)
        }
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

