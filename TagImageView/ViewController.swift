//
//  ViewController.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var tagImageView: TagImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let tagInfoOne = TagInfo(point: CGPoint(x: 0.2, y: 0.3), title: "哈哈哈")
        let tagInfoTwo = TagInfo(point: CGPoint(x: 0.2, y: 0.8), title: "哈哈哈")
        
        let infos = [tagInfoOne, tagInfoTwo]
        
        tagImageView.inputs.tagInfos.onNext(infos)
    }


}
