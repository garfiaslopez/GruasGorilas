angular.module('RouteExampleCtrl',[]).controller('RouteExampleController',function($scope,$mdDialog,RouteExampleServ){

	var self = this;

	//initialize 'seccion'
	self.Ruta = {
		origin: null,
		destiny: null,
		price:null
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.Ruta.origin = null;
		self.Ruta.destiny = null;
		self.Ruta.price = null;

		self.isEditing.flag = false;
		self.isEditing.id = null;
	}

	function Alerta(title, message){

		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	function ReloadData(){
		self.RoutesOnDB = [];
		RouteExampleServ.All().success(function(data){
			self.RoutesOnDB = data.routes;
			console.log(self.RoutesOnDB);
		});
	}

	ReloadData();

	self.Submit = function(){

		if (self.Ruta.origin != undefined &&
			self.Ruta.destiny != undefined &&
			self.Ruta.price != undefined){

			if(self.isEditing.flag){

				RouteExampleServ.Update(self.isEditing.id,self.Ruta).success(function(data){

					if(data.success){
						Alerta('Ruta Actualizado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{
				RouteExampleServ.Create(self.Ruta).success(function(data){
					if(data.success){
						Alerta('Ruta Agregado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}
				}).error(function(data){
					Alerta('Error',data.message);
		       	});
			}
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Edit = function(RutaDB){

		ClearTextFields();

		self.Ruta.origin = RutaDB.origin;
		self.Ruta.destiny = RutaDB.destiny;
		self.Ruta.price = RutaDB.price;

		self.isEditing.flag = true;
		self.isEditing.id = RutaDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(RutaDB){
		RouteExampleServ.Delete(RutaDB._id).success(function(data){
			Alerta('Ruta Eliminado',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}
});
