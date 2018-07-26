//
//  SearchingOperatorViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 23/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SearchingOperatorViewController: UIViewController {

    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    var clickedOrder = false;
    
    @IBOutlet weak var LoadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_SearchingOp")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let frame = CGRect(x: 0, y: 0, width: 80, height: 80);
        let animationView =  NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: UIColor.white, padding: 0.0);
        self.LoadingView.addSubview(animationView);
        animationView.startAnimating();
    }
    
    @IBAction func CancelAction(_ sender: AnyObject) {
        if(self.clickedOrder == false){
            self.clickedOrder = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
    }
    
}
