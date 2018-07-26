//
//  ScheduleViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 2/1/17.
//  Copyright © 2017 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let Format = Formatter();
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var OrdersSchedules:Array<OrderModel> = [];
    var OrderQuotation:OrderModel!;
    
    var isQuotation = false;
    var SelectedOrder:OrderModel!;

    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var QuotationTable: UITableView!
    @IBOutlet weak var ScheduleTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "FullOrderTableViewCell", bundle: nil);
        self.ScheduleTable.register(nib, forCellReuseIdentifier: "ScheduleCustomCell");
        self.QuotationTable.register(nib, forCellReuseIdentifier: "QuotationCustomCell");
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        // self.reloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Schedules")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
        self.reloadData();
    }
    
    func reloadData() {
        SwiftSpinner.show("Consultando historial");
        let QuotationUrl = Variables.getApiUrl() + "/orders/lastQuotationByUser/" + self.UsuarioEnSesion._id;
        let SchedulesUrl = Variables.getApiUrl() + "/orders/schedulesByUser/" + self.UsuarioEnSesion._id;
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        switch status {
        case .online(.wwan), .online(.wiFi):
            Alamofire.request(QuotationUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    print("DONE WITH QUOTATIONS REQUEST");
                    print(data);
                    if(data["success"] == true){
                        if (data["order"].isEmpty) {
                            self.QuotationTable.isHidden = true;
                        }else{
                            self.QuotationTable.isHidden = false;
                            self.OrderQuotation = OrderModel(data: data["order"]);
                            self.QuotationTable.reloadData();
                        }
                        self.OrdersSchedules = [];

                        //Request SCHEDULES:
                        Alamofire.request(SchedulesUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            if response.result.isSuccess {
                                let dataSchedules = JSON(data: response.data!);
                                if(dataSchedules["success"] == true){
                                    if (dataSchedules["orders"]["docs"].arrayValue.count > 0) {
                                        for (_,order):(String,JSON) in dataSchedules["orders"]["docs"] {
                                            let tmp:OrderModel = OrderModel(data: order);
                                            self.OrdersSchedules.append(tmp);
                                        }
                                    }
                                    self.ScheduleTable.reloadData();
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
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 1) {
            return OrdersSchedules.count;
        } else if (tableView.tag == 0) {
            if(self.OrderQuotation != nil){
                return 1;
            }
            return 0;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:FullOrderTableViewCell!;
        
        if(tableView.tag == 0){
            
            cell = tableView.dequeueReusableCell(withIdentifier: "QuotationCustomCell", for: indexPath) as! FullOrderTableViewCell;
        
            cell.OrderNumberLabel.text = "#\(self.OrderQuotation.order_id)";
            cell.DateLabel.text = self.Format.DatePretty.string(from: self.OrderQuotation.dateSchedule);
            cell.OriginLabel.text = self.OrderQuotation.origin.address;
            cell.DestinyLabel.text = self.OrderQuotation.destiny.address;
            cell.GroupLabel.text = self.OrderQuotation.group;
            cell.TotalLabel.text = "$\(self.OrderQuotation.total)";
            
        
        }else if(tableView.tag == 1) {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCustomCell", for: indexPath) as! FullOrderTableViewCell;

            
            cell.OrderNumberLabel.text = "#\(self.OrdersSchedules[indexPath.row].order_id)";
            cell.DateLabel.text = self.Format.DatePretty.string(from: self.OrdersSchedules[indexPath.row].dateSchedule);
            cell.OriginLabel.text = self.OrdersSchedules[indexPath.row].origin.address;
            cell.DestinyLabel.text = self.OrdersSchedules[indexPath.row].destiny.address;
            cell.GroupLabel.text = self.OrdersSchedules[indexPath.row].group;
            cell.TotalLabel.text = "$\(self.OrdersSchedules[indexPath.row].total)";
        
        }
        
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailFullOrderSegue" {
            if let dest = segue.destination as? DetailFullOrderViewController {
                dest.isQuotation = self.isQuotation;
                dest.Order = self.SelectedOrder;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.tag == 0) {
            self.SelectedOrder = self.OrderQuotation;
            self.isQuotation = true;
        } else if(tableView.tag == 1){
            self.SelectedOrder = self.OrdersSchedules[indexPath.row];
            self.isQuotation = false;
        }
        self.performSegue(withIdentifier: "DetailFullOrderSegue", sender: self);
    }

    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
