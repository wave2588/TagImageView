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

protocol TagImageViewInputs {
    
    /// 是否是编辑模式
    var isEdit: BehaviorRelay<Bool> { get }
    /// 添加标签
    var addTagInfos: BehaviorRelay<[TagInfo]> { get }
    /// 删除标签
    var removeTagInfos: BehaviorRelay<[TagInfo]> { get }
}

protocol TagImageViewOutputs {
    
    /// 点击 Tag
    var clickTagView: PublishSubject<TagInfo> { get }
}

class TagImageView: UIImageView {

    var inputs: TagImageViewInputs { return self }
    let isEdit = BehaviorRelay<Bool>(value: false)
    let addTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))
    let removeTagInfos = BehaviorRelay<[TagInfo]>(value: ([]))

    var outputs: TagImageViewOutputs { return self }
    let clickTagView = PublishSubject<TagInfo>()

    let tapGesture = UITapGestureRecognizer()

    /// test
    var testTitle: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = true
        
        configureTagViews()
        configureGesture()
    }
}

extension TagImageView: TagImageViewInputs {}
extension TagImageView: TagImageViewOutputs {}

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
                    self.removeTagInfos.accept([info])
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
            tagView.inputs.createTag.onNext(tagInfo)
            tagView.inputs.isEdit.accept(isEdit.value)
            tagView.clickTagView
                .bind(to: clickTagView)
                .disposed(by: rx.disposeBag)
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
                tagView.inputs.removeTag.onNext(tagInfo)
            }
        }
    }
    
    /// 点击创建的时候 centerPoint  title  titleCenterPoint  direction  都需要计算出来
    func createTagInfo(point: CGPoint, title: String) -> TagInfo {

        let direction: TagDirection = point.x >= width * 0.5 ? .left : .right
        
        /// 小白点中心点
        let centerPointRatio = CGPoint(
            x: point.x / width,
            y: point.y / height
        )
        
        let lineW = TagTool.lineWidth

        /// 计算 lbl
        var lblW = TagTool.getLblWidth(title: title)

        var lblX: CGFloat = 0
        if direction == .right {
            
            lblX = point.x + lineW
            
            if lblX + lblW >= width {       /// 超出屏幕
                let excess = width - lblX - lblW
                lblW = lblW + excess
            }
        } else {
            lblX = point.x - TagTool.lineWidth - lblW
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
    
    func createStickerInfo(point: CGPoint) {
        
        let size = CGSize(width: 100, height: 100)
        let stickerView = StickerView(frame: .zero)
        stickerView.size = size
        stickerView.center = point
        addSubview(stickerView)
        
        let stickerInfo = StickerInfo(stickerID: NSUUID().uuidString, image: UIImage(named: "test2")!  , centerPointRatio: point, size: size, transform: stickerView.transform)
        stickerView.inputs.stickerInfo.onNext(stickerInfo)
    }
}

private extension TagImageView {
    
    func configureTagViews() {
        
        isEdit
            .subscribe(onNext: { [unowned self] edit in
                if self.isEdit.value {
                    self.addGestureRecognizer(self.tapGesture)
                } else {
                    self.removeGestureRecognizer(self.tapGesture)
                }
                
                /// 测试代码, 实际情况下不会出现
                self.subviews.forEach { view in
                    if let tagView = view as? TagView {
                        tagView.inputs.isEdit.accept(edit)
                    }
                }
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
        
        tapGesture.rx.event
            .bind(onNext: { [unowned self] gesture in
                let point = gesture.location(in: self)
                if point.x > 0 &&
                    point.y > 0 &&
                    point.x < self.width &&
                    point.y < self.height
                {
//                    let tagInfo = self.createTagInfo(point: point, title: self.testTitle)
//                    var infos = self.addTagInfos.value
//                    infos.append(tagInfo)
//                    self.addTagInfos.accept(infos)
                    
                    self.createStickerInfo(point: point)
                    
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
}
