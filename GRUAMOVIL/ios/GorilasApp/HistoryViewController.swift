//
//  HIstoryViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 12/09/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class HistoryViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {

    let Format = Formatter();
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Orders:Array<OrderModel> = [];
    var Page = 1;
    var Pages = 1;
    var OrdersTotal = 0;
    var Limit = 10;
    var isLoading = false;
    
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var FooterView: UIView!
    @IBOutlet weak var FooterLoading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.MainTableView.allowsSelection = false;
        
        self.FooterView.isHidden = true;
        self.isLoading = false;
        
        self.loadData();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if(self.Orders.count > 0){
            self.Page = 1;
            self.Pages = 1;
            self.OrdersTotal = 0;
            self.isLoading = false;
            self.Orders = [];
            self.loadData();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_History")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func loadData(){
        SwiftSpinner.show("Cargando Historial.");
        
        let AuthUrl = ApiUrl + "/orders/byFilters";
        let headers: HTTPHeaders = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        var idToSend = "user_id";
        if self.UsuarioEnSesion.typeuser == "operator" {
            idToSend = "operator_id";
        }
        let DataToSend: Parameters = [
            "page": self.Page as AnyObject!,
            "limit": self.Limit as AnyObject!,
            idToSend: self.UsuarioEnSesion._id  as AnyObject!
        ];
        let status = Reach().connectionStatus();

        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    print(data);
                    if(data["success"] == true){
                        for (_,order):(String,JSON) in data["orders"]["docs"] {
                            self.Orders.append(OrderModel(data: order));
                        }
                        self.Page = data["orders"]["page"].intValue + 1;
                        self.Pages = data["orders"]["pages"].intValue;
                        self.OrdersTotal = data["orders"]["total"].intValue;
                        self.isLoading = false;
                        self.FooterView.isHidden = true;
                        self.MainTableView.reloadData();
                        SwiftSpinner.hide();
                    }else{
                        SwiftSpinner.hide();
                        self.alerta(Titulo: "Error de sesión", Mensaje: data["message"].stringValue );
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta(Titulo: "Error", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta(Titulo: "Error", Mensaje: "Favor de conectarse a internet");
        }
        
    }
    
    func InfinityHandler(){
        
        if(self.Page <= self.Pages){
            if(self.isLoading == false){
                self.isLoading = true;
                self.FooterView.isHidden = false;
                self.FooterLoading.startAnimating();
                self.loadData();
            }
        }
        
    }
    

    // MARK: - Table view data source
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Orders.count;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = .zero;
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false;
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = .zero;
        }
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath as IndexPath) as! HistoryTableViewCell;
        let date = Format.ParseMoment(self.Orders[indexPath.row].date);
        let order = self.Orders[indexPath.row].order_id;
        cell.DateLabel.text = "#\(order) | \(Format.DatePretty.string(from: date))";
        cell.AddressLabel.text = self.Orders[indexPath.row].destiny.address;
        cell.TotalLabel.text = "$\(self.Orders[indexPath.row].total)";
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maximumOffset - currentOffset) <= -10 {
            self.InfinityHandler();
        }
    }
    
    func alerta(Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }

    
    
}
