//
//  ConfirmOrderOpViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 21/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps

class ConfirmOrderOpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var Order = OrderModel();
    var UsuarioEnSesion:Session = Session();
    var OrderDetailArray:Array<[String:String]> = [];
    var isClickedConfirm = false;
    var isClickedCancel = false;
    
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var CallButton: UIButton!
    @IBOutlet weak var ConfirmPriceButton: UIButton!
    @IBOutlet weak var PriceTextField: UITextField!
    
    @IBOutlet weak var MainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConfirmOrderOpViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ConfirmOrderOpViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        print(self.Order)

        self.reloadData();
    }
    
    func reloadData() {
        self.OrderDetailArray = [];
        
        // USER:
        self.OrderDetailArray.append(["title": "NOMBRE DEL USUARIO", "value": "\(self.Order.user.name)   |   \(round(self.Order.user.rate)) Estrellas","icon":"Profile.png"]);
        if (self.Order.isSchedule) {
            let str = Formatter().FullDatePretty.string(from: self.Order.dateSchedule);
            self.OrderDetailArray.append(["title": "FECHA", "value": str,"icon":"Calendar.png"]);
        }else{
            self.OrderDetailArray.append(["title": "FECHA", "value": "INMEDIATAMENTE","icon":"Calendar.png"]);
        }
        self.OrderDetailArray.append(["title": "ORIGEN", "value": self.Order.origin.address,"icon":"Home.png"]);
        self.OrderDetailArray.append(["title": "DESTINO", "value": self.Order.destiny.address,"icon":"MapMarker.png"]);
        
        self.OrderDetailArray.append(["title": "AUTOMÓVIL", "value": self.Order.carinfo,"icon":"Car.png"]);
        self.OrderDetailArray.append(["title": "CONDICIONES", "value": self.Order.conditions,"icon":"Wheel.png"]);
        
        self.MainTableView.reloadData();

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.OrderDetailArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! OrderTableViewCell;
        cell.selectionStyle = .none;
        cell.TitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"];
        let image = UIImage(named: self.OrderDetailArray[(indexPath as NSIndexPath).row]["icon"]!);
        cell.IconImageView.image = image;
        cell.SubtitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"];
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.alerta(self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"]!, Mensaje: self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"]!);
    }

    @IBAction func ConfirmPriceAction(_ sender: AnyObject) {
        
        if (self.PriceTextField.text != "" && self.isNumeric(self.PriceTextField.text!)) {
            if (self.isClickedConfirm == false) {
                self.isClickedConfirm = true;
                SocketIOManager.sharedInstance.ConfirmPrice(self.Order._id, user_id: self.UsuarioEnSesion._id, total: self.PriceTextField.text!);
            }
        } else {
            self.alerta("Oops!", Mensaje: "Introducir un valor numerico valido de precio.");
        }
    }
    
    @IBAction func CancelOrder(_ sender: AnyObject) {
        if (isClickedCancel == false){
            self.isClickedCancel = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
    }
    @IBAction func CallToUser(_ sender: AnyObject) {
        let phoneNumber: String = "tel://\(self.Order.user.phone)";
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    
    func isNumeric(_ string: String) -> Bool
    {
        let number = Double(string);
        return number != nil
    }
    
    func KeyboardDidShow(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConfirmOrderOpViewController.DismissKeyboard))
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
        self.PriceTextField.resignFirstResponder();
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok Pressed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
}
