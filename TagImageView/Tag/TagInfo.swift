//
//  TagInfo.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

enum TagDirection {
    case left           /// 文字在左边
    case right          /// 文字在右边
}

struct TagInfo {
    
    /// 小白点的中心点 ( 0 ~ 1 )
    var centerPoint: CGPoint
    
    /// 标题
    var title: String
    
    /// 标题中心点 ( 0 ~ 1 )
    var contentCenterPoint: CGPoint
    
    /// 方向
    var direction: TagDirection
    
    init(centerPoint: CGPoint, title: String, contentCenterPoint: CGPoint, direction: TagDirection) {
        self.centerPoint = centerPoint
        self.title = title
        self.contentCenterPoint = contentCenterPoint
        self.direction = direction
    }
    
}
