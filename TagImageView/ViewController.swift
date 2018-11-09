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

func uuid() -> String{
    return NSUUID().uuidString
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let vc = UIStoryboard(name: "TwoSb", bundle: nil).instantiateInitialViewController() as? TwoVC else {
            return
        }
        present(vc, animated: true, completion: nil)
    }
}

