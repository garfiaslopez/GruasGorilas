//
//  LoadingViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 11/6/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingViewController: UIViewController {

    @IBOutlet weak var LoadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let frame = CGRect(x: 0, y: 0, width: 80, height: 80);
        let animationView =  NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: UIColor.white, padding: 0.0);
        self.LoadingView.addSubview(animationView);
        animationView.startAnimating();
    }
    
    @IBAction func CallCentral(_ sender: Any) {
        let phoneNumber: String = "tel://5556839645";
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    
}
