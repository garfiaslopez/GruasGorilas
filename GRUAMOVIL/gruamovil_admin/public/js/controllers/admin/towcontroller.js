angular.module('TowCtrl',[]).controller('TowController',function($scope,$mdDialog,TowServ,GroupServ){

	var self = this;

	//initialize 'seccion'
	self.NewTow = {
        group: '',
    	economicNumber: '',
    	plate:'',
    	policyNumber:'',
        expirationDate: '',
        aditional: ''
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.NewTow.group = null;
        self.NewTow.economicNumber = null;
        self.NewTow.plate = null;
        self.NewTow.policyNumber = null;
        self.NewTow.expirationDate = null;
		self.NewTow.aditional = null;
		self.NewTow.serialNumber = null;
		self.NewTow.policyCompany = null;

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

        self.GroupsOnDB = [];
		GroupServ.All().success(function(data){
			self.GroupsOnDB = data.groups;
			console.log(self.GroupsOnDB);
		});

		self.TowsOnDB = [];
		TowServ.All().success(function(data){
			self.TowsOnDB = data.tows;
			console.log(self.TowsOnDB);
		});
	}

	ReloadData();

	self.Submit = function(){

        console.log(self.NewTow);

		if (self.NewTow.economicNumber != undefined &&
			self.NewTow.plate != undefined ){

			if(self.isEditing.flag){

				TowServ.Update(self.isEditing.id,self.NewTow).success(function(data){

					if(data.success){
						Alerta('Grua Actualizada.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{
				TowServ.Create(self.NewTow).success(function(data){
					if(data.success){

						Alerta('Grua Agregada.',data.message);

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

	self.Edit = function(ObjectDB){

		ClearTextFields();
		console.log(ObjectDB);


		self.NewTow.group = ObjectDB.group._id;
        self.NewTow.economicNumber = ObjectDB.economicNumber;
        self.NewTow.plate = ObjectDB.plate;
		self.NewTow.policyCompany = ObjectDB.policyCompany;
		self.NewTow.policyNumber = ObjectDB.policyNumber;
        self.NewTow.expirationDate = new Date(ObjectDB.expirationDate);
		self.NewTow.aditional = ObjectDB.aditional;
		self.NewTow.serialNumber = ObjectDB.serialNumber;

		self.isEditing.flag = true;
		self.isEditing.id = ObjectDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(ObjectDB){
		TowServ.Delete(ObjectDB._id).success(function(data){
			Alerta('Grua Eliminada',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}

	self.Detail = function (TowDB){
       	var parentEl = angular.element(document.body);
		$mdDialog.show({
         	parent: parentEl,
         	template:
		           '<md-dialog style="width:700px;" aria-label="List dialog">' +
		           '  	<md-dialog-content>'+
		           '    	<md-list>'+
		           '      		<md-list-item>'+
		           '       			<p>Grupo: 	{{info.group.name}}</p>' +
		           '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Numero Economico: 	{{info.economicNumber}}</p>' +
				   '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Placas: 	{{info.plate}}</p>' +
		           '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Numero de serie: 	{{info.serialNumber}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Aseguradora: 	{{info.policyCompany}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Numero Póliza: 	{{info.policyNumber}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Fecha de expiracion: 	{{info.expirationDate}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Adicional: 	{{info.aditional}}</p>' +
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
           		info: TowDB
         	},
          	controller: function DialogController($scope, $mdDialog) {
            	$scope.closeDialog = function() {
              		$mdDialog.hide();
            	}
            	$scope.info = TowDB;
          	}
        });
	}
});
