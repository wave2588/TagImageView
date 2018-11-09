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
    /// 添加标签
    var addTagInfos: BehaviorRelay<[TagInfo]> { get }
    /// 删除标签
    var removeTagInfos: BehaviorRelay<[TagInfo]> { get }
}

class TagImageView: UIImageView {

    var inputs: TagImageViewInputs { return self }

    let state = BehaviorRelay<State>(value: .normal)
    let addTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))
    let removeTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))

    /// test
    var testTitle: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureTagViews()
    }
}

extension TagImageView: TagImageViewInputs {}

private extension TagImageView {
    
    /// 根据 tagID 去 subViews 里边找, 如果找到了则不添加, 没找到则进行添加
    func add(tagInfo: TagInfo) {
        
        let tagViews = subviews.filter { view -> Bool in
            if let tgView = view as? TagView {
                return tgView.tagID == tagInfo.tagID
            }
            return false
        }

        if tagViews.count == 0 {
            
            let tagView = TagView()
            
            tagView.output
                .removeTagInfo.subscribe(onNext: { [unowned self] info in
                    
                    var infos = self.addTagInfos.value
                    guard let deleteInfo = infos.filter({ tempInfo -> Bool in
                            return tempInfo.tagID == info.tagID
                        }).first else {
                                return
                    }
                    
                    guard let index = infos.firstIndex(where: { info -> Bool in
                            return info.tagID == deleteInfo.tagID
                        }) else {
                                return
                        }
                    infos.remove(at: index)
                    self.addTagInfos.accept(infos)
                })
                .disposed(by: rx.disposeBag)
            
            tagView.output
                .updateTagInfo.subscribe(onNext: { [unowned self] updateTagInfo in
                    var infos = self.addTagInfos.value
                    guard let index = infos.firstIndex(where: { tempInfo -> Bool in
                        return tempInfo.tagID == updateTagInfo.tagID
                    }) else {
                        return
                    }
                    infos[index] = updateTagInfo
                    self.addTagInfos.accept(infos)
                })
                .disposed(by: rx.disposeBag)
            addSubview(tagView)
            tagView.input.createTag.onNext(tagInfo)
            tagView.input.state.onNext(state.value)
        }
    }
    
    func remove(tagInfo: TagInfo) {

        let tagViews = subviews.filter { view -> Bool in
            if let tgView = view as? TagView {
                return tgView.tagID == tagInfo.tagID
            }
            return false
        }

        if tagViews.count != 0 {
            if let tagView = tagViews.first as? TagView {
                tagView.input.removeTag.onNext(tagInfo)
            }
        }
    }
    
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
        var lblW = lbl.width + 12
//        let lblH: CGFloat = 22

        var lblX: CGFloat = 0
        if direction == .right {
            
            lblX = pointViewX + pointViewW + 21
            
            if lblX + lblW >= width {       /// 超出屏幕
                let excess = width - lblX - lblW
                lblW = lblW + excess
            }
        } else {
            lblX = pointViewX - 21 - lblW
            
            if lblX <= 0 {              /// 超出屏幕
                let excess = lblX
                lblW = lblW + excess
                lblX = 0
            }
        }
        
        let lblCenterXRatio = (lblX + lblW * 0.5) / width
        let lblCenterYRatio = point.y / height
        
        /// 文本中心点
        let titleCenterPointRatio = CGPoint(x: lblCenterXRatio, y: lblCenterYRatio)
        
        let tagInfo = TagInfo(
            tagID: uuid(),
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
            .subscribe(onNext: { [unowned self] infos in
                infos.forEach({ info in
                    self.add(tagInfo: info)
                })
            })
            .disposed(by: rx.disposeBag)
        
        removeTagInfos
            .subscribe(onNext: { [unowned self] infos in
                infos.forEach({ info in
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
                        guard let tagInfo = self.createTagInfo(point: point, title: self.testTitle) else {
                            return
                        }
                        var infos = self.addTagInfos.value
                        infos.append(tagInfo)
                        self.addTagInfos.accept(infos)
                    }
                } else if state == .image {
                    
                    /// 获取当前页面上所有的 tagViews
                    let tagViews = self.subviews.filter({ view -> Bool in
                        if let _ = view as? TagView {
                            return true
                        }
                        return false
                    })
                    
                    if tagViews.count == 0 {
                        /// 添加
                        self.addTagInfos.accept(self.addTagInfos.value)
                    } else {
                        /// 删除
                        self.removeTagInfos.accept(self.addTagInfos.value)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        
        /// 测试代码, 实际情况下不会出现
        subviews.forEach { view in
            if let tagView = view as? TagView {
                tagView.input.state.onNext(state)
            }
        }
    }
    
}
