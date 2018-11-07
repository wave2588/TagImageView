//
//  TagInfo.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

struct TagInfo {

    enum TagDirection {
        case left
        case right
    }
    
    /// 方向
    var direction: TagDirection = .right
    
    /// 比例 (0 ~ 1)
    var point: CGPoint = CGPoint(x: 0, y: 0)
    
    /// 标题
    var title: String = ""
    
    init(point: CGPoint, title: String) {
        self.point = point
        self.title = title
    }
}
