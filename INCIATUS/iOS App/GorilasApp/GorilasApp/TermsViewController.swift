//
//  TermsViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 9/25/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var WebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL (string: "http://gorilasapp.com.mx/index.php/terms-and-conditions/");
        let requestObj = URLRequest(url: url!);
        self.WebView.loadRequest(requestObj);
    }

    @IBAction func Close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    
    //HIDE STATUS BAR:
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool{
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait;
    }
    

}
