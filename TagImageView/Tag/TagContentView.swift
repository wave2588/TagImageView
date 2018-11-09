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
}

class TagContentView: UIView {
    
    var input: TagContentViewInputs { return self }
    let createContent = PublishSubject<TagInfo>()
    
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
        
        lineView.width = 25
        lineView.height = 1
        lineView.top = (height - lineView.height) * 0.5
        lineView.backgroundColor = .white
        addSubview(lineView)
        
        backView.width = width - lineView.width
        backView.height = height
        backView.top = 0
        backView.layer.cornerRadius = 11
        backView.layer.masksToBounds = true
        addSubview(backView)

        titleLbl = UILabel(text: info.title)
        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        titleLbl.frame = CGRect(x: 6, y: 0, width: backView.width - 12, height: backView.height)
        titleLbl.textColor = .white
        backView.addSubview(titleLbl)
        
        if info.direction == .right {
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
        
        createContent
            .subscribe(onNext: { [unowned self] info in
                self.create(info: info)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureUI() {
        
    }
}


//class TagContentView: UIView {
//    
//    private var lineView = UIView()
//    private var titleLbl = UILabel()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        configureUI()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension TagContentView {
//    
//    func updateContentView(direction: TagDirection, info: TagInfo) {
//
//        titleLbl.text = info.title
//        titleLbl.sizeToFit()
//        titleLbl.centerY = centerY
//
//        lineView.centerY = centerY
//        lineView.width = 25
//        lineView.height = 1
//
//        /// 文字在左边
//        if direction == .left {
//            
//            titleLbl.left = 6
//            lineView.left = titleLbl.right + 6
//        } else {
//            lineView.left = 0
//            titleLbl.left = lineView.right + 6
//        }
//    }
//}
//
//private extension TagContentView {
//    
//    func configureUI() {
//        
//        clipsToBounds = true
//
//        lineView.backgroundColor = .white
//        addSubview(lineView)
//        
//        titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
//        titleLbl.textColor = .white
//        addSubview(titleLbl)
//    }
//}

///// 容器 view
//containerView.height = height
//containerView.width = 10
//addSubview(containerView)
//
///// 横线
//lineView.width = 25
//lineView.height = 1
//lineView.backgroundColor = UIColor.white
//containerView.addSubview(lineView)
//
///// 文字背景阴影
//visualEffectView.left = lineView.right
//visualEffectView.top = 0
//visualEffectView.height = 22
//visualEffectView.borderWidth = 0.8
//visualEffectView.borderColor = .white
//containerView.addSubview(visualEffectView)
//
///// 文字
//titleLbl.text = info.title
//titleLbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
//titleLbl.textColor = .white
//titleLbl.sizeToFit()
////        titleLbl.left = lineView.right + 6
////        titleLbl.centerY = lineView.centerY
//containerView.addSubview(titleLbl)
//
//visualEffectView.width = titleLbl.width + 12
//
//containerView.width = 25 + self.visualEffectView.width
//
//let resultWidth = self.pointShadowView.width + self.containerView.width

