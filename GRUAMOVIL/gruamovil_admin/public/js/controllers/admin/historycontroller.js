angular.module('HistoryCtrl',[]).controller('HistoryController',function($scope,$mdDialog,HistoryServ,GroupServ,TowServ,VendorServ,ConectionServ){

	var self = this;
	self.Query =  {}
	self.Query.filterSelector = "0";
	self.Query.limit = 10;
	self.Query.page = 1;

	self.totalOrdersOnSearch = 0;
	self.limitOptions = [10,50,100];

	self.DisableRange=true;
	self.disabledOp = true;


	function Alerta(title, message){
		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	self.FilterChanged = function(){
		if(self.Query.filterSelector == 1){
			self.DisableRange=false;
		}else{
			ClearDateTexts();
			self.DisableRange=true;
		}
	}

	function ReloadData() {
		self.GroupsOnDB = [];
		GroupServ.All().success(function(data){
			self.GroupsOnDB = data.groups;
			console.log(self.GroupsOnDB);
		});
	}

	self.CleanTowsAndOperators = function() {
		self.TowsOnDB = [];
		self.OperatorsOnDB = [];
		if (self.Query) {
			self.Query.tow = '';
			self.Query.operator_id = '';
		}
	}
	self.LoadTows = function() {
		TowServ.ByGroup(self.Query.group).success(function(data){
			self.TowsOnDB = data.tows;
			console.log(self.TowsOnDB);
		});

		self.Query.operator_id = '';
		self.disabledOp = true;

	}

	self.CleanOperators = function() {
		self.OperatorsOnDB = [];
		if (self.Query) {
			self.Query.operator_id = '';
		}
	}

	self.LoadOperators = function() {
		VendorServ.AllByGroup(self.Query.group).success(function(data){
			self.OperatorsOnDB = data.users;
			console.log(self.OperatorsOnDB);
		});

		self.Query.tow = '';
		self.disabledOp = false;
	}

	ReloadData();

	self.onPaginate = function(nextPage) {
		self.Query.page = nextPage;
		self.Search();
	}

	self.Search = function(){
		if (self.Query.filterSelector == 0){
			self.Query.dateFilter = "TODAY"
			self.Query.status = "ALL"
		}else{
			self.Query.initialDate = moment(self.Query.FechaInicio).format('YYYY-MM-DD');
			self.Query.finalDate = moment(self.Query.FechaFinal).format('YYYY-MM-DD');
		}

		HistoryServ.AllWithFilter(self.Query).success(function(data){
            if (data.success) {
				if(data.orders.docs) {
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

				self.totalOrdersOnSearch =  data.orders.total
				self.servicesCount = data.orders.docs.length;
				self.servicesTotal = 0.0;
				angular.forEach(data.orders.docs,function(order){
	                self.servicesTotal = self.servicesTotal + order.total;
	            });
				console.log(self.Query);
            }else{
                Alerta('Error',data.message);
            }
        }).error(function(data){
            Alerta('Error',data.message);
        });

		if (self.Query.operator_id ) {
			ConectionServ.AllByOperator(self.Query.operator_id).success(function(data){
				self.totalTime = 0.0;
				self.operatorConections = 0;
				angular.forEach(data.connections,function(con){
					if (con.timeInHours > 0) {
						self.operatorConections = self.operatorConections + 1;
					}
					self.totalTime = self.totalTime + con.timeInHours;
				});
				self.time = self.totalTime.toFixed(2);
	        }).error(function(data){
	            Alerta('Error',data.message);
	        });

		}

	}


	self.DeleteOrder = function(ObjectDB){
		console.log("FOR DELETE");
		console.log(ObjectDB);
		HistoryServ.Delete(ObjectDB._id).success(function(data){
			Alerta('Orden Eliminada', data.message);
			// MAKE THE OPERATOR AVAILABLE AGAIN:
			if(ObjectDB.status != "Normal" && ObjectDB.status != "Canceled") {
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


    self.PrintTableTickets = function(){
		var doc = new jsPDF('p', 'pt', 'letter');
		var Table = document.getElementById('TableTickets');
		console.log(Table);
		doc.fromHTML(Table, 15, 15, {
			'width': 170
		});

		doc.save('TicketsTable.pdf');

	}

});
