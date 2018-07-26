package com.example.gargui3.gruasgorilas;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.net.URISyntaxException;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

/**
 * Created by gargui3 on 8/10/16.
 */
public class SocketIO implements Serializable {

    private static SocketIO INSTANCE = null;

    private Socket socket;
    private Activity activity;
    private JSONObject orderActual;
    private static Boolean activo = false;
    private Boolean firstOpen = true;
    private Boolean isEnded = false;
    private static ProgressDialog pDialog = null;
    private boolean isQuoted = false;
    private boolean isSchedule = false;

    public JSONObject getOrderActual() {
        return orderActual;
    }

    public void setOrderActual(JSONObject orderActual) {
        this.orderActual = orderActual;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public Activity getActivity() {
        return activity;
    }

    public void setActivity(Activity activity) {
        pDialog = new ProgressDialog(activity);
        this.activity = activity;
    }

    public boolean isQuoted() {
        return isQuoted;
    }

    public void setQuoted(boolean quoted) {
        isQuoted = quoted;
    }

    private synchronized static void createInstance() {
        if (INSTANCE == null) {
            INSTANCE = new SocketIO();
        }
    }

    public boolean isSchedule() {
        return isSchedule;
    }

    public void setSchedule(boolean schedule) {
        isSchedule = schedule;
    }

    public static SocketIO getInstance(){
        if(INSTANCE == null) createInstance();
        return INSTANCE;
    }

    public void conectar(String ipaddress){
        this.firstOpen = true;
        if(socket == null) {
            try {
                this.socket = IO.socket(ipaddress);
            } catch (URISyntaxException e) {
            }

            metodosON();
            socket.connect();

        }else {
            if (!socket.connected()) {

                try {
                    this.socket = IO.socket(ipaddress);
                } catch (URISyntaxException e) {
                }

                metodosON();
                socket.connect();

            }
        }
    }

    public void isEnded(){
        this.isEnded = true;
        this.socket.disconnect();
    }

    public void inicializar(String ipaddress, Activity activity) {

        setActivity(activity);
        this.activo = true;
        this.firstOpen = true;

        if(socket == null) {
            try {
                this.socket = IO.socket(ipaddress);
            } catch (URISyntaxException e) {
            }

            metodosON();
            socket.connect();

        }else {
            if (!socket.connected()) {


                try {
                    this.socket = IO.socket(ipaddress);
                } catch (URISyntaxException e) {
                }

                metodosON();
                socket.connect();

            }
        }

    }

    public void metodosON(){

        socket.on("HowYouAre", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                usuarioConectado();
            }

        });

        socket.on("ExpiredSession", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                desconectarUsuario();
            }

        });

        socket.on("UpdateOrder", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                JSONObject order = (JSONObject) args[0];
                try {
                    if(order != null) {
                        orderActual = order;
                        String status = order.getString("status");
                        switchView(status);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

        });

    }

    public void desconectarUsuario(){
        SharedPreferences prefs = activity.getApplication().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("token", "sintoken");
        editor.commit();
        isEnded();
        Intent i = new Intent(activity, Login.class);
        activity.finish();
        activity.startActivity(i);
    }

    public void switchView(String status){
        pDialog.dismiss();
        if(status.equals("Searching")){
            firstOpen = false;
            Intent intent = new Intent(activity, Buscando.class);
            activity.finish();
            intent.putExtra("ordenID", "sinorden");
            activity.startActivity(intent);
        }else if(status.equals("Accepted")) {
            activity.finish();
            Intent intent = new Intent(activity, DescripcionOrden.class);
            activity.startActivity(intent);
        }else if(status.equals("Confirmed")) {
            activity.finish();
            Intent intent = new Intent(activity, DescripcionServicio.class);
            activity.startActivity(intent);
        }else if(status.equals("Arriving")) {
            SharedPreferences prefs = activity.getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isAccepted", true);
            editor.putBoolean("isRejected", false);
            editor.putBoolean("isExpired", false);
            editor.putBoolean("isAlreadyTaked", false);
            editor.commit();
            activity.finish();
            Intent intent = new Intent(activity, ArrivingOrder.class);
            activity.startActivity(intent);
        }else if(status.equals("Transporting")) {
            activity.finish();
            Intent intent = new Intent(activity, TransportingOrder.class);
            activity.startActivity(intent);
        }else if(status.equals("Delivered")){
            SharedPreferences prefs = activity.getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString("isCalifico", "false");
            editor.commit();
            activity.finish();
            Intent intent = new Intent(activity, Calificar.class);
            activity.startActivity(intent);
        }else if(status.equals("Normal")){
            if(!firstOpen) {
                firstOpen = true;
                activity.finish();
                Intent intent = new Intent(activity, MainActivity.class);
                activity.startActivity(intent);
            }
        }else if(status.equals("Rejected")){
            SharedPreferences prefs = activity.getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isRejected", true);
            editor.commit();
            if(!firstOpen)
                activity.finish();
            Intent intent = new Intent(activity, MainActivity.class);
            activity.startActivity(intent);
        }else if(status.equals("Expired")){
            SharedPreferences prefs = activity.getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isExpired", true);
            editor.commit();
            if(!firstOpen)
                activity.finish();
            Intent intent = new Intent(activity, MainActivity.class);
            activity.startActivity(intent);
        }else if(status.equals("AlreadyTaked")){
            SharedPreferences prefs = activity.getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isAlreadyTaked", true);
            editor.commit();
            if(!firstOpen)
                activity.finish();
            Intent intent = new Intent(activity, MainActivity.class);
            activity.startActivity(intent);
        }else if(status.equals("NotAccepted")){
            SharedPreferences prefs = activity.getApplication().getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isAccepted", false);
            editor.commit();
            if(!firstOpen)
                activity.finish();
            Intent intent = new Intent(activity, MainActivity.class);
            activity.startActivity(intent);
        }else if(status.equals("Canceled")){
            SharedPreferences prefs = activity.getApplication().getSharedPreferences("Datos",Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isAccepted", false);
            editor.commit();
            if(!firstOpen)
                activity.finish();
            Intent intent = new Intent(activity, MainActivity.class);
            activity.startActivity(intent);
        }
    }

    public void usuarioConectado() {

        SharedPreferences prefs = activity.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        String id = prefs.getString("idUsuario", "sinID");
        String rol = prefs.getString("rol", "sinrol");
        String correo = prefs.getString("correoUsuario", "sincorreo");


        JSONObject datos = new JSONObject();
        try {
            datos.put("user_id", id);
            datos.put("email", correo);
            datos.put("typeuser", rol);
            datos.put("device", "Android");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("ConnectedUser", datos);

    }

    public void searchForVendor(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("SearchForVendor", order);
    }

    public void acceptOrder(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("AcceptOrder", order);
    }

    public void cancelOrder(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("CancelOrder", order);
    }

    public void rejectOrder(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("RejectOrder", order);
    }

    public void confirmPrice(String order_id, String user_id, double total) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
            order.put("total", total);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("ConfirmPrice", order);
    }

    public void acceptPayOrder(String order_id, String user_id, String paymethod, String cardForPayment) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
            order.put("paymethod", paymethod);
            order.put("cardForPayment", cardForPayment);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("AcceptPayOrder", order);
    }

    public void toDestiny(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("ToDestiny", order);
    }

    public void endTravel(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("EndTravel", order);
    }

    public void endQuotation(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        isQuoted = true;

        socket.emit("EndQuotation", order);
    }

    public void scheduleOrder(String order_id, String user_id) {
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        isSchedule = true;

        socket.emit("ScheduleOrder", order);
    }

    public void ratedUser(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("RatedUser", order);
    }

}

