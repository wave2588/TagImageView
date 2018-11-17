//
//  StickerInfo.swift
//  iOS
//
//  Created by wave on 2018/11/17.
//  Copyright © 2018 Zhihu. All rights reserved.
//

import UIKit

struct StickerInfo {
    
    var stickerID: String
    
    var image: UIImage

    var centerPointRatio: CGPoint
    
    var size: CGSize
    
    var transform: CGAffineTransform
    
    init(stickerID: String, image: UIImage, centerPointRatio: CGPoint, size: CGSize, transform: CGAffineTransform) {
        self.stickerID = stickerID
        self.image = image
        self.centerPointRatio = centerPointRatio
        self.size = size
        self.transform = transform
    }
    
}
