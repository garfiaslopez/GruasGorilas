
//
//  State.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 03/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//
import UIKit
import Foundation
import SocketIO
import SwiftyJSON
import SwiftSpinner

class SocketIOManager: NSObject {
    
    let socket = SocketIOClient(socketURL: URL(string: VARS().getApiUrl())!, config: [.log(true), .forcePolling(true)])
    static let sharedInstance = SocketIOManager();
    var actualState:String = "NO_INITIALIZED";
    var beforeState:String = "NO_INITIALIZED";
    var delegate:ViewController!;
    var reconnectTimer:Timer!;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;

    var Info: JSON =  [ "user_id": Session()._id,
                        "name": Session().name,
                        "email": Session().email,
                        "typeuser": Session().typeuser,
                        "device": "Iphone"
                    ];
    
    override init() {
        super.init();
        self.listenActions();
    }
    
    func establishConnection() {
        
        // retreive new session user:
        self.Info =  [ "user_id": Session()._id,
                            "name": Session().name,
                            "email": Session().email,
                            "typeuser": Session().typeuser,
                            "device": "Iphone"
        ];
        socket.connect();
    }

    func closeConnection() {
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            socket.disconnect();
        case .unknown, .offline:
            break;
        }
    }
    
    fileprivate func listenActions() {
        socket.on("HowYouAre") {data, ack in
            if (Session().typeuser != "") {
                self.socket.emit("ConnectedUser",self.Info.object as! SocketData);
            }
        }
        socket.on("disconnect") {data, ack in
            print("DISCONNECTED DEVICE FROM SOCKET");
        }
        socket.on("UpdateOrder") {data, ack in
            print("--------------------------------------CAYO UN UPDATE ORDER --------------------------------------");
            let json = JSON(data[0]);
            let Req = OrderModel(data: json);
            self.ChangeState(Req);
        }
        
        socket.on("ExpiredSession") {data, ack in
            print("LOGGIN OUT FOR ANOTHER SESSION");
            self.delegate.logOut();
        }
    }

    func GetLastOrder(_ type:String,user_id:String,state:String){
        let Data: JSON =  ["type":type,"user_id":user_id];
        self.socket.emit(state,Data.object as! SocketData);
    }
    func SendState(_ order_id:String,user_id:String,state:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        self.socket.emit(state,Data.object as! SocketData);
    }
    func ConfirmPrice(_ order_id:String,user_id:String,total:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id,"total":total];
        self.socket.emit("ConfirmPrice",Data.object as! SocketData);
    }
    func MakePayWithCash(_ order_id:String,user_id:String,paymethod:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id,"paymethod":paymethod];
        self.socket.emit("AcceptPayOrder",Data.object as! SocketData);
    }
    func MakePayWithDebt(_ order_id:String,user_id:String,paymethod:String, cardForPayment:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id,"paymethod":paymethod,"cardForPayment": cardForPayment];
        self.socket.emit("AcceptPayOrder",Data.object as! SocketData);
    }
    func RequestOrder(_ order_id:String,user_id:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        self.socket.emit("SearchForVendor",Data.object as! SocketData);
    }
    func AcceptOrder(_ order_id:String,user_id:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        self.socket.emit("AcceptOrder",Data.object as! SocketData);
    }
    func ChangeState(_ Data:OrderModel){
        self.beforeState = self.actualState;
        self.actualState = Data.status;
        self.delegate.reloadWithOrder(Data);
    }
}
