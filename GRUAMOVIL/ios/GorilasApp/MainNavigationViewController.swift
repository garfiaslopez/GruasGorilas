//
//  MainNavigationViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 08/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class MainNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "[z] Arista", size: 20)!, NSForegroundColorAttributeName:UIColor.white];
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }



}
