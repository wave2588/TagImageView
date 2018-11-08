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

protocol TagViewInputs {
    
    /// tag 信息
    var createTag: PublishSubject<TagInfo> { get }
}

class TagView: UIView {
    
    var input: TagViewInputs { return self }
    let createTag = PublishSubject<TagInfo>()

    private var tagInfo: TagInfo?
    
    /// 白点
    private var pointCenterView = UIView()
    /// 白点阴影
    private var pointShadowView = UIView()
    /// 内容视图, 包括白线
    private var contentView = UIView()

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
    
    func createTag(tagInfo: TagInfo) {
        
        self.tagInfo = tagInfo
        
        guard let superViewW = superview?.width,
              let superViewH = superview?.height else {
                return
        }
        
        let pointViewCenterPoint = CGPoint(
            x: tagInfo.centerPointRatio.x * superViewW,
            y: tagInfo.centerPointRatio.y * superViewH
        )
        
        /// 先初始化自己的位置
        height = 22
        width = 14
        center = pointViewCenterPoint
        
        let titleCenterPoint = CGPoint(
            x: tagInfo.titleCenterPointRatio.x * superViewW,
            y: tagInfo.titleCenterPointRatio.y * superViewH
        )
        
        let pointView = UIView()
        pointView.backgroundColor = .yellow
        pointView.size = frame.size
        pointView.frame.origin = CGPoint(x: 0, y: 0)
        addSubview(pointView)

        let lineView = UIView()
        lineView.backgroundColor = .black
        lineView.top = (height - 1) * 0.5
        lineView.width = 25
        lineView.height = 1
        addSubview(lineView)

        let contentView = UIView()
        contentView.backgroundColor = .blue
        contentView.top = 0
        contentView.height = 22
        addSubview(contentView)
        
        if tagInfo.direction == .right {
            
            lineView.left = width - 4
            
            let contentViewLeft = left + pointView.width + 21
            let contentViewW = (titleCenterPoint.x - contentViewLeft) * 2
            contentView.left = lineView.right
            contentView.width = contentViewW
            
            UIView.animate(withDuration: 0.7) {
                /// 设置自己的宽度
                self.width = pointView.width + 21 + contentViewW
            }
        } else {
            
            let rightSpace = superViewW - right
            let contentViewRight = superViewW - pointView.width - 21 - rightSpace
            let contentViewW = (contentViewRight - titleCenterPoint.x) * 2
            self.left = self.left - 21 - contentViewW

            /// 设置自己的宽度
            width = pointView.width + 21 + contentViewW

            /// 重新设置 pointView 位置
            pointView.frame.origin = CGPoint(x: width - pointView.width, y: 0)
            
            /// 重新设置 lineView 位置
            lineView.right = pointView.left
            contentView.right = 0

            UIView.animate(withDuration: 0.7) {
                contentView.width = contentViewW
            }
        }
        
        let title = UILabel(text: tagInfo.title)
        title.font = UIFont(name: "PingFangSC-Medium", size: 12)
        title.frame = CGRect(x: 6, y: 0, width: contentView.width - 12, height: contentView.height)
        contentView.addSubview(title)

        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bind { [unowned self] _ in
            debugPrint(1111)
            self.superview?.bringSubviewToFront(self)
        }.disposed(by: rx.disposeBag)
        addGestureRecognizer(tapGesture)
    }
}

private extension TagView {
    
    func configureTagInfo() {
        
        backgroundColor = .red
        clipsToBounds = true
        
        createTag
            .subscribe { [unowned self] event in
                guard let info = event.element else { return }
                self.createTag(tagInfo: info)
            }
            .disposed(by: rx.disposeBag)
    }
    
//    /// 添加没有位置的点
//    func configurePointView(tagInfo: TagInfo) {
//        /// 小黑点
//        pointShadowView.size = CGSize(width: 14, height: 14)
//        pointShadowView.cornerRadius = 7
//        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        addSubview(pointShadowView)
//
//        /// 小白点
//        pointCenterView.size = CGSize(width: 6, height: 6)
//        pointCenterView.cornerRadius = 3
//        pointCenterView.backgroundColor = .white
//        pointCenterView.shadowOffset = CGSize(width: 0, height: 1)
//        pointCenterView.shadowColor = .black
//        pointCenterView.shadowRadius = 1.5
//        pointCenterView.shadowOpacity = 0.5
//        addSubview(pointCenterView)
//
//        if tagInfo.direction == .right {
//            pointShadowView.frame.origin = CGPoint(x: 0, y: (height - pointShadowView.height) * 0.5)
//        } else {
//            pointShadowView.frame.origin = CGPoint(x: width - pointShadowView.width, y: (height - pointShadowView.height) * 0.5)
//        }
//        pointCenterView.center = pointShadowView.center
//    }
//
//    func configureContentView(tagInfo: TagInfo) {
//        let pointSpace: CGFloat = 4
//
//        contentView.backgroundColor = .blue
//        addSubview(contentView)
//
//        contentView.height = tagInfo.contentSize.height
//        contentView.top = 0
//
//        if tagInfo.direction == .right {
//            contentView.left = pointCenterView.right
//            UIView.animate(withDuration: 0.7) {
//                self.contentView.width = tagInfo.contentSize.width - pointSpace
//            }
//        } else {
//            UIView.animate(withDuration: 0.7) {
//                self.contentView.left = 0
//                self.contentView.width = tagInfo.contentSize.width
//            }
//        }
//
//    }
    
}



















//enum TagDirection {
//    case left
//    case right
//}
//
//protocol TagViewInputs {
//
//    /// tag 信息
//    var tagInfo: PublishSubject<TagInfo> { get }
//}
//
//class TagView: UIView {
//
//    var input: TagViewInputs { return self }
//    let tagInfo = PublishSubject<TagInfo>()
//
//    /// 白点
//    private var pointCenterView = UIView()
//    /// 白点阴影
//    private var pointShadowView = UIView()
//
//    private var tagViewW: CGFloat = 0
//    
//    private var contentView = TagContentView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        configureTagInfo()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension TagView: TagViewInputs {}
//
//private extension TagView {
//
//    func changeLocationOrigin(gesture: UIPanGestureRecognizer) {
//        self.origin = gesture.location(in: self.superview)
//        
//    }
//    
//    func update(direction: TagDirection, info: TagInfo) {
//        
//        width = tagViewW
//
//        contentView.top = 0
//        contentView.height = 22
//
//        contentView.updateContentView(direction: direction, info: info)
//        
//        if direction == .left {
//            left = left - tagViewW
//            pointShadowView.right = tagViewW
//            pointCenterView.center = pointShadowView.center
//
//            contentView.right = pointCenterView.left
//
//            UIView.animate(withDuration: 0.7) {
//                self.contentView.left = 4
//                self.contentView.width = self.tagViewW - self.pointShadowView.width
//            }
//        } else {
//            contentView.left = pointShadowView.right - 4
//            UIView.animate(withDuration: 0.7) {
//                self.contentView.width = self.tagViewW - self.pointShadowView.width
//            }
//        }
//        /// 4 是 想让小白点和白线链接起来        pointShadowView.right - 4   self.contentView.left = 4
//    }
//}
//
//private extension TagView {
//    
//    func configureTagInfo() {
//        
//        tagInfo
//            .subscribe(onNext: { [unowned self] info in
//                self.configureTagView(info: info)
//            })
//            .disposed(by: rx.disposeBag)
//    }
//    
//    func configureGesture() {
//        
//    }
//    
//    func configureTagView(info: TagInfo) {
//
//        clipsToBounds = true
//        
//        /// 小黑点
//        pointShadowView.frame = CGRect(x: 0, y: (height - 14) * 0.5, width: 14, height: 14)
//        pointShadowView.cornerRadius = 7
//        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        addSubview(pointShadowView)
//
//        /// 小白点
//        pointCenterView.size = CGSize(width: 6, height: 6)
//        pointCenterView.center = pointShadowView.center
//        pointCenterView.cornerRadius = 3
//        pointCenterView.backgroundColor = UIColor.white
//        pointCenterView.shadowOffset = CGSize(width: 0, height: 1)
//        pointCenterView.shadowColor = UIColor.black
//        pointCenterView.shadowRadius = 1.5
//        pointCenterView.shadowOpacity = 0.5
//        addSubview(pointCenterView)
//
//        let titleLbl = UILabel()
//        titleLbl.text = info.title
//        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
//        titleLbl.sizeToFit()
//        
//        let contentViewW = 25 + titleLbl.width + 12               /// 25 是白线的宽度  12是白线和文字的间距 + 文字最后的间距
//        tagViewW = pointShadowView.width + contentViewW
//        
//        guard let superViewW = superview?.width,
//              let _ = superview?.height else {
//                return
//        }
//        
//        addSubview(contentView)
//
//        if left + tagViewW > superViewW {
//            update(direction: .left, info: info)
//        } else {
//            update(direction: .right, info: info)
//        }
//    }
//}
//
//
//
//
//
//private extension TagView {
//    
//    func addAnimation() {
//        let cka = CAKeyframeAnimation(keyPath: "transform.scale")
//        //        cka.values = [0.7, 0.9, 0.9, 3.5, 0.9, 3.5]
//        cka.values = [0.3, 0.5, 0.5, 1.0, 0.5, 0.5, 0.3]
//        cka.keyTimes = [0.0, 0.3, 0.3, 0.65, 0.65, 1, 1]
//        cka.repeatCount = MAXFLOAT
//        cka.duration = 1.5
//        pointShadowView.layer.add(cka, forKey: "cka")
//    }
//    
//    func removeAnimation() {
//        //        pointShadowView.removeAnimation(forKey: "cka")
//    }
//}

