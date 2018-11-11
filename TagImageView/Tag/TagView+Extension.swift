//
//  TagView+Extension.swift
//  TagImageView
//
//  Created by wave on 2018/11/9.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

extension TagView {
    
    private struct AssociatedKeys {
        static var tagID = "eventId"
    }
    
    @IBInspectable var tagID: String? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tagID, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            guard let id = objc_getAssociatedObject(self, &AssociatedKeys.tagID) as? String else { return nil }
            return id
        }
    }
}

class TagTool {
    
    static let lineWidth: CGFloat = 25
    
    static let pointWidth: CGFloat = 14
    static let pointHeight: CGFloat = 22

    static func getLblWidth(title: String) -> CGFloat {
        let lbl = UILabel(text: title)
        lbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        lbl.sizeToFit()
        /// 12 是文本前后都有 6 像素间距
        let lblW = lbl.width + 12
        return lblW
    }
    
    static func getContentViewWidth(title: String) -> CGFloat {
        let lbl = UILabel(text: title)
        lbl.font = UIFont(name: "PingFangSC-Medium", size: 12)
        lbl.sizeToFit()
        /// 12 是文本前后都有 6 像素间距
        let lblW = lbl.width + 12
        /// 25 是白线的宽度
        let width = lblW + 25
        return width
    }
}
