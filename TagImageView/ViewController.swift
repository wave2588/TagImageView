//
//  ViewController.swift
//  TagImageView
//
//  Created by wave on 2018/11/7.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tagImageView: TagImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let tagInfoOne = TagInfo(
//            centerPoint: CGPoint(x: 0.5, y: 0.5),
//            title: "123321",
//            contentPoint: CGPoint(x: 0.53, y: 0.5),
//            direction: .left
//        )
//        
//        let infos = [tagInfoOne]
        tagImageView.inputs.state.accept(.edit)
//        tagImageView.inputs.addTagInfos.accept(infos)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.bind { _ in
            debugPrint("我是底部的view 哈哈哈哈")
        }.disposed(by: rx.disposeBag)
        view.addGestureRecognizer(tap)
        
    }


}
