var app = angular.module('LoginApp',['ngMaterial','AuthService']);


app.config(function($mdIconProvider){

    $mdIconProvider
      .icon("pass", "../public/images/icons/locked57.svg"        , 24)
      .icon("user", "../public/images/icons/account4.svg"    , 24)
      .icon("userlogin", "../public/images/icons/account4.svg"    , 120);


});


app.controller('LoginController',function($scope,$mdDialog,Auth){

	$scope.doLogin = function(loginData) {

		console.log("LoginData: " + loginData);
        Auth.LoginAdmin(loginData.username, loginData.password)

     		.success(function(data) {

     			console.log(data);

     			if(data.success){

                    window.location = '/Dashboard';




     			}else{

	     			$mdDialog.show(
					      $mdDialog.alert()
					        .parent(angular.element(document.body))
					        .title('Error Al Iniciar Sesion.')
					        .content(data.message)
					        .ariaLabel('Alert Dialog Demo')
					        .ok('OK')
				    );
     			}
       		})
       		.error(function(data){

        		$mdDialog.show(
				      $mdDialog.alert()
				        .parent(angular.element(document.body))
				        .title('Error Al Iniciar Sesion.')
				        .content(data.message)
				        .ariaLabel('Alert Dialog Demo')
				        .ok('OK')
			    );
       		});
   	};


});
