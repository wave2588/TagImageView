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

//        let tagView = TagView()
//        tagView.input.createTag.onNext(tagInfo)
//        addSubview(tagView)
    }
    
    func remove(tagInfo: TagInfo) {
        
    }
    
    /// 点击左边屏幕, 标签文字在右边..  点击右边屏幕, 标签文字在左边
    /// 点击创建的时候 centerPoint  title  titleCenterPoint  direction  都需要计算出来
    func createTagInfo(centerPoint: CGPoint, title: String) -> TagInfo? {

        let direction: TagDirection = centerPoint.x >= width * 0.5 ? .left : .right
        
        let pointW: CGFloat = 14
        /// 根据 centerPoint 计算出点的位置
        let pointX = (width - pointW) * 0.5
        debugPrint(pointX)
        
        
        
//        let lbl = UILabel(text: title)
//        lbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
//        lbl.sizeToFit()
//
//        /// + 12 是因为文字和左右边框有6个像素
//        let contentW = lbl.width + 12
//        let pointSpace: CGFloat = 4
//        let lineW: CGFloat = 25
//
//        var contentCenterX: CGFloat = 0
//        if direction == .right {
//            contentCenterX = centerPoint.x + lineW + pointSpace
//        } else {
//            contentCenterX = centerPoint.x - lineW - contentW - pointSpace
//        }
//
//        let contentCenterY = centerPoint.y
//        let contentCenterPoint = CGPoint(x: contentCenterX, y: contentCenterY)
//        let contentSize = CGSize(width: contentW, height: 22)
//
//        let tagInfo = TagInfo(
//            centerPoint: centerPoint,
//            title: title,
//            contentCenterPoint: contentCenterPoint,
//            direction: direction
//        )

        return nil
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
                        guard let tagInfo = self.createTagInfo(centerPoint: point, title: "哈哈哈fdsafsdafsdafsd哈哈哈fdsafsdafsdafs") else {
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
