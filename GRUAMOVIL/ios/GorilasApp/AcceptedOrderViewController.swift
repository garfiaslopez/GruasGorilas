//
//  AcceptedOrderViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 23/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class AcceptedOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var LoadingView: UIView!
    
    var Order = OrderModel();
    var OrderDetailArray:Array<[String:String]> = [];
    
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var Descriptionlabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.reloadData();
        
        // Do any additional setup after loading the view.
        
        if(self.Order.isQuotation){
            self.Descriptionlabel.text = "Cotización aceptada, en un momento su operador le proporcionara el precio final del servicio.";
        }else{
                        self.Descriptionlabel.text = "Orden aceptada, en un momento su operador se comunicara con usted.";
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100);
        
        let animationView =  NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: UIColor.white, padding: 0.0);
        
        self.LoadingView.addSubview(animationView);
        animationView.startAnimating();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_AcceptedOrder")
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
    

}
