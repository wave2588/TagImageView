//
//  StickerView.swift
//  TagImageView
//
//  Created by wave on 2018/11/17.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol StickerViewInputs {
    
    var stickerInfo: PublishSubject<StickerInfo> { get }
}

class StickerView: UIImageView {
    
    var inputs: StickerViewInputs { return self }
    let stickerInfo = PublishSubject<StickerInfo>()
    
    private let tapGesture = UITapGestureRecognizer()
    private let panGesture = UIPanGestureRecognizer()
    private let rotationGesture = UIRotationGestureRecognizer()
    private let pinchGesture = UIPinchGestureRecognizer()

    private var rotationAngleInRadians: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        debugPrint(111)
        configureStickerInfo()
        configureGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StickerView: StickerViewInputs{}

private extension StickerView {
    
    func updateStickerInfo() {
        
    }
}

private extension StickerView {
    
    func configureStickerInfo() {
        stickerInfo
            .subscribe(onNext: { [unowned self] info in
                self.image = info.image
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureGesture() {
        tapGesture.rx.event
            .bind { _ in
                debugPrint(111)
            }
            .disposed(by: rx.disposeBag)
        addGestureRecognizer(tapGesture)
        
        panGesture.rx.event
            .bind { [unowned self] gesture in
                
                guard let superView = self.superview else { return }
                let superViewW = superView.width
                let superViewH = superView.height
                
                let translationPotion = gesture.translation(in: superView)
                let newLeft = self.left + translationPotion.x
                let newTop = self.top + translationPotion.y

                if newLeft > 0 && newLeft + self.width <= superViewW {
                    self.centerX = self.centerX + translationPotion.x
                }
                if newTop > 0 && newTop + self.height <= superViewH {
                    self.centerY = self.centerY + translationPotion.y
                }
                gesture.setTranslation(.zero, in: self)
                if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.updateStickerInfo()
                    debugPrint("拖动结束, 更新info  \(self.center)")
                }
            }
            .disposed(by: rx.disposeBag)
        addGestureRecognizer(panGesture)
        
        rotationGesture.rx.event
            .bind { [unowned self] gesture in
                
                self.transform = self.transform.rotated(by: gesture.rotation)
                gesture.rotation = 0
                if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    self.updateStickerInfo()
                    
                    debugPrint("旋转结束, 更新info  \(self.transform)")
                }
            }
            .disposed(by: rx.disposeBag)
        addGestureRecognizer(rotationGesture)

        pinchGesture.rx.event
            .bind { [unowned self] gesture in
                self.transform = self.transform.scaledBy(x: gesture.scale, y: gesture.scale)
                gesture.scale = 1
                if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                    debugPrint("缩放结束, 更新info  \(self.size)")
                }
            }
            .disposed(by: rx.disposeBag)
        addGestureRecognizer(pinchGesture)
    }
}
