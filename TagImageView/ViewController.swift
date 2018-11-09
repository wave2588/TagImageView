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
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let one = TagInfo(
            centerPointRatio: CGPoint(x: 0.1056338028169014, y: 0.4686411149825784),
            title: "哈哈哈fdsafsdafsdafsds",
            titleCenterPointRatio: CGPoint(x: 0.3908450704225352, y: 0.4686411149825784),
            direction: .right
        )
        
        let two = TagInfo(
            centerPointRatio: CGPoint(x: 0.07464788732394366, y: 0.8519163763066202),
            title: "哈哈哈fdsafsdafsdafsds",
            titleCenterPointRatio: CGPoint(x: 0.3598591549295775, y: 0.8519163763066202),
            direction: .right
        )

        let three = TagInfo(
            centerPointRatio: CGPoint(x: 0.8929577464788733, y: 0.6672473867595818),
            title: "哈哈哈fdsafsdafsdafsds",
            titleCenterPointRatio: CGPoint(x: 0.6077464788732394, y: 0.6672473867595818),
            direction: .left
        )
        
        let infos = [one, two, three]
        tagImageView.inputs.state.accept(.edit)
        tagImageView.inputs.addTagInfos.accept(infos)
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.bind { _ in
            debugPrint("我是底部的view 哈哈哈哈")
        }.disposed(by: rx.disposeBag)
        view.addGestureRecognizer(tap)
        
        
        textField.rx.text
            .subscribe(onNext: { [unowned self] text in
                self.tagImageView.testTitle = text ?? ""
            })
            .disposed(by: rx.disposeBag)
    }

    @IBAction func change(_ sender: UIButton) {
        if sender.titleLabel?.text == "编辑" {
            tagImageView.inputs.state.accept(.image)
            sender.setTitle("图片", for: .normal)
        } else {
            tagImageView.inputs.state.accept(.edit)
            sender.setTitle("编辑", for: .normal)
        }
    }
    
    @IBAction func printTag(_ sender: UIButton) {
        let infos = tagImageView.outputs.tagInfos.value
        debugPrint(infos)
    }
}
