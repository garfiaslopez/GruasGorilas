angular.module('UserCtrl',[]).controller('UserController',function($scope,$mdDialog,UserServ){

	var self = this;

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
		self.UsersOnDB = [];
		UserServ.All().success(function(data){
			self.UsersOnDB = data.users;
			console.log(self.UsersOnDB);
		});
	}

	ReloadData();


	self.Block = function(UserDB){
		UserServ.Block(UserDB._id).success(function(data){
			Alerta('Exito',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
		});
	};

	self.Delete = function(UserDB){

		UserServ.Delete(UserDB._id).success(function(data){
			Alerta('Usuario Eliminado',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
	    });

	};

	self.Detail = function (UserDB){
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
				   '       			<p>Email: 	{{info.email.address}}</p>' +
				   '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Phone: 	{{info.phone}}</p>' +
		           '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Calificacion: 	{{info.rate.average}}</p>' +
				   '      		</md-list-item>' +
				   '      		<md-list-item>'+
				   '       			<p>Bloqueado: 	{{info.blocked}}</p>' +
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
           		info: UserDB
         	},
          	controller: function DialogController($scope, $mdDialog) {
            	$scope.closeDialog = function() {
              		$mdDialog.hide();
            	}
            	$scope.info = UserDB;
          	}
        });
	}
});
