angular.module('DashboardCtrl',[]).controller('DashboardController',function($rootScope,$mdDialog,$scope,HistoryServ){


	var self = this;
	self.connectedUsers = 0;
	self.connectedOperators = 0;

	self.TodayDate = moment().format("DD - MM - YYYY");
	self.Query =  {}
	self.Query.dateFilter = "TODAY"
	self.Query.isTotals = true;

	self.Detail = {};
	self.Detail.dateFilter = "TODAY";
	self.Detail.status = "";
	self.Detail.limit = 200;
	self.Detail.status = "ALL";

	function Alerta(title, message){

		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	// Socket.emit('GetUsersConnected', {});
	//
	// Socket.on('RefreshUsersConnected', function (data) {
	// 	console.log("refreshUsersConnected",data);
	// 	self.connectedUsers = data.users;
	// 	self.connectedOperators = data.operators;
	// });
	// Socket.on('RefreshDashboard', function (data) {
	// 	ReloadData();
	// });


	self.DeleteOrder = function(ObjectDB){
		console.log("FOR DELETE");
		console.log(ObjectDB);
		HistoryServ.Delete(ObjectDB._id).success(function(data){
			Alerta('Orden Eliminada', data.message);

			// MAKE THE OPERATOR AVAILABLE AGAIN:
			if(ObjectDB.status != "Normal " && ObjectDB.status != "Canceled") {
				HistoryServ.Available(ObjectDB.operator_id._id).success(function(data){
					console.log(data.message)
				}).error(function(data){
					Alerta('Error',data.message);
				});
			}

			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}

	function ReloadData(){
		HistoryServ.AllWithFilter(self.Query).success(function(data){
			if (data.success) {
				self.ResumeDB = data;
				self.totalOrders = self.ResumeDB.count;
				self.totalPrice = self.ResumeDB.total;
			}else{
				Alerta('Error',data.message);
			}
		}).error(function(data){
			Alerta('Error',data.message);
		});
		HistoryServ.AllWithFilter(self.Detail).success(function(data){
			console.log("ALL WITH FILTER");
			console.log(data);
			if (data.success) {
				if (data.orders) {
					if(data.orders.docs.length > 0) {
						self.OrdersOnDB = data.orders.docs.map(function(order){
							var newOrder = order;
							var type = "Orden";
							if(order.isSchedule) {
								type = "Agendado";
							}
							if (order.isQuotation) {
								type = "Cotizacion";
							}
							newOrder.date = moment(newOrder.date).format("DD/MM/YYYY HH:mm:ss A");
							newOrder.type = type;
							return newOrder;
						});
					}
				}
			}else{
				Alerta('Error',data.message);
			}
		}).error(function(data){
			Alerta('Error',data.message);
		});

		HistoryServ.AllAvailable().success(function(data){
			if (data.success) {
				self.UsersAvailables = data.users;
				angular.forEach(self.UsersAvailables,function(obj){
					if (obj.typeuser == "operator") {
						self.connectedOperators = self.connectedOperators + 1;
					}else{
						self.connectedUsers = self.connectedUsers + 1;
					}
				});
			}else{
				Alerta('Error',data.message);
			}
		}).error(function(data){
			Alerta('Error',data.message);
		});
	}

	ReloadData();

});
