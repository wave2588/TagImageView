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
