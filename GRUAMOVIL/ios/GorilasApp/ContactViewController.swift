//
//  ContactViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 10/31/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner


class ContactViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var EnterpriseTextField: UITextField!
    @IBOutlet weak var CityTextField: UITextField!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var TopMarginLayout: NSLayoutConstraint!
    @IBOutlet weak var NumberTows: UITextField!
    let EmailToSend = "operaciones@gorilasapp.com.mx";
    let TopScroll = 130;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        self.NameTextField.returnKeyType = .done;
        self.PhoneTextField.returnKeyType = .done;
        self.EmailTextField.returnKeyType = .done;
        self.EnterpriseTextField.returnKeyType = .done;
        self.CityTextField.returnKeyType = .done;
        self.MessageTextView.returnKeyType = .done;
        
        self.NameTextField.delegate = self;
        self.NameTextField.tag = 0;
        self.PhoneTextField.delegate = self;
        self.PhoneTextField.tag = 1;
        self.EmailTextField.delegate = self;
        self.EmailTextField.tag = 2;
        self.EnterpriseTextField.delegate = self;
        self.EnterpriseTextField.tag = 3;
        self.CityTextField.delegate = self;
        self.CityTextField.tag = 4;
        
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    
        AcceptButton.layer.cornerRadius = 15;
        AcceptButton.layer.borderWidth = 1.5;
        AcceptButton.layer.borderColor = UIColor.white.cgColor;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "Login_Contact")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func doneEmail(){
        SwiftSpinner.hide();
        self.NameTextField.text = "";
        self.MessageTextView.text = "";
        self.EmailTextField.text = "";
        self.PhoneTextField.text = "";
        self.alertaAndDismiss("Perfecto", Mensaje: "Muchas gracias por escribirnos, te contactaremos lo antes posible.");
        
    }
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: TopScroll), animated: true);
        
        
    }
    func KeyboardDidHidden(){
        
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
        
    }
    
    func DismissKeyboard(){
        self.EmailTextField.resignFirstResponder();
        self.NameTextField.resignFirstResponder();
        self.MessageTextView.resignFirstResponder();
        self.PhoneTextField.resignFirstResponder();
        self.EnterpriseTextField.resignFirstResponder();
        self.CityTextField.resignFirstResponder();
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok PRessed");
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

    @IBAction func Send(_ sender: Any) {
        
        if(self.NameTextField.text != "" && self.EmailTextField.text != "" && self.MessageTextView.text != ""){
            
            SwiftSpinner.show("Enviando");
            
            let Url = VARS().getMailgunUrl();
            let username = "api"
            let password = VARS().getMailgunKey();
            
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            let headers = [
                "Authorization": "Basic \(base64LoginString)",
                "Content-Type": "application/x-www-form-urlencoded"
            ];
            let parameters = [
                "from": "\(self.NameTextField.text!)<\(self.EmailTextField.text!)>",
                "to": "Operaciones GorilasApp<\(self.EmailToSend)>",
                "subject": "CONTACTO-IPHONE-CLIENT-APP",
                "text": "Empresa: \(self.EnterpriseTextField.text) ----- Ciudad: \(CityTextField.text) ------ Telefono: \(self.PhoneTextField.text!) -----  Mensaje: \(self.MessageTextView.text!) -----  # De gruas: \(self.NumberTows.text!)"
            ];
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(Url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON {
                    response in
                    print(response);
                    if response.result.isSuccess {
                        self.doneEmail();
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .offline:
                SwiftSpinner.hide();
                self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                break;
            default:
                break;
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos.");
        }
        
    }
    @IBAction func BackModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            self.PhoneTextField.becomeFirstResponder();
        case 1:
            self.EmailTextField.becomeFirstResponder();
        case 2:
            self.EnterpriseTextField.becomeFirstResponder();
        case 3:
            self.CityTextField.becomeFirstResponder();
        case 4:
            self.MessageTextView.becomeFirstResponder();
        default:
            self.DismissKeyboard();
        }
        return true;
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
