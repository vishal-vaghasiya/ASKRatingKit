//
//  ViewController.swift
//  UIKitDemo
//

import UIKit
import ASKRatingKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ASKRatingKit.shared.requestRatingIfNeeded()
    }
    
}

