//
//  TagPointView.swift
//  TagImageView
//
//  Created by wave on 2018/11/10.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class TagPointView: UIView {

    /// 白点
    private var pointCenterView = UIView()
    /// 白点阴影
    private var pointShadowView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurePointView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pointShadowView.left = 0
        pointShadowView.top = (height - pointShadowView.height) * 0.5
        pointCenterView.center = pointShadowView.center
    }
}

private extension TagPointView {
    
    func configurePointView() {
        /// 小黑点
        pointShadowView.size = CGSize(width: 14, height: 14)
        pointShadowView.cornerRadius = 7
        pointShadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addAnimation()
        addSubview(pointShadowView)
        
        /// 小白点
        pointCenterView.size = CGSize(width: 6, height: 6)
        pointCenterView.cornerRadius = 3
        pointCenterView.backgroundColor = .white
        pointCenterView.shadowOffset = CGSize(width: 0, height: 1)
        pointCenterView.shadowColor = .black
        pointCenterView.shadowRadius = 1.5
        pointCenterView.shadowOpacity = 0.5
        
        pointCenterView.center = pointShadowView.center
        addSubview(pointCenterView)
    }
}

private extension TagPointView {
    
    func addAnimation() {
        let cka = CAKeyframeAnimation(keyPath: "transform.scale")
        //        cka.values = [0.7, 0.9, 0.9, 3.5, 0.9, 3.5]
        //        cka.values = [0.3, 0.5, 0.5, 1.0, 1.0, 0.5, 0.3]
        cka.values = [0.4, 0.6, 0.6, 1.0, 1.0, 0.6, 0.6, 0.5]
        //        cka.keyTimes = [0.0, 0.3, 0.3, 0.65, 0.65, 1, 1, 1]
        cka.keyTimes = [0.0, 0.3, 0.3, 0.5, 0.5, 0.8, 0.8, 1]
        cka.repeatCount = MAXFLOAT
        cka.duration = 2.0
        pointShadowView.layer.add(cka, forKey: "cka")
    }
    
    func removeAnimation() {
        //        pointShadowView.removeAnimation(forKey: "cka")
    }
}

