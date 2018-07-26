//
//  PayMethodViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 23/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class PayMethodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var Order = OrderModel();
    var OrderDetailArray:Array<[String:String]> = [];
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Paymethods:Array<PaymethodModel> = [];
    
    var SelectedCard:PaymethodModel!;
    var SelectedPaymethod = "CASH";
    var lastIndexPath = -1;
    var isClickedConfirm = false;
    var isClickedCancel = false;
    var isClickedFinishQuotation = false;
    var clickedOrderOrSchedule = false;
    
    @IBOutlet weak var TopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var PaymethodsTableView: UITableView!
    @IBOutlet weak var PaymethodsView: UIView!
    @IBOutlet weak var PaymethodSegment: UISegmentedControl!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var ButtonsView: UIView!
    @IBOutlet weak var QuotationButton: UIButton!
    @IBOutlet weak var NowScheduleButton: UIButton!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var CardListView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        let nibpay = UINib(nibName: "PaydataTableViewCell", bundle: nil);
        self.PaymethodsTableView.register(nibpay, forCellReuseIdentifier: "CustomCellPay");
        
        self.TotalLabel.text = "$\(Formatter().Number.string(from: NSNumber(value: self.Order.total))!)";
        
        self.PaymethodsView.isHidden = true;
        self.CardListView.isHidden = true;

        
        
        
        if (self.Order.isQuotation) {
            self.ConfirmButton.isHidden = true;
            self.CancelButton.isHidden = true;

        }else{
            self.PaymethodsView.isHidden = false;
            self.NowScheduleButton.isHidden = true;
        }
        
        if (self.Order.isSchedule) {
            self.NowScheduleButton.setTitle("AGENDAR", for: .normal);
        }else{
            self.NowScheduleButton.setTitle("PEDIR AHORA", for: .normal);
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Paymethod")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func reloadData() {
        self.OrderDetailArray = [];
        
        // USER:
        self.OrderDetailArray.append(["title": "NOMBRE DEL OPERADOR", "value": "\(self.Order.oper.name)   |   \(round(self.Order.oper.rate)) Estrellas","icon":"Profile.png"]);
        if (self.Order.isSchedule) {
            let str = Formatter().FullDatePretty.string(from: self.Order.dateSchedule);
            self.OrderDetailArray.append(["title": "FECHA", "value": str,"icon":"Calendar.png"]);
        }else{
            self.OrderDetailArray.append(["title": "FECHA", "value": "INMEDIATAMENTE","icon":"Calendar.png"]);
        }
        self.OrderDetailArray.append(["title": "\(self.Order.group.uppercased())", "value": self.Order.tow,"icon":"TowTruck.png"]);
        self.OrderDetailArray.append(["title": "ORIGEN", "value": self.Order.origin.address,"icon":"Home.png"]);
        self.OrderDetailArray.append(["title": "DESTINO", "value": self.Order.destiny.address,"icon":"MapMarker.png"]);
        
        self.OrderDetailArray.append(["title": "AUTOMÓVIL", "value": self.Order.carinfo,"icon":"Car.png"]);
        self.OrderDetailArray.append(["title": "CONDICIONES", "value": self.Order.conditions,"icon":"Wheel.png"]);
        
        self.MainTableView.reloadData();
        
        
        if(self.SelectedPaymethod == "DEBT"){
        
            SwiftSpinner.show("Cargando métodos de pago");
            
            let AuthUrl = ApiUrl + "/conekta/cards/" + self.UsuarioEnSesion._id;
            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            self.Paymethods = [];
                            
                            for (_,card):(String,JSON) in data["cards"] {
                                
                                var tmp:PaymethodModel = PaymethodModel();
                                
                                tmp.tokenization = card["id"].stringValue;
                                tmp.termination = card["last4"].stringValue;
                                tmp.brand = card["brand"].stringValue;
                                
                                self.Paymethods.append(tmp);
                            }
                            self.PaymethodsTableView.reloadData();
                            SwiftSpinner.hide();
                            
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
                self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0){
            return self.OrderDetailArray.count;
        }else{
            return self.Paymethods.count;
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(tableView.tag == 0){
            
            if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
                cell.separatorInset = UIEdgeInsets.zero;
            }
            if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
                cell.preservesSuperviewLayoutMargins = false;
            }
            
            if cell.responds(to: #selector(setter: UIView.layoutMargins)){
                cell.layoutMargins = UIEdgeInsets.zero;
            }
            
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 60;
        }else{
            return 50;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView.tag == 0){
            let cell:OrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! OrderTableViewCell;
            
            cell.selectionStyle = .none;
            cell.TitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"];
            let image = UIImage(named: self.OrderDetailArray[(indexPath as NSIndexPath).row]["icon"]!);
            cell.IconImageView.image = image;
            cell.SubtitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"];
            
            return cell;

        }else{
            let cell:PaydataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPay", for: indexPath) as! PaydataTableViewCell;
            
            
            if(self.lastIndexPath == (indexPath as NSIndexPath).row){
                cell.CheckmarkImageView.isHidden = false;
            }else{
                cell.CheckmarkImageView.isHidden = true;
            }
            
            cell.IconImageView.image = UIImage(named: "\(self.Paymethods[(indexPath as NSIndexPath).row].brand).png");
            cell.TerminationLabel.text = "**** **** **** \(self.Paymethods[(indexPath as NSIndexPath).row].termination)";
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.tag == 0){
            self.alerta(self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"]!, Mensaje: self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"]!);
        }else{
            self.SelectedCard = self.Paymethods[(indexPath as NSIndexPath).row];
            self.lastIndexPath = (indexPath as NSIndexPath).row;
            self.PaymethodsTableView.reloadData();
        }
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
    
    func alertaWithDisclaimer(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "ACEPTO", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.AcceptOrderNow();
        }
        let cancelAction = UIAlertAction(title: "NO ACEPTO", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.CancelOrderNow();
        }
        alertController.addAction(cancelAction);
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func onChangePaymethod(_ sender: AnyObject) {
        
        if(self.PaymethodSegment.selectedSegmentIndex == 0){
            self.SelectedPaymethod = "CASH";
            self.SelectedCard = nil;
            self.CardListView.isHidden = true;
            self.TopLayout.constant = 0;
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }else{
            if self.Order.total <= 2000 {
                self.TopLayout.constant = -280;
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
                
                self.SelectedPaymethod = "DEBT";
                self.CardListView.isHidden = false;
                self.reloadData();
            }else{
                self.alerta("Oops!", Mensaje: "Nuestra plataforma solo acepta pagos con tarjeta menores a $2,000. Si es tu unico medio de pago puedes seleccionar efectivo y notificar al  operador.");
                self.PaymethodSegment.selectedSegmentIndex = 0;
            }

        }
        
    }
    
    func CancelOrderNow() {
        if (isClickedCancel == false){
            self.isClickedCancel = true;
        SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
    }
    func AcceptOrderNow() {
        if (self.isClickedConfirm == false) {
            self.isClickedConfirm = true;
            SwiftSpinner.show("Enviando confirmación");
            if (self.Order.isSchedule) {
                SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "ScheduleOrder");
                if (self.UsuarioEnSesion.typeuser == "user") {
                    self.alerta("Exito", Mensaje: "Su servicio ha sido agendado, su operador le contactará antes del servicio el dia y hora indicados.");
                }
            }else{
                if(self.SelectedPaymethod == "CASH"){
                    SocketIOManager.sharedInstance.MakePayWithCash(self.Order._id, user_id: self.UsuarioEnSesion._id, paymethod:self.SelectedPaymethod);
                }else{
                    if(self.SelectedCard != nil){
                        SocketIOManager.sharedInstance.MakePayWithDebt(self.Order._id, user_id: self.UsuarioEnSesion._id, paymethod:self.SelectedPaymethod,cardForPayment: self.SelectedCard.tokenization);
                    }else{
                        self.alerta("Oops!", Mensaje: "Selecciona algun metodo de pago");
                    }
                }
            }
        }
    }
    
    @IBAction func FinishQuotation(_ sender: Any) {
        if (self.isClickedFinishQuotation == false) {
            self.isClickedFinishQuotation = true;
            SwiftSpinner.show("Finalizando");
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "EndQuotation");
            if (self.UsuarioEnSesion.typeuser == "user") {
                self.alerta("Exito!", Mensaje: "Su cotización se ha realizado, aparecera en su menu de cotizaciones");
            }
        }

    }
    @IBAction func OrderOrSchedule(_ sender: Any) {
        self.clickedOrderOrSchedule = true;
        
        self.PaymethodsView.isHidden = false;
        self.CancelButton.isHidden = false;
        self.ConfirmButton.isHidden = false;
    }
    
    
    @IBAction func CancelOrder(_ sender: AnyObject) {
        if (clickedOrderOrSchedule) {
            self.clickedOrderOrSchedule = false;
            self.PaymethodsView.isHidden = true;
            self.CancelButton.isHidden = true;
            self.ConfirmButton.isHidden = true;
        }else{
            self.CancelOrderNow();
        }
    }
    @IBAction func ConfirmOrder(_ sender: AnyObject) {
        self.alertaWithDisclaimer("AVISO", Mensaje: "Estimado Cliente le informamos que la tarifa pactada puede modificarse si existe cambios de destino o diferencia en las condiciones reportadas del vehiculo a trasladar");
    }
}
