//
//  CouponViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 16/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class CouponViewController: UIViewController {
    
    var Timer = Foundation.Timer();
    
    @IBOutlet weak var CodeTextfield: UITextField!
    @IBOutlet weak var ApplyButton: UIButton!
    @IBOutlet weak var MenuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        CodeTextfield.layer.borderColor = UIColor.orange.cgColor;
        CodeTextfield.tintColor = UIColor.orange;

        ApplyButton.layer.shadowOpacity = 0.55;
        ApplyButton.layer.shadowRadius = 5.0;
        ApplyButton.layer.shadowColor = UIColor.gray.cgColor;
        ApplyButton.layer.shadowOffset = CGSize(width: 0, height: 2.5);

        NotificationCenter.default.addObserver(self, selector: #selector(CouponViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(CouponViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        // Do any additional setup after loading the view.
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Coupons")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Hide() {
        SwiftSpinner.hide();
        self.alerta("Correcto", Mensaje: "Tu cupon se aplicara en tu siguiente servicio");
    }
    
    @IBAction func ApplyCoupon(_ sender: AnyObject) {
        
        SwiftSpinner.show("Aplicando...");
        self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(CouponViewController.Hide), userInfo: nil, repeats: false)
        RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);
    }


    
    func KeyboardDidShow(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CouponViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func KeyboardDidHidden(){
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func DismissKeyboard(){
        self.CodeTextfield.resignFirstResponder();
    }
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
}
