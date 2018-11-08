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
    /// 删除标签
    var removeTagInfos: BehaviorRelay<[TagInfo]> { get }
}

class TagImageView: UIImageView {

    var inputs: TagImageViewInputs { return self }
    let state = BehaviorRelay<State>(value: .normal)
    let addTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))
    let removeTagInfos = BehaviorRelay<[TagInfo]>(value: [])

    override func awakeFromNib() {
        super.awakeFromNib()

        configureTagViews()
    }
}

extension TagImageView: TagImageViewInputs {}

private extension TagImageView {
    
    func add(tagInfo: TagInfo) {

        let tagView = TagView()
        addSubview(tagView)
        tagView.input.createTag.onNext(tagInfo)
    }
    
    func remove(tagInfo: TagInfo) {
        
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
        
        let lblCenterXRatio = (lblX + lblW * 0.5) / width
        let lblCenterYRatio = point.y / height
        
        /// 文本中心点
        let titleCenterPointRatio = CGPoint(x: lblCenterXRatio, y: lblCenterYRatio)
        
//        let view = UIView()
//        view.width = pointViewW
//        view.height = pointViewH
//        view.center = CGPoint(x: centerPointRatio.x * width, y: centerPointRatio.y * height)
//        view.backgroundColor = .blue
//        addSubview(view)
//
//        let lineView = UIView()
//        lineView.backgroundColor = .black
//        if direction == .right {
//            lineView.left = view.right - 4
//        } else {
//            lineView.left = view.left - 21
//        }
//        lineView.centerY = view.centerY
//        lineView.width = lineW
//        lineView.height = 1
//        addSubview(lineView)
//
//        let contentView = UIView()
//        contentView.backgroundColor = .red
//        contentView.width = lblW
//        contentView.height = lblH
//        let ppp = CGPoint(x: titleCenterPointRatio.x * width, y: titleCenterPointRatio.y * height)
//        contentView.center = ppp
//        addSubview(contentView)
        
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
                infos.forEach({ [unowned self] info in
                    self.add(tagInfo: info)
                })
            })
            .disposed(by: rx.disposeBag)
        
        removeTagInfos
            .subscribe(onNext: { infos in
                infos.forEach({ [unowned self] info in
                    self.remove(tagInfo: info)
                })
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
                        guard let tagInfo = self.createTagInfo(point: point, title: "哈哈哈fdsafsdafsdafsds") else {
                            return
                        }
                        self.add(tagInfo: tagInfo)
                    }
                } else if state == .image {
                    debugPrint("展示 或 隐藏 全部标签")
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}
