//
//  TagImageView.swift
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

/// UIImageView 有以下三个模式可供选择
enum State {
    case normal     /// 普通状态, 没有状态
    case edit       /// 全局点击是编辑状态
    case image      /// 全局点击标签进行隐藏或展示
    case video      /// 不需要全局点击按钮
}

protocol TagImageViewInputs {
    
    /// 设置 ImageView 的模式
    var state: BehaviorRelay<State> { get }
    /// 添加标签, 并且进行模式设置
    var addTagInfos: BehaviorRelay<[TagInfo]> { get }
}

class TagImageView: UIImageView {

    var inputs: TagImageViewInputs { return self }
    let state = BehaviorRelay<State>(value: .normal)
    let addTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))

    var tagViews = [TagView]()
    
    var testTitle: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureTagViews()
    }
}

extension TagImageView: TagImageViewInputs {}

private extension TagImageView {
    
    func add(tagInfos: [TagInfo]) {

        tagInfos.forEach { [unowned self] tagInfo in
            let tagView = TagView()
            self.addSubview(tagView)
            tagView.input.createTag.onNext(tagInfo)
            self.tagViews.append(tagView)
        }
    }
    
    func remove() {
        tagViews.forEach { tagView in
            if let tagInfo = tagView.tagInfo {
                tagView.input.removeTag.onNext(tagInfo)
            }
        }
        tagViews = []
    }
    
    /// 点击左边屏幕, 标签文字在右边..  点击右边屏幕, 标签文字在左边
    /// 点击创建的时候 centerPoint  title  titleCenterPoint  direction  都需要计算出来
    func createTagInfo(point: CGPoint, title: String) -> TagInfo? {

        let direction: TagDirection = point.x >= width * 0.5 ? .left : .right
        
        /// 小白点中心点
        let centerPointRatio = CGPoint(
            x: point.x / width,
            y: point.y / height
        )
        
        let pointViewW: CGFloat = 14
        let pointViewH: CGFloat = 22
        
        /// 根据 centerPoint 计算出点的位置
        let pointViewX = point.x - pointViewW * 0.5
//        let pointViewY = point.y - pointViewH * 0.5

        /// 21 是线的长度, 其实线的长度是 25, 缩进小黑点里 4 像素
//        let lineW: CGFloat = 25

        /// 计算 lbl
        let lbl = UILabel(text: title)
        lbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        lbl.sizeToFit()
        /// 12 是文本前后都有 6 像素间距
        let lblW = lbl.width + 12
//        let lblH: CGFloat = 22

        var lblX: CGFloat = 0
        if direction == .right {
            lblX = pointViewX + pointViewW + 21
        } else {
            lblX = pointViewX - 21 - lblW
        }
        
        /// 所以, 在这里就要控制好, 看是否超出了屏幕
        if direction == .right {
            if lblX + lblW >= width {
                debugPrint("超出了")
            } else {
                debugPrint("没有超出")
            }
        } else {
            
        }
        
        let lblCenterXRatio = (lblX + lblW * 0.5) / width
        let lblCenterYRatio = point.y / height
        
        /// 文本中心点
        let titleCenterPointRatio = CGPoint(x: lblCenterXRatio, y: lblCenterYRatio)
        
        let tagInfo = TagInfo(
            centerPointRatio: centerPointRatio,
            title: title,
            titleCenterPointRatio: titleCenterPointRatio,
            direction: direction
        )

        return tagInfo
    }
}

private extension TagImageView {
    
    func configureTagViews() {
        
        state
            .subscribe(onNext: { [unowned self] state in
                self.configureGesture()
            })
            .disposed(by: rx.disposeBag)
        
        addTagInfos
            .subscribe(onNext: { infos in
                self.add(tagInfos: infos)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureGesture() {
        
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer()

        let state = self.state.value
        if state == .edit || state == .image {
            addGestureRecognizer(tapGesture)
        }
        
        tapGesture.rx.event
            .bind(onNext: { [unowned self] gesture in
                if state == .edit {
                    let point = gesture.location(in: self)
                    if point.x > 0 &&
                        point.y > 0 &&
                        point.x < self.width &&
                        point.y < self.height
                    {
                        guard let tagInfo = self.createTagInfo(point: point, title: self.testTitle) else {
                            return
                        }
                        self.add(tagInfos: [tagInfo])
                    }
                } else if state == .image {
                    
                    let tagInfos = self.addTagInfos.value
                    if self.tagViews.count == 0 {
                        self.add(tagInfos: tagInfos)
                    } else {
                        self.remove()
                    }
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}
