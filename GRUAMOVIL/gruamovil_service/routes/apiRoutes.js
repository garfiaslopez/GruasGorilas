 'use strict'
//  Module dependencies.
var RedirectFunctions = require("../controllers/redirectController");
var AuthenticateFunctions = require("../controllers/authcontroller");
var UserFunctions = require("../controllers/usercontroller");
var UserAdminFunctions = require("../controllers/useradmincontroller");
var MiddleAuth = require('./../middlewares/auth');

var CouponFunctions = require("../controllers/couponcontroller");
var RouteExampleFunctions = require("../controllers/routeexamplecontroller");
var CarworkshopFunctions = require("../controllers/carworkshopController");
var ImageFunctions = require("../controllers/serveImageController");
var SubsidiaryFunctions = require("../controllers/subsidiaryController");
var NoticeFunctions = require("../controllers/noticeController");
var HelpFunctions = require("../controllers/helpController");
var OrderFunctions = require("../controllers/orderController");
var ConektaFunctions = require("../controllers/conektaController");
var ConnectionsFunctions = require("../controllers/connectionsController");
var GroupFunctions = require("../controllers/groupController");
var TowFunctions = require("../controllers/towController");
var CarFunctions = require("../controllers/carController");


module.exports = function(server) {

    //  Redirect request to controller
    server.get('/appstore',RedirectFunctions.redirectToAppstore);

    server.post('/authenticate',AuthenticateFunctions.AuthByUser);
    server.post('/authenticate/admin',AuthenticateFunctions.AuthByUserAdmin);
    server.post('/authenticate/logoutuser',AuthenticateFunctions.LogOutUser);

    server.post('/user',UserFunctions.Create);

    server.get('/images/:carworkshop/:filename',ImageFunctions.Get);

    server.post('/profile/images/:user_id',ImageFunctions.UploadProfileImage);
    server.get('/profile/images/:user_id',ImageFunctions.GetProfileImage);

    server.post('/forgotpassword',UserFunctions.ForgotPassword);
    server.get('/validate/:email/:token',UserFunctions.ValidateEmail);

    //the routes put before the middleware does not is watched.
    server.use(MiddleAuth.AuthToken);

    server.get('/user',UserFunctions.All);
    server.get('/user/:user_id',UserFunctions.ById);
    server.get('/user/by/group/:group_id',UserFunctions.ByGroup);
    server.get('/user/by/users',UserFunctions.AllUsers);
    server.get('/user/by/vendors',UserFunctions.AllVendors);
    server.get('/user/by/availablevendors',UserFunctions.AllAvailableVendors);
    server.put('/user/:user_id',UserFunctions.UpdateById);
    server.del('/user/:user_id',UserFunctions.DeleteById);
    server.post('/rateuser',UserFunctions.RateUserById);
    server.post('/blockuser',UserFunctions.BlockUser);
    server.post('/availableoperator',UserFunctions.AvailableOperator);

    server.get('/users/byavailable',UserFunctions.SearchByAvailable);
    server.get('/users/byvendors/bylocation/:lat/:long',UserFunctions.SearchVendorsByLoc);
    server.get('/users/byavailablevendors/bylocation/:lat/:long',UserFunctions.SearchVendorsByStatus);

    server.post('/conekta/card',ConektaFunctions.CreateCard);
    server.get('/conekta/cards/:user_id',ConektaFunctions.AllCardsByUser);
    server.del('/conekta/card/:user_id/:card_id',ConektaFunctions.DelCardByUser);
    server.del('/conekta/user/:user_id/',ConektaFunctions.DelUser);

    server.post('/useradmin',UserAdminFunctions.AddNewUserAdmin);
    server.get('/useradmin',UserAdminFunctions.AllUsersAdmin);
    server.put('/useradmin/:useradmin_id',UserAdminFunctions.UpdateUserAdminById);
    server.del('/useradmin/:useradmin_id',UserAdminFunctions.DeleteUserAdminById);

    server.post('/coupon',CouponFunctions.Create);
    server.get('/coupon',CouponFunctions.All);
    server.get('/coupon/:coupon_id',CouponFunctions.ById);
    server.put('/coupon/:coupon_id',CouponFunctions.UpdateById);
    server.del('/coupon/:coupon_id',CouponFunctions.DeleteById);
    server.post('/coupon/apply',CouponFunctions.Apply);

    server.post('/routeexample',RouteExampleFunctions.Create);
    server.get('/routeexample',RouteExampleFunctions.All);
    server.get('/routeexample/:route_id',RouteExampleFunctions.ById);
    server.put('/routeexample/:route_id',RouteExampleFunctions.UpdateById);
    server.del('/routeexample/:route_id',RouteExampleFunctions.DeleteById);


    server.post('/carworkshop',CarworkshopFunctions.Create);
    server.get('/carworkshop',CarworkshopFunctions.All);
    server.get('/carworkshop/:carworkshop_id',CarworkshopFunctions.ById);
    server.put('/carworkshop/:carworkshop_id',CarworkshopFunctions.UpdateById);
    server.del('/carworkshop/:carworkshop_id',CarworkshopFunctions.DeleteById);
    server.get('/carworkshop/by/type/:type',CarworkshopFunctions.ByType);

    server.post('/subsidiary',SubsidiaryFunctions.Create);
    server.get('/subsidiary',SubsidiaryFunctions.All);
    server.get('/subsidiary/:subsidiary_id',SubsidiaryFunctions.ById);
    server.put('/subsidiary/:subsidiary_id',SubsidiaryFunctions.UpdateById);
    server.del('/subsidiary/:subsidiary_id',SubsidiaryFunctions.DeleteById);

    server.post('/notice',NoticeFunctions.Create);
    server.get('/notice',NoticeFunctions.All);
    server.get('/notice/:notice_id',NoticeFunctions.ById);
    server.put('/notice/:notice_id',NoticeFunctions.UpdateById);
    server.del('/notice/:notice_id',NoticeFunctions.DeleteById);

    server.post('/help',HelpFunctions.Create);
    server.get('/help',HelpFunctions.All);
    server.get('/help/:help_id',HelpFunctions.ById);
    server.put('/help/:help_id',HelpFunctions.UpdateById);
    server.del('/help/:help_id',HelpFunctions.DeleteById);

    server.post('/order',OrderFunctions.Create);
    server.get('/order',OrderFunctions.All);
    server.get('/order/:order_id',OrderFunctions.ById);
    server.put('/order/:order_id',OrderFunctions.UpdateById);
    server.del('/order/:order_id',OrderFunctions.DeleteById);

    server.get('/orders/LastByUser/:user_id',OrderFunctions.LastByUser);
    server.get('/orders/lastQuotationByUser/:user_id',OrderFunctions.LastQuotationByUser);
    server.get('/orders/schedulesByUser/:user_id',OrderFunctions.SchedulesByUser);
    server.post('/orders/byFilters',OrderFunctions.Filter);

    server.post('/connection',ConnectionsFunctions.Create);
    server.get('/connection',ConnectionsFunctions.All);
    server.get('/connections/:operator_id',ConnectionsFunctions.AllByOperator);
    server.get('/connection/:connection_id',ConnectionsFunctions.ById);
    server.put('/connection/:connection_id',ConnectionsFunctions.UpdateById);
    server.del('/connection/:connection_id',ConnectionsFunctions.DeleteById);
    server.put('/connectionclose/:operator_id',ConnectionsFunctions.CloseConnection);


    server.post('/group',GroupFunctions.Create);
    server.get('/group',GroupFunctions.All);
    server.put('/group/:group_id',GroupFunctions.UpdateById);
    server.del('/group/:group_id',GroupFunctions.DeleteById);


    server.post('/tow',TowFunctions.Create);
    server.get('/tow',TowFunctions.All);
    server.get('/tow/bygroup/:group_id',TowFunctions.ByGroup);
    server.put('/tow/:tow_id',TowFunctions.UpdateById);
    server.del('/tow/:tow_id',TowFunctions.DeleteById);

    server.post('/car',CarFunctions.Create);
    server.get('/car',CarFunctions.All);
    server.put('/car/:car_id',CarFunctions.UpdateById);
    server.del('/car/:car_id',CarFunctions.DeleteById);
    server.get('/cars/:user_id',CarFunctions.ByUser);

};
