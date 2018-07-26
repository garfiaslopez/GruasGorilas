//
//  RegisterViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 9/25/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import AirshipKit


class RegisterViewController: UIViewController, UITextFieldDelegate {

    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioSesion: NSDictionary!
    var channelID = UAirship.push().channelID;
    
    @IBOutlet weak var NameTextfield: UITextField!
    @IBOutlet weak var NumberTextfield: UITextField!
    @IBOutlet weak var EmailTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    @IBOutlet weak var AcceptButton: UIButton!
    
    
    @IBOutlet weak var TopViewConstrait: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.NameTextfield.delegate = self;
        self.NameTextfield.tag = 0;
        self.NumberTextfield.delegate = self;
        self.NumberTextfield.tag = 1;
        self.EmailTextfield.delegate = self;
        self.EmailTextfield.tag = 2;
        self.PasswordTextfield.delegate = self;
        self.PasswordTextfield.tag = 3;

        
        self.NameTextfield.returnKeyType = .done;
        self.NumberTextfield.returnKeyType = .done;
        self.EmailTextfield.returnKeyType = .done;
        self.PasswordTextfield.returnKeyType = .done;
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        AcceptButton.layer.cornerRadius = 25;
        AcceptButton.layer.borderWidth = 1.5;
        AcceptButton.layer.borderColor = UIColor.white.cgColor;
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Login_Register")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    @IBAction func DoRegister(_ sender: AnyObject) {
        self.submit();
    }
    @IBAction func DismissView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    func submit() {
        if(self.EmailTextfield.text != "" && self.NameTextfield.text != "" && self.NumberTextfield.text != "" && self.PasswordTextfield.text != ""){
            if isValidEmail(self.EmailTextfield.text!){

                self.DismissKeyboard();
                SwiftSpinner.show("Registrando");
                
                let AuthUrl = Variables.getApiUrl() + "/user";
                let status = Reach().connectionStatus();
                
                switch status {
                case .online(.wwan), .online(.wiFi):
                    
                    let DatatoSend: Parameters = [
                        "name": self.NameTextfield.text!,
                        "email": self.EmailTextfield.text!,
                        "password": self.PasswordTextfield.text!,
                        "phone": self.NumberTextfield.text!
                    ];
                    
                    Alamofire.request(AuthUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                        
                        if response.result.isSuccess {
                            let data = JSON(data: response.data!);
                            if(data["success"] == true){
                                
                                SwiftSpinner.show("Iniciando Sesión");
                                
                                let uuid = UUID().uuidString
                                let LoginUrl = self.Variables.getApiUrl() + "/authenticate";
                                let DatatoSend: Parameters = [
                                    "email": self.EmailTextfield.text!,
                                    "password": self.PasswordTextfield.text!,
                                    "uuid": uuid
                                    ];
                                
                                Alamofire.request(LoginUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                                    
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
                                            
                                            self.Save.set(SaveObj, forKey: "UsuarioEnSesion");
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
                                            
                                            if let swreveal = self.presentingViewController?.presentingViewController as? SWRevealViewController {
                                                if let menu = swreveal.rearViewController as? MenuTableViewController {
                                                    menu.UsuarioEnSesion = Session();
                                                    menu.reloadData();
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
                self.alerta("Oops!", Mensaje: "Favor de introducir un email valido.")
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos.");
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 0:
            self.NumberTextfield.becomeFirstResponder();
        case 1:
            self.EmailTextfield.becomeFirstResponder();
        case 2:
            self.PasswordTextfield.becomeFirstResponder();
        case 3:
            self.submit();
        default:
            self.NameTextfield.becomeFirstResponder();
        }
        
        return true;
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailExpression = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailExpression);
        return emailTest.evaluate(with: testStr);
    }
    
    func KeyboardDidShow(){
        //self.TopViewConstrait.constant = self.Variables.MaxToTopConstrait;
        UIView.animate(withDuration: 0.7, animations: {
            self.view.layoutIfNeeded()
        })
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func KeyboardDidHidden(){
        //self.TopViewConstrait.constant = self.Variables.MinToTopConstrait;
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
        NameTextfield.resignFirstResponder();
        NumberTextfield.resignFirstResponder();
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
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertaAndDismiss(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil);
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    

}
