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

/*
 TagView:
 传进来的 TagInfo, 在进行拖动, 改变方向等等操作, 在停止操作的时候, 通过 updateTagInfo 传递出去, 替换外面数组里的数据
 */

protocol TagViewInputs {
    
    var state: PublishSubject<State> { get }
    
    /// 添加 tag 信息
    var createTag: PublishSubject<TagInfo> { get }
    
    /// 删除 tag 信息 (操作图片删除)
    var removeTag: PublishSubject<TagInfo> { get }
}

protocol TagViewOutputs {
    
    /// 删除 (自己手动删除)
    var removeTagInfo: PublishSubject<TagInfo> { get }
    
    /// 更新
    var updateTagInfo: PublishSubject<TagInfo> { get }
    
    /// 点击 tag
    var clickTagView: PublishSubject<TagInfo> { get }
}

class TagView: UIView {
    
    var input: TagViewInputs { return self }
    let state = PublishSubject<State>()
    let createTag = PublishSubject<TagInfo>()
    let removeTag = PublishSubject<TagInfo>()

    var output: TagViewOutputs { return self }
    let removeTagInfo = PublishSubject<TagInfo>()
    let updateTagInfo = PublishSubject<TagInfo>()
    let clickTagView = PublishSubject<TagInfo>()

    
    private var tagInfo: TagInfo?
    
    /// 白点
    private var pointCenterView = UIView()
    /// 白点阴影
    private var pointShadowView = UIView()
    /// 内容视图, 包括白线
    private var contentView = TagContentView()
    
    /// 点击标签
    private let tapGesture = UITapGestureRecognizer()
    /// 点击小红点
    private let pointGesture = UITapGestureRecognizer()
    /// 拖动
    private let panGesture = UIPanGestureRecognizer()

    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureTagInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagView: TagViewInputs {}
extension TagView: TagViewOutputs {}

private extension TagView {
    
    func dragging(gesture: UIPanGestureRecognizer) {
        
        guard let superViewW = superview?.width,
            let superViewH = superview?.height else {
                return
        }

        if gesture.state == .began {
            
            self.superview?.bringSubviewToFront(self)
            
        } else if gesture.state == .changed {
            
            let point = gesture.location(in: superview)
            center = point
            
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            update()
        }
    }
    
    func changeDirection(tagInfo: TagInfo) {
        
        remove(tagInfo: tagInfo)
        removeTagInfo.onNext(tagInfo)
        
//        var upTagInfo = tagInfo
//        /// 改变方向... 相当于把 TagImageView 计算的过程重新来一遍....
//        if tagInfo.direction == .right {
//            /// 改到左边
//
//
//        } else {
//            /// 改到右边
//
//        }
//
//        updateTagInfo.onNext(upTagInfo)
    }
    
    func update() {
        
        guard let superViewW = superview?.width,
              let superViewH = superview?.height,
              let tagInfo = self.tagInfo else {
                return
        }

        var upTagInfo: TagInfo?
        if tagInfo.direction == .right {
            
            /// 计算 point center 位置
            let pointCenterX = left + pointShadowView.width * 0.5
            let pointCenterY = centerY
            let centerPointRatio = CGPoint(
                x: pointCenterX / superViewW,
                y: pointCenterY / superViewH
            )
            
            /// 计算 title center 位置
            let titleW = width - pointShadowView.width - 21
            let titleCenterX = left + pointShadowView.width + 21 + titleW * 0.5
            let titleCenterY = centerY
            let titleCenterPointRatio = CGPoint(
                x: titleCenterX / superViewW,
                y: titleCenterY / superViewH
            )
            
            upTagInfo = TagInfo(
                tagID: tagInfo.tagID,
                centerPointRatio: centerPointRatio,
                title: tagInfo.title,
                titleCenterPointRatio: titleCenterPointRatio,
                direction: tagInfo.direction
            )
        } else {
            
            /// 计算 point center 位置
            let pointCenterX = right - pointShadowView.width * 0.5
            let pointCenterY = centerY
            let centerPointRatio = CGPoint(
                x: pointCenterX / superViewW,
                y: pointCenterY / superViewH
            )
            
            /// 计算 title center 位置
            let titleW = width - pointShadowView.width - 21
            let titleCenterX = left + titleW * 0.5
            let titleCenterY = centerY
            let titleCenterPointRatio = CGPoint(
                x: titleCenterX / superViewW,
                y: titleCenterY / superViewH
            )

            upTagInfo = TagInfo(
                tagID: tagInfo.tagID,
                centerPointRatio: centerPointRatio,
                title: tagInfo.title,
                titleCenterPointRatio: titleCenterPointRatio,
                direction: tagInfo.direction
            )
        }
        guard let info = upTagInfo else { return }
        updateTagInfo.onNext(info)
    }
    
    func remove(tagInfo: TagInfo) {

        self.superview?.bringSubviewToFront(self)
        
        UIView.animate(withDuration: 0.4, animations: {
            if tagInfo.direction == .right {
                self.contentView.width = 0
            } else {
                self.contentView.left = self.pointCenterView.left
                self.contentView.width = 0
            }
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func create(tagInfo: TagInfo) {
        
        guard let superViewW = superview?.width,
              let superViewH = superview?.height else {
                return
        }
        
        tagID = tagInfo.tagID
        
        self.tagInfo = tagInfo
        
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
        
        /// 确定点
        configurePointView()
        pointShadowView.top = (height - pointShadowView.width) * 0.5
        pointShadowView.left = 0
        pointCenterView.center = pointShadowView.center
        
        contentView.top = 0
        contentView.height = 22
        addSubview(contentView)
        
        if tagInfo.direction == .right {
            
            let contentViewLeft = left + pointShadowView.width + 21
            /// contentViewW = 线的宽度 + titleCenterPoint
            let contentViewW = (titleCenterPoint.x - contentViewLeft) * 2 + 25
            contentView.left = pointCenterView.right
            contentView.width = contentViewW
            
            UIView.animate(withDuration: 0.4) {
                /// 设置自己的宽度, - 4 是因为有4个像素缩进 pointView 里边, 线和点要链接在一起
                self.width = self.pointShadowView.width + contentViewW - 4
            }
        } else {
            
            let rightSpace = superViewW - right
            let contentViewRight = superViewW - pointShadowView.width - 21 - rightSpace
            let contentViewW = (contentViewRight - titleCenterPoint.x) * 2 + 25
            left = left - contentViewW + 4

            /// 设置自己的宽度, - 4 是因为有4个像素缩进 pointView 里边, 线和点要链接在一起
            width = pointShadowView.width + contentViewW - 4

            /// 重新设置 pointView 位置
            pointShadowView.left = width - pointShadowView.width
            pointCenterView.center = pointShadowView.center

            self.contentView.right = self.pointCenterView.left
            
            UIView.animate(withDuration: 0.4) {
                self.contentView.width = contentViewW
                self.contentView.left = 0
            }
        }
        
        contentView.input.createContent.onNext(tagInfo)

        configureGesture()
    }
}

private extension TagView {
    
    func configureGesture() {
        
        tapGesture.rx.event
            .bind { [unowned self] gesture in
                guard let tagInfo = self.tagInfo else { return }
                self.clickTagView.onNext(tagInfo)
                self.superview?.bringSubviewToFront(self)
            }
            .disposed(by: rx.disposeBag)
        
        pointGesture.rx.event
            .bind { [unowned self] _ in
                guard let tagInfo = self.tagInfo else { return }
                self.changeDirection(tagInfo: tagInfo)
            }
            .disposed(by: rx.disposeBag)
        
        panGesture.rx.event
            .bind { [unowned self] gesture in
                self.dragging(gesture: gesture)
            }
            .disposed(by: rx.disposeBag)
    }
    
    func configureTagInfo() {
        
        clipsToBounds = true
        
        state
            .subscribe { [unowned self] event in
                
                guard let state = event.element else { return }
                if state == .edit {
                    
                    self.pointShadowView.addGestureRecognizer(self.pointGesture)
                    self.addGestureRecognizer(self.panGesture)
                    self.addGestureRecognizer(self.tapGesture)
                } else {
                    
                    self.addGestureRecognizer(self.tapGesture)
                    
                    self.pointShadowView.removeGestureRecognizer(self.pointGesture)
                    self.removeGestureRecognizer(self.panGesture)
                }
            }
            .disposed(by: rx.disposeBag)
        
        createTag
            .subscribe(onNext: { [unowned self] tagInfo in
                self.create(tagInfo: tagInfo)
            })
            .disposed(by: rx.disposeBag)
        
        removeTag
            .subscribe(onNext: { [unowned self] tagInfo in
                self.remove(tagInfo: tagInfo)
            })
            .disposed(by: rx.disposeBag)
    }
    
    /// 添加没有位置的点
    func configurePointView() {
        /// 小黑点
        pointShadowView.size = CGSize(width: 14, height: 14)
        pointShadowView.cornerRadius = 7
        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addSubview(pointShadowView)

        /// 小白点
        pointCenterView.size = CGSize(width: 6, height: 6)
        pointCenterView.cornerRadius = 3
        pointCenterView.backgroundColor = .white
        pointCenterView.shadowOffset = CGSize(width: 0, height: 1)
        pointCenterView.shadowColor = .black
        pointCenterView.shadowRadius = 1.5
        pointCenterView.shadowOpacity = 0.5
        addSubview(pointCenterView)

        pointCenterView.center = pointShadowView.center
    }
}


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

