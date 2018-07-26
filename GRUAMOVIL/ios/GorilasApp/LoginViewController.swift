//
//  LoginViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 21/12/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import AirshipKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioSesion: NSDictionary!
    var channelID = UAirship.push().channelID;
    
    @IBOutlet weak var EmailTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var SignupButton: UIButton!
    
    @IBOutlet weak var TopViewConstrait: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.EmailTextfield.delegate = self;
        self.PasswordTextfield.delegate = self;
        self.PasswordTextfield.tag = 1;
        
        self.EmailTextfield.returnKeyType = .done;
        self.PasswordTextfield.returnKeyType = .done;
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        
        
        AcceptButton.layer.cornerRadius = 25;
        AcceptButton.layer.borderWidth = 1.5;
        AcceptButton.layer.borderColor = UIColor.white.cgColor;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.hide();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Login_Main")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    @IBAction func DoLogin(_ sender: AnyObject) {
        self.AcceptAction();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 1) {
            self.AcceptAction();
        }else{
            self.PasswordTextfield.becomeFirstResponder();
        }
        return true;
    }
    
    func KeyboardDidShow(){
        self.TopViewConstrait.constant = self.Variables.MaxToTopConstrait;
        UIView.animate(withDuration: 0.7, animations: {
            self.view.layoutIfNeeded()
        })
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func KeyboardDidHidden(){
        self.TopViewConstrait.constant = self.Variables.MinToTopConstrait;
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func DismissKeyboard(){
        EmailTextfield.resignFirstResponder();
        PasswordTextfield.resignFirstResponder();
        self.TopViewConstrait.constant = 0;
    }
    
    func AcceptAction() {
        self.DismissKeyboard();
        
        if(self.EmailTextfield.text != "" && self.PasswordTextfield.text != "" && self.isValidEmail(self.EmailTextfield.text!)){
            
            SwiftSpinner.show("Iniciando Sesión");
            let AuthUrl = Variables.getApiUrl() + "/authenticate";
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                let uuid = UUID().uuidString;
                let DatatoSend: Parameters = [
                    "email": self.EmailTextfield.text!,
                    "password": self.PasswordTextfield.text!,
                    "uuid": uuid
                ];
                
                Alamofire.request(AuthUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                    
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            //save the user and dissmiss the view
                            var SaveObj = [String : String]();
                            
                            SaveObj["token"] = data["token"].stringValue;
                            SaveObj["_id"] = data["user"]["_id"].stringValue;
                            SaveObj["email"] = data["user"]["email"]["address"].stringValue;
                            SaveObj["name"] = data["user"]["name"].stringValue;
                            SaveObj["phone"] = data["user"]["phone"].stringValue;
                            SaveObj["typeuser"] = data["user"]["typeuser"].stringValue;
                            
                            self.Save.set(SaveObj, forKey: "UsuarioEnSesion")
                            self.Save.set(true, forKey: "connectionState");
                            self.Save.synchronize();
                            
                            SwiftSpinner.hide();
                            
                            //Tags & PushID
                            UAirship.push().tags = [data["user"]["typeuser"].stringValue, "iOS"];
                            UAirship.push().updateRegistration();
                            
                            if((UAirship.push().channelID) != nil){
                                let PutUrl = self.ApiUrl + "/user/" + data["user"]["_id"].stringValue;
                                let headers: HTTPHeaders = [
                                    "Authorization": data["token"].stringValue
                                ];
                                let UserData: Parameters = [
                                    "push_id": UAirship.push().channelID!
                                ];
                                
                                Alamofire.request(PutUrl,method: .put, parameters: UserData, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                                    if response.result.isSuccess {
                                        print("SETED");
                                    }else{
                                        print((response.result.error?.localizedDescription)!);
                                    }
                                }
                            }
                            
                            SocketIOManager.sharedInstance.establishConnection();
                            
                            if let swreveal = self.presentingViewController as? SWRevealViewController {
                                if let menu = swreveal.rearViewController as? MenuTableViewController {
                                    menu.UsuarioEnSesion = Session();
                                    // menu.reloadData();
                                }
                                if let navigation = swreveal.frontViewController as? MainNavigationViewController {
                                    if let Status = navigation.viewControllers.first as? ViewController{
                                        Status.UsuarioEnSesion = Session();
                                        Status.reloadInitViewForTypeOfUser();
                                        Status.dismiss(animated: true, completion: nil);
                                    }
                                }
                            }
                            
                        }else{
                            SwiftSpinner.hide();
                            self.alerta("Oops!", Mensaje: data["message"].stringValue );
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
                
            case .unknown, .offline:
                //No internet connection:
                SwiftSpinner.hide();
                self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
            }
            
        }else{
            self.alerta("Oops!", Mensaje: "Favor de ingresar sus datos.");
        }
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
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        return true;
        
//        let emailExpression = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailExpression);
//        return emailTest.evaluate(with: testStr);
    }
    @IBAction func CallCentral(_ sender: Any) {
        self.alertWithCall("Llamar a la central.", Mensaje: "Desea llamar a la central de operaciones para asignarle una grua en este momento?");
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
    
    func alertWithCloseView(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil);
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertWithCall(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let callAction = UIAlertAction(title: "Llamar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let phoneNumber: String = "tel://5556839645";
            UIApplication.shared.openURL(URL(string:phoneNumber)!);
        }
        let okAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        alertController.addAction(callAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
}
