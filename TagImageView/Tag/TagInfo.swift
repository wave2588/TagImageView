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
    
    /// 小白点的中心点 ( 0 ~ 1 )
    var centerPoint: CGPoint
    
    /// 标题
    var title: String
    
    /// 标题中心点 ( 0 ~ 1 )
    var titleCenterPoint: CGPoint
    
    /// 方向
    var direction: TagDirection
    
    init(centerPoint: CGPoint, title: String, titleCenterPoint: CGPoint, direction: TagDirection) {
        self.centerPoint = centerPoint
        self.title = title
        self.titleCenterPoint = titleCenterPoint
        self.direction = direction
    }
    
}
