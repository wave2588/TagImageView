//
//  TagContentView.swift
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

protocol TagContentViewInputs {
    
    /// tag 信息
    var createContent: PublishSubject<TagInfo> { get }
    
    /// 更新 contentView 布局
    var updateContent: PublishSubject<TagDirection> { get }
}

class TagContentView: UIView {
    
    var inputs: TagContentViewInputs { return self }
    let createContent = PublishSubject<TagInfo>()
    let updateContent = PublishSubject<TagDirection>()

    private var lineView = UIView()
    private var backView = UIView()
    private var titleLbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCreateContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagContentView: TagContentViewInputs {}

private extension TagContentView {
    
    func create(info: TagInfo) {
        
        lineView.width = TagTool.lineWidth
        lineView.height = 1
        lineView.top = (height - lineView.height) * 0.5
        lineView.backgroundColor = .white
        addSubview(lineView)
        
        backView.width = width - lineView.width
        backView.height = height
        backView.top = 0
        backView.layer.cornerRadius = 11
        backView.layer.masksToBounds = true
        backView.borderColor = .white
        backView.borderWidth = 1
        backView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(backView)

        titleLbl = UILabel(text: info.title)
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        titleLbl.frame = CGRect(x: 6, y: 0, width: backView.width - 12, height: backView.height)
        titleLbl.textColor = .white
        titleLbl.lineBreakMode = .byTruncatingTail
        backView.addSubview(titleLbl)
        
        if info.direction == .right {
            lineView.left = 0
            backView.left = lineView.right
        } else {
            backView.left = 0
            lineView.left = backView.right
        }
    }
    
    func update(direction: TagDirection) {
        backView.width = width - lineView.width
        titleLbl.left = 6
        titleLbl.width = backView.width - 12

        if direction == .right {
            lineView.left = 0
            backView.left = lineView.right
        } else {
            backView.left = 0
            lineView.left = backView.right
        }
    }
}

private extension TagContentView {
    
    func configureCreateContent() {
        
        clipsToBounds = true
        
        createContent
            .subscribe(onNext: { [unowned self] info in
                self.create(info: info)
            })
            .disposed(by: rx.disposeBag)
        
        updateContent
            .subscribe(onNext: { [unowned self] direction in
                self.update(direction: direction)
            })
            .disposed(by: rx.disposeBag)
    }
}

