//
//  AddPaydataViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 19/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import Caishen

struct MyCard {
    var name:String = "";
    var number:String = "";
    var cvc:String = "";
    var dateMonth:String = "";
    var dateYear:String = "";
}

class AddPaydataViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {

    let ApiUrl = VARS().getApiUrl();
    var CardForSave:MyCard!;
    var UsuarioEnSesion:Session = Session();
    var Paymethods:Array<PaymethodModel> = [];

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
        
    @IBOutlet weak var CardNumber: CardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.CardNumber.cardTextFieldDelegate = self;

        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Paydata_Add")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Caishen.Card, withValidationResult validationResult: CardValidationResult) {
        if validationResult == .Valid {
            self.CardForSave = MyCard(
                name: self.NameTextField.text!,
                number: "\(information.bankCardNumber)",
                cvc: "\(information.cardVerificationCode.rawValue)",
                dateMonth: "\(information.expiryDate.month)",
                dateYear: "\(information.expiryDate.year)"
            );

        }
    }
    
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "Cardio");
    }
    
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] _ in
            
            let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self)
            self?.present(cardIOViewController!, animated: true, completion: nil)
        }
    }
    
    // MARK: - Card.io delegate methods

    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil);
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        self.CardNumber.prefill(cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func cleanTextFields() {
        self.NameTextField.text = "";
    }
    func KeyboardDidShow(){
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPaydataViewController.DismissKeyboard))
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
    
    
    
    @IBAction func SaveAction(_ sender: AnyObject) {
        
        if (self.NameTextField.text != "" &&
            self.CardForSave.number != "" &&
            self.CardForSave.dateYear != "" &&
            self.CardForSave.dateMonth != "" &&
            self.CardForSave.cvc != ""){
            
            self.DismissKeyboard();
            SwiftSpinner.show("Guardando tarjeta.");
            
            let conekta = Conekta();
            conekta.delegate = self;
            conekta.publicKey = VARS().getConektaPublicKey();
            conekta.collectDevice();
            let card = conekta.card();
            card?.setNumber(self.CardForSave.number, name: self.NameTextField.text, cvc: self.CardForSave.cvc, expMonth: self.CardForSave.dateMonth, expYear: self.CardForSave.dateYear);
            
            let token = conekta.token();
            token?.card = card;
            token?.create(success: { (data) -> Void in
                if (data?["object"] as! String != "error"){
                    let ConektaUrl =  VARS().getApiUrl() + "/conekta/card";
                    let headers: HTTPHeaders = [
                        "Authorization": self.UsuarioEnSesion.token
                    ]
                    let status = Reach().connectionStatus();
                    switch status {
                    case .online(.wwan), .online(.wiFi):
                        
                        
                        let DataToSend: Parameters = [
                            "user_id": self.UsuarioEnSesion._id as AnyObject!,
                            "card_token": data?["id"] as AnyObject!,
                            ];
                        
                        Alamofire.request(ConektaUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            if response.result.isSuccess {
                                let data = JSON(data: response.data!);
                                
                                if(data["success"] == true){
                                    SwiftSpinner.hide();
                                    self.cleanTextFields();
                                    self.alertaAndDissmiss("Correcto", Mensaje: data["message"].stringValue );
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
                        SwiftSpinner.hide();
                        self.alerta("Sin Conexion a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                        break;
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: data?["message_to_purchaser"] as! String);
                }
                
                }, andError: { (error) -> Void in
                    print(error);
            })
        }else{
            SwiftSpinner.hide();
            
            self.alerta("Oops!", Mensaje: "Favor de rellenar todos los campos");
        }
        
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
    func alertaAndDissmiss(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil);
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func DismissKeyboard(){
        self.CardNumber.resignFirstResponder();
    }

}
