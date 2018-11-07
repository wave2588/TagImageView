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

protocol TagImageViewInputs {
    
    /// 添加标签
    var tagInfos: PublishSubject<[TagInfo]> { get }
}

class TagImageView: UIImageView {

    var inputs: TagImageViewInputs { return self }
    let tagInfos = PublishSubject<[TagInfo]>()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureTagViews()
        configureGesture()
    }
}

extension TagImageView: TagImageViewInputs {}

private extension TagImageView {
    
    func add(tagInfo: TagInfo) {
        
        let x = self.width * tagInfo.point.x
        let y = self.height * tagInfo.point.y
        let tagView = TagView(frame: CGRect(x: x, y: y, width: 14, height: 22))
        tagView.input.tagInfo.onNext(tagInfo)
        self.addSubview(tagView)

        /// 在这里要计算 tagView 的宽高, 显示左右位置判断, 做动画
        
    }
}

private extension TagImageView {
    
    func configureTagViews() {
        
        tagInfos
            .subscribe(onNext: { infos in
                infos.forEach({ [unowned self] info in
                    self.add(tagInfo: info)
                })
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureGesture() {
        
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .bind(onNext: { [unowned self] gesture in
                let point = gesture.location(in: self)
                let tagInfo = TagInfo(
                    point: CGPoint(
                        x: point.x / self.width,
                        y: point.y / self.height
                    ),
                    title: "点击添加"
                )
                self.add(tagInfo: tagInfo)
            })
            .disposed(by: rx.disposeBag)
        addGestureRecognizer(tapGesture)
    }
    
}
