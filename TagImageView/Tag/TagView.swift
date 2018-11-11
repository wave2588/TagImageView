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
    
    
    /// 点
    private var pointView = TagPointView()
    
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
        
        guard let superViewW = superview?.width,
            let superViewH = superview?.height else {
                return
        }
        
        let pointViewW = TagTool.pointWidth
        
        /// 先计算点的位置
        let centerPoint = CGPoint(
            x: tagInfo.centerPointRatio.x * superViewW,
            y: tagInfo.centerPointRatio.y * superViewH
        )
        
        /// 改变方向... 相当于把 TagImageView 计算的过程重新来一遍....
        if tagInfo.direction == .right {
            /// 改到左边
            UIView.animate(withDuration: 0.4, animations: {
                self.contentView.width = 0
            }) { _ in
                self.width = pointViewW
                self.center = centerPoint
                self.pointView.left = 0

                /// 计算 contentView 宽度
                var contentViewW = self.getContentViewWidth(title: tagInfo.title)
                /// 距离父控件的 X 值
                var contentViewX = centerPoint.x - contentViewW
                if contentViewX <= 0 {
                    let excess = contentViewX
                    contentViewW = contentViewW + excess
                    contentViewX = 0
                }
                
                self.width = contentViewW + self.pointView.width * 0.5
                self.left = contentViewX
                self.pointView.right = self.width
                self.contentView.left = self.pointView.left - self.pointView.width * 0.5
                self.contentView.width = contentViewW
                UIView.animate(withDuration: 0.4, animations: {
                    self.contentView.left = 0
                })
                self.contentView.input.updateContent.onNext(.left)
                
                /// 改变源数据
                let titleCenterY = self.centerY
                let titleCenterPointRatio = CGPoint(
                    x: (self.left + contentViewW * 0.5) / superViewW,
                    y: titleCenterY / superViewH
                )
                
                let upTagInfo = TagInfo(
                    tagID: tagInfo.tagID,
                    centerPointRatio: tagInfo.centerPointRatio,
                    title: tagInfo.title,
                    titleCenterPointRatio: titleCenterPointRatio,
                    direction: .left
                )
                self.tagInfo = upTagInfo
                self.updateTagInfo.onNext(upTagInfo)
            }

        } else {
            /// 改到右边
            /// 先把 contentView 隐藏
            UIView.animate(withDuration: 0.4, animations: {
                self.contentView.width = 0
                self.contentView.left = self.width - self.pointView.width * 0.5
            }) { _ in
                self.width = pointViewW
                self.center = centerPoint
                self.pointView.left = 0
                
                /// 计算 contentView 宽度
                var contentViewW = self.getContentViewWidth(title: tagInfo.title)
                /// 距离父控件的 x 值
                let contentViewX = self.left + self.pointView.width * 0.5
                /// 判断是否超出了屏幕
                if contentViewX + contentViewW >= superViewW {
                    let excess = superViewW - contentViewX - contentViewW
                    contentViewW = contentViewW + excess
                }
                
                /// 设置自己的宽度
                self.contentView.width = contentViewW
                self.contentView.left = self.pointView.right - self.pointView.width * 0.5
                let selfWidth = self.pointView.width * 0.5 + contentViewW
                UIView.animate(withDuration: 0.4, animations: {
                    self.width = selfWidth
                })
                self.contentView.updateContent.onNext(.right)
                
                /// 改变源数据
                let titleW = selfWidth - TagTool.lineWidth - self.pointView.width * 0.5
                let titleCenterX = self.left + self.pointView.width * 0.5 + TagTool.lineWidth + titleW * 0.5
                let titleCenterY = self.centerY
                let titleCenterPointRatio = CGPoint(
                    x: titleCenterX / superViewW,
                    y: titleCenterY / superViewH
                )

                let upTagInfo = TagInfo(
                    tagID: tagInfo.tagID,
                    centerPointRatio: tagInfo.centerPointRatio,
                    title: tagInfo.title,
                    titleCenterPointRatio: titleCenterPointRatio,
                    direction: .right
                )
                self.tagInfo = upTagInfo
                self.updateTagInfo.onNext(upTagInfo)
            }
        }
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
            let pointCenterX = left + pointView.width * 0.5
            let pointCenterY = centerY
            let centerPointRatio = CGPoint(
                x: pointCenterX / superViewW,
                y: pointCenterY / superViewH
            )

            /// 计算 title center 位置
            let titleW = width - TagTool.lineWidth - pointView.width * 0.5
            let titleCenterX = pointCenterX + TagTool.lineWidth + titleW * 0.5
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
            let pointCenterX = right - pointView.width * 0.5
            let pointCenterY = centerY
            let centerPointRatio = CGPoint(
                x: pointCenterX / superViewW,
                y: pointCenterY / superViewH
            )

            /// 计算 title center 位置
            let titleW = width - TagTool.lineWidth - pointView.width * 0.5
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
        self.tagInfo = info
        updateTagInfo.onNext(info)
    }
    
    func remove(tagInfo: TagInfo) {

        self.superview?.bringSubviewToFront(self)

        UIView.animate(withDuration: 0.4, animations: {
            if tagInfo.direction == .right {
                self.contentView.width = 0
            } else {
                self.contentView.left = self.pointView.left + self.pointView.width * 0.5
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
        
        /// 先初始化自己的 大小 and 位置
        height = TagTool.pointHeight
        width = TagTool.pointWidth
        center = pointViewCenterPoint
        
        let titleCenterPoint = CGPoint(
            x: tagInfo.titleCenterPointRatio.x * superViewW,
            y: tagInfo.titleCenterPointRatio.y * superViewH
        )
        
        /// 确定点
        pointView.width = TagTool.pointWidth
        pointView.height = TagTool.pointHeight
        pointView.top = (height - pointView.height) * 0.5
        pointView.left = 0
        
        contentView.top = 0
        contentView.height = TagTool.pointHeight
        
        addSubview(contentView)
        addSubview(pointView)

        if tagInfo.direction == .right {
            
            /// 基于父控件的 left
            let lblX = left + pointView.width * 0.5 + TagTool.lineWidth
            let lblW = (titleCenterPoint.x - lblX) * 2
            let contentViewW = lblW + TagTool.lineWidth
            contentView.left = pointView.width * 0.5
            contentView.width = contentViewW
            UIView.animate(withDuration: 0.4) {
                self.width = self.pointView.width * 0.5 + contentViewW
            }
        } else {
            
            let rightSpace = superViewW - right
            let lblW = (superViewW - rightSpace - titleCenterPoint.x - pointView.width * 0.5 - TagTool.lineWidth) * 2
            let contentViewW = lblW + TagTool.lineWidth
            
            width = pointView.width * 0.5 + TagTool.lineWidth + lblW
            left = left - contentViewW + pointView.width * 0.5
            pointView.left = lblW + TagTool.lineWidth - pointView.width * 0.5
            contentView.right = pointView.center.x
            UIView.animate(withDuration: 0.4) {
                self.contentView.left = 0
                self.contentView.width = contentViewW
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
                    
                    self.pointView.addGestureRecognizer(self.pointGesture)
                    
                    self.addGestureRecognizer(self.panGesture)
                    self.addGestureRecognizer(self.tapGesture)
                } else {
                    
                    self.addGestureRecognizer(self.tapGesture)
                    
                    self.pointView.removeGestureRecognizer(self.pointGesture)
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
            .subscribe { event in
                guard let tagInfo = event.element else { return }
                self.remove(tagInfo: tagInfo)
            }
            .disposed(by: rx.disposeBag)
    }
    
}

