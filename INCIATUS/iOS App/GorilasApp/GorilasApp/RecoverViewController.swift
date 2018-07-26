//
//  RecoverViewController.swift
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

class RecoverViewController: UIViewController, UITextFieldDelegate {
    
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioSesion: NSDictionary!
    var channelID = UAirship.push().channelID;
    
    @IBOutlet weak var EmailTextfield: UITextField!
    @IBOutlet weak var AcceptButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    
        AcceptButton.layer.cornerRadius = 25;
        AcceptButton.layer.borderWidth = 1.5;
        AcceptButton.layer.borderColor = UIColor.white.cgColor;
        
        EmailTextfield.returnKeyType = .done;
        EmailTextfield.delegate = self;
        
    }

    func isValidEmail(_ testStr:String) -> Bool {
        let emailExpression = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailExpression);
        return emailTest.evaluate(with: testStr);
    }
    
    func KeyboardDidShow(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecoverViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func KeyboardDidHidden(){
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    @IBAction func DoRecover(_ sender: AnyObject) {
        
        if(self.EmailTextfield.text != ""){
            SwiftSpinner.show("Restaurando");
            
            let AuthUrl = ApiUrl + "/forgotpassword";
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                let DatatoSend: Parameters = ["email": self.EmailTextfield.text!];
                Alamofire.request(AuthUrl, method: . post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            SwiftSpinner.hide();
                            self.alerta("Correcto", Mensaje: data["message"].stringValue );
                        }else{
                            SwiftSpinner.hide();
                            self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .unknown, .offline:
                SwiftSpinner.hide();
                self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                break;
            }
        }else{
            alerta("Oops!", Mensaje: "Favor de introducir tu correo");
        }
        
    }
    
    @IBAction func DissmisView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    func DismissKeyboard(){
        EmailTextfield.resignFirstResponder();
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        EmailTextfield.resignFirstResponder();
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        EmailTextfield.resignFirstResponder();
        return true;
    }
    
    
    

}
