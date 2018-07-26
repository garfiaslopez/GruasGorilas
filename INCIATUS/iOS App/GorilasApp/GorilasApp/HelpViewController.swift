//
//  HelpViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 12/09/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import ZDCChat


class HelpViewController: UIViewController {
    
    
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var SubjectTextField: UITextField!
    @IBOutlet weak var DescriptionTextArea: UITextView!
    @IBOutlet weak var SubmitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController();
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:));
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
        }
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Help")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    @IBAction func chatAction(_ sender: Any) {
        
        if(self.UsuarioEnSesion.typeuser == "user") {
            ZDCChat.updateVisitor { user in
                user?.phone = self.UsuarioEnSesion.phone;
                user?.name = self.UsuarioEnSesion.name;
                user?.email = self.UsuarioEnSesion.email;
            }
            
            ZDCChat.start(in: self.navigationController, withConfig: {config in
                config?.department = "iOS Inciatus"
                config?.tags = ["inciatus", "ios", "app"]
            });
        }else{
            let url: String = "https://inciatus.atavist.com/slack";
            UIApplication.shared.openURL(URL(string:url)!);
        }
    }
    
    
    @IBAction func SubmitAction(_ sender: AnyObject) {
        
        if (self.SubjectTextField.text != "" && self.DescriptionTextArea.text != "") {
            DismissKeyboard();
            SwiftSpinner.show("Enviando");
            let AuthUrl = ApiUrl + "/help";
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                let DatatoSend: Parameters = [
                    "subject": self.SubjectTextField.text as AnyObject!,
                    "description": self.DescriptionTextArea.text as AnyObject!,
                    "user_id": self.UsuarioEnSesion._id
                ] as [String : Any];
                
                Alamofire.request(AuthUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            SwiftSpinner.hide();
                            self.alerta("Enviado", Mensaje: "Gracias por su mensaje, pronto alguien se comunicará con usted.");
                            self.SubjectTextField.text = "";
                            self.DescriptionTextArea.text = "";
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
            
        }
    }
    
    func KeyboardDidShow(){
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HelpViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    func KeyboardDidHidden(){
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
    }
    
    func DismissKeyboard(){
        self.SubjectTextField.resignFirstResponder();
        self.DescriptionTextArea.resignFirstResponder();
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
    
}
