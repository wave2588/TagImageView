//
//  UIView+Extension.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import SwifterSwift

public extension UIView {
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    static func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as! T
    }
    
    static func fromNib<T: UIView>(width: CGFloat, height: CGFloat) -> T {
        let view: T = fromNib()
        view.width = width
        view.height = height
        return view
    }
}

