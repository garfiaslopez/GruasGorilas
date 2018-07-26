var Config = require("./config/config");

var socketio = require('socket.io')();
var async = require('async');
var _ = require('lodash');
var request = require('request');
var conekta = require('conekta');
var moment = require('moment');
conekta.api_key = Config.ConektaApiKey;
conekta.locale = 'es';


var UserModel = require("./models/user");
var OrderModel = require("./models/order");

var ConnectedUsers = [];
var ConnectedOperators = [];
var ConnectedAdmins = [];
var ActualOrders = {};

function ConnectUser(NewUser){
	//añadir al arreglo
	if (NewUser.info.typeuser == 'operator') {
		var opIndex = _.findIndex(ConnectedOperators, function(o) { return o.info.user_id == NewUser.info.user_id; });
		if(opIndex == -1){
			ConnectedOperators.push(NewUser);
			NewUser.socket.join('operators');
		}else{
			ConnectedOperators[opIndex].socket.emit('ExpiredSession');
			ConnectedOperators.push(NewUser);
			NewUser.socket.join('operators');
		}
		GetLastOrderFromOperator(NewUser.info.user_id,function(Err, Order){
			NewUser.socket.emit('UpdateOrder',Order);
		});
	}else {
		var usIndex = _.findIndex(ConnectedUsers, function(o) { return o.info.user_id == NewUser.info.user_id; });
		if(usIndex == -1){
			ConnectedUsers.push(NewUser);
			NewUser.socket.join('users');
		}else{
			ConnectedUsers[usIndex].socket.emit('ExpiredSession');
			ConnectedUsers.push(NewUser);
			NewUser.socket.join('users');
		}
		GetLastOrderFromUser(NewUser.info.user_id,function(Err, Order){
			NewUser.socket.emit('UpdateOrder',Order);
		});
	}
	// console.log(NewUser.info);
	// UserModel.findById(NewUser.info.user_id, function(err, User) {
	// 	if(User) {
	// 		User.available = true;
	// 		User.save();
	// 	}
	// });
}

function RemoveUser(NewUser){
	if (NewUser.info.typeuser == 'operator') {
		var i = ConnectedOperators.indexOf(NewUser);
		ConnectedOperators.splice(i, 1);
		NewUser.socket.leave('operators');
	} else {
		var i = ConnectedUsers.indexOf(NewUser);
		ConnectedUsers.splice(i, 1);
		NewUser.socket.leave('users');
	}
	// UserModel.findById(NewUser.info.user_id, function(err, User) {
	// 	if(User) {
	// 		User.available = true;
	// 		User.save();
	// 	}
	// });
}

function ConnectAdmin(NewAdmin) {
	if(ConnectedAdmins.indexOf(NewAdmin) == -1){
		ConnectedAdmins.push(NewAdmin);
		NewAdmin.socket.join('admins');
	}
}

function RemoveAdmin(NewAdmin) {
	var i = ConnectedAdmins.indexOf(NewAdmin);
	ConnectedAdmins.splice(i, 1);
	NewAdmin.socket.leave('admins');
}

function GetUserConnected(UserId,callback){
	var counter = 0;
	ConnectedUsers.forEach(function(UserObject){
		if (UserObject.info.user_id == UserId) {
			callback(UserObject);
		}else{
			counter +=1;
			if(counter == ConnectedUsers.length){
				callback(null);
			}
		}
	});
}


function GetOperatorConnected(OperatorId,callback){
	var counter = 0;
	ConnectedOperators.forEach(function(UserObject){
		if (UserObject.info.user_id == OperatorId) {
			callback(UserObject);
		}else{
			counter +=1;
			if(counter == ConnectedOperators.length){
				callback(null);
			}
		}
	});
}

function GetLastOrderFromUser(UserId,callback) {
	OrderModel.findOne({user_id:UserId})
				.sort({$natural:-1})
				.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
				.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'})
				.populate('tow').populate('group')
				.exec(function(err,Order){
		if(err){
			console.log(err);
			callback('Algo salio mal');
		}
		callback(null,Order);
	});
}

function GetLastOrderFromOperator(OperatorId,callback) {
	// here validate if that vendor is in the ActualOrders Notifications for send it her push order:

	console.log("ON GET LAST ORDER FROM OPERATOR:  " + OperatorId);
	console.log("OP: " + ConnectedOperators.length + "  USERS: " + ConnectedUsers.length);

	var index = -1;
	var order = 0;

	_.forEach(ActualOrders, function(ActualOrder, OrderId) {
		console.log("ORder: " + OrderId);
		console.log("FoundedOperators");
		console.log(ActualOrder.foundedOperators);
		index = _.findIndex(ActualOrder.foundedOperators, function(op){return op == OperatorId});
		console.log("index : " + index);
		if (index != -1) {
			order = OrderId;
		}
	});

	if (order != 0) {
		OrderModel.findById(order)
					.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
					.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'})
					.populate('tow').populate('group')
					.exec(function(err,Order){
			if(err){
				callback('Algo salio mal');
			}

			console.log("PUEDE RECUPERAR UNA ORDEN...");

			// Agregar al vendor al otro arreglo que asegura que vio la orden.
			ActualOrders[order].operators.push(OperatorId);
			// status OFF for getting a new order
			ConnectedOperators.forEach(function(Obj){
				if (Obj.info.user_id == OperatorId) {
					Obj.available = false;
				}
			});
			callback(null,Order);
		});
	}else{
		console.log("ULTIMA ORDEN DESDE DB...");
		OrderModel.findOne({operator_id:OperatorId})
					.sort({$natural:-1})
					.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
					.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'})
					.populate('tow').populate('group')
					.exec(function(err,Order){
			if(err){
				callback('Algo salio mal');
			}
			callback(null,Order);
		});
	}
}

function ChangeOrderStatus(OrderId,NewOrder,callback){
	OrderModel.findById(OrderId)
				.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
				.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'})
				.populate('tow').populate('group').exec(function(err, Order) {
		if(err){
			console.log(err);
			callback({info:'Something wrong with getting user.',error: err});
		}

		if (Order) {
			if (Order.status === 'Requesting' && NewOrder.status === 'Searching' 		|| 
				Order.status === 'Searching' && NewOrder.status === 'SendToCentral' 	||
				Order.status === 'Searching' && NewOrder.status === 'Accepted'			||
				Order.status === 'Accepted' && NewOrder.status === 'Confirmed'			||
				Order.status === 'Confirmed' && NewOrder.status === 'Arriving'			||
				Order.status === 'Confirmed' && NewOrder.status === 'Normal'			||
				Order.status === 'Arriving' && NewOrder.status === 'Arriving'			||
				Order.status === 'Arriving' && NewOrder.status === 'Transporting'		||
				Order.status === 'Transporting' && NewOrder.status === 'Delivered'	||
				Order.status === 'Delivered' && NewOrder.status === 'Delivered'	||
				Order.status === 'Delivered' && NewOrder.status === 'Normal'			||
				Order.status === 'Normal' && NewOrder.status === 'Normal'			||
				Order.status === 'Canceled') {

					if(NewOrder.date) {
						Order.date = NewOrder.date;
					}
					if(NewOrder.status){
						Order.status = NewOrder.status;
					}
					if(NewOrder.total){
						Order.total = NewOrder.total;
					}
					if(NewOrder.cardForPayment){
						Order.cardForPayment = NewOrder.cardForPayment;
					}
					if(NewOrder.paymethod){
						Order.paymethod = NewOrder.paymethod;
					}
					if(NewOrder.transaction_id){
						Order.transaction_id = NewOrder.transaction_id;
					}
					if(NewOrder.isPaid !== undefined){
						Order.isPaid = NewOrder.isPaid;
					}
					if(NewOrder.isSchedule !== undefined){
						Order.isSchedule = NewOrder.isSchedule;
					}
					if(NewOrder.isQuotation !== undefined){
						Order.isQuotation = NewOrder.isQuotation;
					}
					if(NewOrder.operator_id){
						Order.operator_id = NewOrder.operator_id;

						UserModel.findById(NewOrder.operator_id).populate('tow group').exec(function(err,Opera){
							if(err){
								res.json({success: false , message: "Error fallo alguna validacion."});;
							}
							console.log("ASSIGNATING OPERATOR");
							console.log(Opera);

							Order.tow = Opera.tow;
							Order.group = Opera.group;

							Order.save(function(err){
								if(err){
									callback({info:'Error saving on db.'});
								}
								if(NewOrder.operator_id){
									Order.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'},function(ErrPop){
										if(ErrPop){
											callback({info:'Error populating from db.'});
										}
										callback(null,Order);
									});
								} else {
									callback(null,Order);
								}
							});
						});
					}else{
						Order.save(function(err){
							if(err){
								callback({info:'Error saving on db.'});
							}
							if(NewOrder.operator_id){
								Order.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id loc'},function(ErrPop){
									if(ErrPop){
										callback({info:'Error populating from db.'});
									}
									callback(null,Order);
								});
							}else{
								callback(null,Order);
							}
						});
					}
			}else if(NewOrder.status == 'NotAccepted') {
				if(Order.status === 'Searching'){
					Order.status = 'NotAccepted';
					Order.save(function(err){
						if(err){
							callback({info:'Error saving on db.'});
						}
						callback(null,Order);
					});
				}else{
					callback({info:'La orden fue tomada por otro repartidor.'});
				}
			} else if(NewOrder.status == 'Canceled') {
				if(Order.status !== 'Normal'){
					Order.status = 'Canceled';
					Order.save(function(err){
						if(err){
							callback({info:'Error saving on db.'});
						}
						callback(null,Order);
					});
				}else{
					callback({info:'La orden fue cancelada.'});
				}
			} else {
				callback({info:'La orden fue cancelada.'});
			}
		}
	});
}

function GetNearAndAvailableOperators(NearCoords, callback){
	var limit = Config.searchLimit;
	var maxDistance = Config.searchDistance;
	var queryLoc = {
		$near: {
			$geometry: {
				type:'Point',
				coordinates:NearCoords
			},
			$maxDistance:maxDistance
		}
	};
	UserModel.find({'loc.cord': queryLoc, 'available': true, 'blocked': false}).limit(limit).exec(function(err, Operators) {
  		if (err) {
			callback(null);
  		}
      	callback(Operators);
    });
}

function SendPNToUser(push_id,message,callback){
	var UrlToPush = "https://go.urbanairship.com/api/push";
	var Notification = {
		audience: {
			OR: [
				{ ios_channel:  push_id },
				{ android_channel: push_id }
			]
		},
		notification: {
			ios: {
				alert: message.body,
				extra: message.customData,
				sound: "default"
			},
			android: {
				alert: message.body,
				extra: message.customData,
				sound: "default"
			}
		},
    	device_types: "all"
	}
	var Headers = {
		'Accept': 'application/vnd.urbanairship+json; version=3',
		'Content-Type': 'application/json'
	}
	var Auth = {
		'user': Config.UrbanAppKey,
		'pass': Config.UrbanMasterSecret
	}
	request({method: 'POST', uri: UrlToPush, headers: Headers, auth: Auth, body: JSON.stringify(Notification) } , function(error, response, body) {
		if (error) {
			callback(null);
		}
    	callback(body);
	});
}

function MakePay(Order,callback){
	var ConektaProducts = [];
	var p = {
		name: "Traslado Regular Gruas Gorilas",
		unit_price: Order.total * 100,
		quantity: 1,
		description: 'Servicio Gruas Gorilas.'
	}
	ConektaProducts.push(p);
	var name = "Usuario Gruas Gorilas";
	if(Order.user_id.name) {
		name = Order.user_id.name;
	}
	var OrderCharge = {
		amount: Order.total * 100,
		currency: 'MXN',
		description: 'Servicio Traslado Gruas Gorilas',
		card: Order.cardForPayment,
		details: {
			name: name,
			email: Order.user_id.email.address,
			phone: Order.user_id.phone,
			line_items: ConektaProducts
		}
	}
	conekta.Charge.create(OrderCharge,function(ErrorCharge,Charge){
		if(ErrorCharge){
			callback({info:ErrorCharge.message_to_purchaser});
		}
		callback(null,Charge);
	});
}

exports.initialize = function(server){
	var io = socketio.listen(server);

	io.on('connection', function (MainSocket) {
		console.log('OnConnection');
		MainSocket.emit('HowYouAre');

		/////// CONNECTION HANDLER FUNCTIONS   /////////////
		MainSocket.on('ConnectedUser', function (data) {
			if(data.user_id != ''){
				var NewUser = { info: data, socket: MainSocket, available: true };
				ConnectUser(NewUser);
				MainSocket.on('disconnect', function() {
					RemoveUser(NewUser);
				});
			}else{

			}
		});
		MainSocket.on('ConnectedAdmin', function (data) {
			if(data.user_id != ''){
				var NewAdmin = { info: data, socket: MainSocket, available: true  };
				ConnectAdmin(NewAdmin);
				MainSocket.on('disconnect', function() {
					RemoveAdmin(NewAdmin);
				});
			}
	  	});

		MainSocket.on('GetLastOrder', function (data) {
			if (data.type == 'operator') {
				GetLastOrderFromOperator(data.user_id,function(Err, Order){
					MainSocket.emit('UpdateOrder',Order);
				});
			}else{
				GetLastOrderFromUser(data.user_id,function(Err, Order){
					MainSocket.emit('UpdateOrder',Order);
				});
			}
		});

		/////// OPERATIONAL FUNCTIONS   /////////////
		///////////////////////////////////////////////////////////////////////////////////////////

		MainSocket.on('SearchForVendor', function (data) {
			console.log("ON SEARCH VENDOR: ");
			ChangeOrderStatus(data.order_id,{status:'Searching'},function(Error,Order){
			    if(Order){
					MainSocket.emit("UpdateOrder",Order);
					var cancelTimer;
					var Timer = setInterval(function searchOperators() {
						GetNearAndAvailableOperators(Order.origin.cord,function(OperatorsOnDb){
							if(OperatorsOnDb != null && OperatorsOnDb.length != 0){
								console.log('Found Operators');
								OperatorsOnDb.forEach(function(OperatorDB) {
									ActualOrders[data.order_id].foundedOperators.push(OperatorDB._id);
									//Notify each operator on notification push.
									if (OperatorDB.push_id) {
										const msg = {body:'Tienes un nuevo servicio.',customData:{order_id:data.order_id}};
										SendPNToUser(OperatorDB.push_id,msg,function(response){
											if(response){
												console.log('notification sended');
											}
										});
									}
									//Notify each operator on socket connected
									console.log("OPERADORES CONECTADOS");
									console.log(ConnectedOperators);
									ConnectedOperators.forEach(function(OperatorObject){
										if (OperatorObject.info.user_id == OperatorDB._id && OperatorObject.available == true) {
											//Add to the array of operators on actual order
											ActualOrders[data.order_id].operators.push(OperatorObject.info.user_id);
											OperatorObject.available = false;
											OperatorObject.socket.emit("UpdateOrder",Order);
											console.log("Emmited socket to: " + OperatorObject.info.user_id);
										}
									});
								});
								clearInterval(Timer);
							}else{
								console.log('NO OPERATOR');
							}
						});
					},3000);
					cancelTimer = setTimeout(function(){
						ChangeOrderStatus(data.order_id,{status:'NotAccepted'},function(Error,OrderChanged){
							MainSocket.emit("UpdateOrder",OrderChanged);
						});
						clearInterval(Timer);
						clearTimeout(cancelTimer);
						ActualOrders[data.order_id].operators.forEach(function(OperatorId){
							//Compare if the vendor is connected:
							ConnectedOperators.forEach(function(OperatorObject){
								if (OperatorObject.info.user_id == OperatorId) {
									var OperatorOrder = Order;
									OperatorOrder.status = "Expired";
									OperatorObject.socket.emit("UpdateOrder",OperatorOrder);
									OperatorObject.available = true;
								}
							});
						});
						delete ActualOrders[data.order_id];
					},120000);
					ActualOrders[data.order_id] = {
						user_id: data.user_id,
						operators: [],
						foundedOperators: [],
						status: 'Searching',
						timer: Timer,
						expiredTimer: cancelTimer
					}
				}else{
					console.log('NO ORDER');
				}
			});

		});

		MainSocket.on('AcceptOrder', function (data) {
			console.log("ACEPTAR ORDEN: " + data.user_id);
			if(ActualOrders[data.order_id]) {
				if(ActualOrders[data.order_id].status == "Searching") {
					ActualOrders[data.order_id].status = "Accepted";
					clearInterval(ActualOrders[data.order_id].timer);
					clearTimeout(ActualOrders[data.order_id].expiredTimer);
					var NewOrder = {status:'Accepted', operator_id:data.user_id};
					ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){
						if(Order){
							// set status of vendor on false DB
							UserModel.findById(data.user_id, function(err, User) {
								User.available = false;
								User.save();
							});
							//Notify vendor.
							MainSocket.emit('UpdateOrder',Order);
							//Notify User
							GetUserConnected(Order.user_id._id, function(UserSocket){
								if(UserSocket) {
									UserSocket.socket.emit('UpdateOrder',Order);
								}
							});
							//notify to other vendors that was notified with order before.
							if(ActualOrders[data.order_id]) {
								ActualOrders[data.order_id].operators.forEach(function(OperatorId){
									//Compare if the vendor is connected:
									ConnectedOperators.forEach(function(OperatorObject){
										if (OperatorObject.info.user_id == OperatorId && OperatorId !== data.user_id) {
											var OperatorOrder = Order;
											OperatorOrder.status = "AlreadyTaked";
											OperatorObject.socket.emit("UpdateOrder",OperatorOrder);
											OperatorObject.available = true;
										}
									});
								});
							}

							if (Order.user_id.push_id) {
								const msg = {body:'Tu orden fue aceptada por un operador.',customData:{order_id:data.order_id}};
								SendPNToUser(Order.user_id.push_id,msg,function(response){
									if(response){
									}
								});
							}
							//delete actualorder...
							delete ActualOrders[data.order_id];
						}
						if(Err){
							MainSocket.emit('ErrorOrder',Err);
						}
					});
				}else{
					console.log("EMITTING ALREADY TAKEN");
					MainSocket.emit('UpdateOrder',{ status: 'AlreadyTaked' });
				}
			}else{
				console.log("EMITTING ALREADY TAKEN");
				MainSocket.emit('UpdateOrder',{ status: 'AlreadyTaked' });
			}
		});

		// Operator confirm service cost....
		MainSocket.on('ConfirmPrice', function (data) {
			console.log("CONFIRM PRICE ");
			var NewOrder = {status:'Confirmed', total:data.total};
			ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){
				if(Order) {
					if (Order.user_id.push_id) {
						const msg = {body:'Tu operador estableció el costo del servicio.',customData:{order_id:data.order_id}};
						SendPNToUser(Order.user_id.push_id,msg,function(response){
							if(response){
							}
						});
					}
					//Notify User
					GetUserConnected(Order.user_id._id, function(UserSocket){
						if(UserSocket){
							UserSocket.socket.emit('UpdateOrder',Order);
						}
					});
					MainSocket.emit('UpdateOrder',Order);
				}
			});
		});

		// IF  is quotation this is the action for send to main view and get everything normal:
		MainSocket.on('EndQuotation', function(data){
			console.log('Ending Quotation');
			var NewOrder = {status:'Normal', isQuotation: true, isSchedule: false};
			ChangeOrderStatus(data.order_id, NewOrder, function(Err,Order) {
				if(Order) {
					//set true to database.
					UserModel.findById(Order.operator_id._id, function(err, Op) {
						Op.available = true;
						Op.save();
					});
					//set true in socket connection
					ConnectedOperators.forEach(function(OpObject){
						if (OpObject.info.user_id == Order.operator_id._id) {
							OpObject.available = true;
						}
					});
					MainSocket.emit('UpdateOrder',Order);
					GetOperatorConnected(Order.operator_id._id, function(OperatorSocket){
						if (OperatorSocket){
							OperatorSocket.socket.emit('UpdateOrder',Order);
						}
					});
					delete ActualOrders[data.order_id];
				}
			});
		})
		// IF user decided Schedule the order in that moment....
		MainSocket.on('ScheduleOrder', function(data){
			console.log('Ending schedule');
			var NewOrder = {status:'Normal', isSchedule: true, isQuotation: false};
			ChangeOrderStatus(data.order_id, NewOrder, function(Err,Order) {
				if(Order) {
					//set true to database.
					UserModel.findById(Order.operator_id._id, function(err, Op) {
						Op.available = true;
						Op.save();
					});
					//set true in socket connection
					ConnectedOperators.forEach(function(OpObject){
						if (OpObject.info.user_id == Order.operator_id._id) {
							OpObject.available = true;
						}
					});
					MainSocket.emit('UpdateOrder',Order);
					GetOperatorConnected(Order.operator_id._id, function(OperatorSocket){
						if (OperatorSocket){
							OperatorSocket.socket.emit('UpdateOrder',Order);
						}
					});
					delete ActualOrders[data.order_id];
				}
			});
		});

		// IF user decided Schedule the order in that moment....
		MainSocket.on('EndScheduleOrder', function(data){
			console.log('Ending Arrived Schedule Order');
			var NewOrder = {status:'Normal', isSchedule: false, isQuotation: false, date: moment(new Date()).utc() };
			ChangeOrderStatus(data.order_id, NewOrder, function(Err,Order) {
				if(Order) {
					console.log("DONE CHANGED ORDER");
					// //set true to database.
					// UserModel.findById(Order.operator_id._id, function(err, Op) {
					// 	Op.available = true;
					// 	Op.save();
					// });
					// //set true in socket connection
					// ConnectedOperators.forEach(function(OpObject){
					// 	if (OpObject.info.user_id == Order.operator_id._id) {
					// 		OpObject.available = true;
					// 	}
					// });
				}
			});
		});


		// User last confirm of service and pays....
		MainSocket.on('AcceptPayOrder', function (data) {
			console.log("PROCESSING PAY");
			if(data.paymethod === 'DEBT') {
				var NewOrder = {status:'Arriving', paymethod:data.paymethod, cardForPayment: data.cardForPayment, isQuotation: false};
				ChangeOrderStatus(data.order_id,NewOrder,function(Err,Order){
					if(Order) {
						// Check if was a quotation order:
						if (Order.operator_id.push_id) {
							const msg = {body:'El usuario ha confirmado el pago.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.operator_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
						if (Order.user_id.push_id) {
							const msg = {body:'Tu operador esta en camino al lugar donde estas.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.user_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
						MakePay(Order,function(Err,Charge){
							if(Charge){
								NewNewOrder = {status:'Arriving', isPaid:true, transaction_id: Charge.id};
							}else{
								console.log(Err);
								NewNewOrder = {status:'Arriving', isPaid:false};
							}
							ChangeOrderStatus(data.order_id,NewNewOrder,function(Err, Order){
								if(Order){
									MainSocket.emit('UpdateOrder',Order);
									GetOperatorConnected(Order.operator_id._id, function(OperatorSocket){
										if(OperatorSocket) {
											OperatorSocket.socket.emit('UpdateOrder',Order);
										}
									});
								}
								if(Err){
									MainSocket.emit('ErrorOrder',Err);
								}
							});
						});
					}
				});
			}else{
				var NewOrder = {status:'Arriving', paymethod:data.paymethod, isQuotation: false};
				ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){
					if(Order) {
						MainSocket.emit('UpdateOrder',Order);
						if (Order.operator_id.push_id) {
							const msg = {body:'El usuario ha confirmado el pago.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.operator_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
						if (Order.user_id.push_id) {
							const msg = {body:'Tu operador esta en camino al lugar donde estas.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.user_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
						GetOperatorConnected(Order.operator_id._id, function(OperatorSocket){
							if (OperatorSocket){
								OperatorSocket.socket.emit('UpdateOrder',Order);
							}
						});
					}
				});
			}
		});


		MainSocket.on('ToDestiny', function (data) {
			var NewOrder = {status:'Transporting'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){

				if (Order.user_id.push_id) {
					const msg = {body:'Tu operador esta en camino a tu destino.',customData:{order_id:data.order_id}};
					SendPNToUser(Order.user_id.push_id,msg,function(response){
						if(response){
						}
					});
				}

				GetUserConnected(Order.user_id._id, function(UserSocket){
						if(UserSocket){
							UserSocket.socket.emit('UpdateOrder',Order);
						}
				});
				MainSocket.emit('UpdateOrder',Order);
			});
		});

		MainSocket.on('EndTravel', function (data) {
			var NewOrder = {status:'Delivered'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){

				if (Order.user_id.push_id) {
					const msg = {body:'Viaje finalizado, gracias por tu preferencia.',customData:{order_id:data.order_id}};
					SendPNToUser(Order.user_id.push_id,msg,function(response){
						if(response){
						}
					});
				}

				GetUserConnected(Order.user_id._id, function(UserSocket){
					if(UserSocket) {
						UserSocket.socket.emit('UpdateOrder',Order);
					}
				});
				delete ActualOrders[data.order_id];

				//set true to database.
				UserModel.findById(Order.operator_id._id, function(err, Op) {
					Op.available = true;
					Op.save();
				});

				//set true in socket connection
				ConnectedOperators.forEach(function(OpObject){
					if (OpObject.info.user_id == Order.operator_id._id) {
						OpObject.available = true;
					}
				});
				MainSocket.emit('UpdateOrder',Order);
			});
		});

		MainSocket.on('RatedUser', function (data) {
			var NewOrder = {status:'Normal'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Error,Order){
				MainSocket.emit('UpdateOrder',Order);
			});
		});

		MainSocket.on('CancelOrder', function (data) {
			console.log("ORDER CANCELED");
			if(ActualOrders[data.order_id]){
				if(ActualOrders[data.order_id].timer) {
					clearInterval(ActualOrders[data.order_id].timer);
				}
				if(ActualOrders[data.order_id].expiredTimer){
					clearTimeout(ActualOrders[data.order_id].expiredTimer);
				}
			}
			var NewOrder = {status:'Canceled'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Error,Order){
				if(Order){
					if (Order.operator_id) {
						UserModel.findById(Order.operator_id._id, function(err, Op) {
							Op.available = true;
							Op.save();
						});
						if (Order.operator_id.push_id) {
							const msg = {body:'Orden Cancelada.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.operator_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
					}
					if (Order.user_id) {
						if (Order.user_id.push_id) {
							const msg = {body:'Orden Cancelada.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.user_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
					}


					//notify to the user that the order was canceled.
					ConnectedUsers.forEach(function(UserObj){
						if (UserObj.info.user_id == Order.user_id._id) {
							var UserOrder = Order;
							UserOrder.status = "Canceled";
							UserObj.socket.emit("UpdateOrder",UserOrder);
						}
					});
					//notify to other ops that the order was canceled.
					if(ActualOrders[data.order_id]){
						ActualOrders[data.order_id].operators.forEach(function(opid){
							//Compare if the vendor is connected:
							ConnectedOperators.forEach(function(OpObject){
								if (OpObject.info.user_id == opid) {
									var OperatorOrder = Order;
									OperatorOrder.status = "Canceled";
									OpObject.socket.emit("UpdateOrder",OperatorOrder);
									OpObject.available = true;
								}
							});
						});
						delete ActualOrders[data.order_id];
					}else{
						//notify to the op that the order was canceled.
						ConnectedOperators.forEach(function(OpObject){
							if (OpObject.info.user_id == Order.operator_id._id) {
								OpObject.available = true;
								var OpOrder = Order;
								OpOrder.status = "Canceled";
								OpObject.socket.emit("UpdateOrder",OpOrder);
							}
						});
					}
				}
			});
		});

		MainSocket.on('RejectOrder', function (data) {
			console.log("REJECTING ORDER");
			MainSocket.emit('UpdateOrder',{ status: 'Normal' });
			//delete from the vendors array on order object
			if (ActualOrders[data.order_id]) {
				if(ActualOrders[data.order_id].operators.length > 0) {
					var i = ActualOrders[data.order_id].operators.indexOf(data.user_id);
					ActualOrders[data.order_id].operators.splice(i, 1);
					// delete from the foundedVendors array for duplicate get order:
					var x = ActualOrders[data.order_id].foundedOperators.indexOf(data.user_id);
					ActualOrders[data.order_id].foundedOperators.splice(i, 1);
					// status on again for getting a new order
					ConnectedOperators.forEach(function(OpObject){
						if (OpObject.info.user_id == data.user_id) {
							OpObject.available = true;
						}
					});
				}
			}
		});

		/////// ANOTHER EXTRA FUNCTIONS   /////////////

		MainSocket.on('GetUsersConnected', function () {
			MainSocket.emit('RefreshUsersConnected', { users: ConnectedUsers.length, operators: ConnectedOperators.length });
		});

		MainSocket.on('RefreshDashboard', function () {
			io.to('admins').emit('RefreshDashboard');
		});

		MainSocket.on('SendMessage', function (data) {
			if (data.to == 'operator') {
				io.to('operators').emit('Message',{title: data.title , message: data.message});
			} else {
				io.to('users').emit('Message',{title: data.title , message: data.message});
			}
		});
	});
}
