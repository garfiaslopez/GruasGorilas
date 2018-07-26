angular.module('VendorCtrl',[]).controller('VendorController',function($rootScope,$location,$scope,$mdSidenav,$mdDialog,Auth,VendorServ,GroupServ,TowServ){

	var self = this;

	function ReloadData(){

		self.GroupsOnDB = [];
		GroupServ.All().success(function(data){
			self.GroupsOnDB = data.groups;
			console.log(self.GroupsOnDB);
		});


		self.VendorsOnDB = [];
		VendorServ.All().success(function(data){
			self.VendorsOnDB = data.operators;
			console.log(self.VendorsOnDB);
		});
	}

	self.CleanTows = function() {
		self.TowsOnDB = [];
		if (self.Usuario) {
			self.Usuario.tow = '';
		}
	}

	self.LoadTows = function() {
		console.log("SEARCHING");
		console.log(self.Usuario.group);
		TowServ.ByGroup(self.Usuario.group).success(function(data){
			self.TowsOnDB = data.tows;
			console.log(self.TowsOnDB);
		});
	}

	ReloadData();

	self.Detail = function (VendorDB){
       	var parentEl = angular.element(document.body);
		$mdDialog.show({
         	parent: parentEl,
         	template:
		           '<md-dialog style="width:700px;" aria-label="List dialog">' +
		           '  	<md-dialog-content>'+
		           '    	<md-list>'+
		           '      		<md-list-item>'+
		           '       			<p>Name: 	{{info.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Phone: 	{{info.phone}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Group: 	{{info.group.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Genero: 	{{info.gender}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Fecha Nac : 	{{info.birthdate}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Nombre: 	{{info.othercontact.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Telefono: 	{{info.othercontact.phone}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Nombre: 	{{info.paydata.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Banco: 	{{info.paydata.bank}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>CLABE: 	{{info.paydata.clabe}}</p>' +
		           '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Numero Licencia 1: 	{{info.driverLicense.firstNumber}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Numero Licencia 2: 	{{info.driverLicense.secondNumber}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Tipo de Licencia: 	{{info.driverLicense.typeLicense}}</p>' +
				   '      		</md-list-item>' +
		           '		</md-list>'+
		           '  	</md-dialog-content>' +
		           '  	<div class="md-actions">' +
		           '    	<md-button ng-click="closeDialog()" class="md-primary">' +
		           '      		Cerrar' +
		           '    	</md-button>' +
		           '  	</div>' +
		           '</md-dialog>',
         	locals: {
           		info: VendorDB
         	},
          	controller: function DialogController($scope, $mdDialog) {
            	$scope.closeDialog = function() {
              		$mdDialog.hide();
            	}
            	$scope.info = VendorDB;
          	}
        });

	}

	self.Submit = function(){
		if (self.Usuario != undefined &&
			self.Usuario.email != undefined &&
			self.Usuario.password != undefined &&
			self.Usuario.name != undefined &&
			self.Usuario.phone != undefined &&
			self.Usuario.birthdate != undefined &&
			self.Usuario.othercontact != undefined ){
			self.Usuario.marketname = "";

			VendorServ.Create(self.Usuario).success(function(data){
				console.log("CREATING");
				console.log(self.Usuario);
				if(data.success){
					self.VendorSaved = true;
					Alerta('Vendedor Agregado.',data.message);
					ReloadData();
					self.Usuario = {};
				}else{
					Alerta('Error',data.message);
				}
			}).error(function(data){
				Alerta('Error',data.message);
	       	});
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Delete = function(VendorDB){
		VendorServ.Delete(VendorDB._id).success(function(data){
			Alerta('Operador Eliminado',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
		});

	};

	self.Block = function(VendorDB){
		VendorServ.Block(VendorDB._id).success(function(data){
			Alerta('Exito',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
		});
	};

	function Alerta(title, message){
		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		).finally(function() {
			if(self.VendorSaved){
        		$location.path("/Vendor");
			}
        });
	}
});
