package com.example.gargui3.gruasgorilas;

import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.loopj.android.http.*;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import Elements.DatePickerFragment;
import Elements.TimePickerFragment;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import modelo.Condicion;
import modelo.Fecha;

public class SeleccionPedido extends AppCompatActivity {

    private TextView seleccionarAuto;
    private TextView seleccionarCondicion;
    private String origen;
    private String destino;
    private double latO;
    private double lngO;
    private double latD;
    private double lngD;
    private String auto = null;
    private Condicion c = null;

    private String userID;
    private String ip;
    private String token;
    private SocketIO socket;
    private String rol;
    private ProgressDialog pDialog;
    private boolean cotizar;
    private boolean reservar;

    private Fecha fechaCotizacion = new Fecha();

    public Fecha getFechaCotizacion() {
        return fechaCotizacion;
    }

    public void setFechaCotizacion(Fecha fechaCotizacion) {
        this.fechaCotizacion = fechaCotizacion;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        setContentView(R.layout.activity_seleccion_pedido);

        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.userID = prefs.getString("idUsuario", "sinID");
        this.token = prefs.getString("token", "sintoken");
        this.rol = prefs.getString("rol", "sinrol");
        this.ip = getString(R.string.ipaddress);

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }

        if(this.rol.equals("user")) {
            this.seleccionarAuto = (TextView) findViewById(R.id.seleccionarAuto);
            this.seleccionarCondicion = (TextView) findViewById(R.id.seleccionarCondicion);
            TextView txtOrigen = (TextView) findViewById(R.id.origen);
            TextView txtDestino = (TextView) findViewById(R.id.destino);
            Intent intent = getIntent();
            this.origen = intent.getStringExtra("direccionO");
            this.destino = intent.getStringExtra("direccionD");
            this.latO = intent.getDoubleExtra("latO", 0.0);
            this.lngO = intent.getDoubleExtra("lngO", 0.0);
            this.latD = intent.getDoubleExtra("latD", 0.0);
            this.lngD = intent.getDoubleExtra("lngD", 0.0);
            this.cotizar = intent.getBooleanExtra("cotizar", true);
            txtOrigen.setText(origen);
            txtDestino.setText(destino);

            TabHost tabs=(TabHost)findViewById(R.id.tabModoPago);
            tabs.setup();

            TabHost.TabSpec spec=tabs.newTabSpec("ahora");
            spec.setContent(R.id.ahora);
            spec.setIndicator("Ahora");
            tabs.addTab(spec);

            spec = tabs.newTabSpec("despues");
            spec.setContent(R.id.despues);
            spec.setIndicator("Para Después");
            tabs.addTab(spec);

            final SeleccionPedido s = this;

            final TextView btnOk = (TextView) findViewById(R.id.btnSiguiente);

            if (cotizar){
                btnOk.setText(getString(R.string.btnCotizacionPedido));
            }

            tabs.setCurrentTab(0);
            tabs.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
                @Override
                public void onTabChanged(String tabId) {
                    if(cotizar) {
                        if (tabId.equals("despues")) {
                            DatePickerFragment newFragment = new DatePickerFragment();
                            newFragment.setS(s);
                            newFragment.show(getSupportFragmentManager(), "datePicker");
                            reservar = true;
                        }else{
                            reservar = false;
                        }
                    }else{
                        if (tabId.equals("despues")) {
                            DatePickerFragment newFragment = new DatePickerFragment();
                            newFragment.setS(s);
                            newFragment.show(getSupportFragmentManager(), "datePicker");
                            btnOk.setText(getString(R.string.btnReservacion));
                            reservar = true;
                        } else {
                            btnOk.setText(getString(R.string.continuarPedido));
                            reservar = false;
                        }
                    }
                }
            });

        }
        pDialog.dismiss();
    }

    public void setTime(){
        SeleccionPedido s = this;
        TimePickerFragment newFragment = new TimePickerFragment();
        newFragment.setF(fechaCotizacion);
        newFragment.setS(s);
        newFragment.show(getSupportFragmentManager(), "timePicker");
    }

    public void showDate(){
        TextView txtFecha = (TextView) findViewById(R.id.fechaCotizacion);
        txtFecha.setText(fechaCotizacion.getDayofmonth() + "/" + fechaCotizacion.getMonth() + "/"
                        + fechaCotizacion.getYear() + "   " + fechaCotizacion.getHour() + ":"
                        + fechaCotizacion.getMinute() + " hrs");
    }

    public void seleccionarAuto(View v){
        Intent intent = new Intent(this, SeleccionAuto.class);
        startActivityForResult(intent, 2);
    }

    public void seleccionarCondicion(View v){
        Intent intent = new Intent(this, Condiciones.class);
        startActivityForResult(intent, 2);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (RESULT_OK == resultCode) {
            auto = data.getStringExtra("auto");
            seleccionarAuto.setText(auto);
        } else if (RESULT_FIRST_USER == resultCode) {
            c = (Condicion) data.getSerializableExtra("condicion");
            seleccionarCondicion.setText(c.getEstado());
        }
    }

    public void solicitar(View v) {
        if(auto!=null) {
            crearOrden();
        } else {
            Toast.makeText(this, getString(R.string.seleccionarEstadosException), Toast.LENGTH_LONG).show();
        }
    }

    public void crearOrden(){
        JSONObject order = new JSONObject();
        JSONObject carinfo = new JSONObject();
        JSONObject origenJSON = new JSONObject();
        JSONObject destinoJSON = new JSONObject();
        String condiciones = "";

        if(c!=null) {
            condiciones = c.getEstado();

            if (c.isRuedasGiran()) {
                condiciones += " - Ruedas Giran";
            }

            if (c.isFallaMotor()) {
                condiciones += " - Falla Motor";
            }

            if (c.isSinLlaves()) {
                condiciones += " - Sin Llaves";
            }

            if (c.isSinRuedas()) {
                condiciones += " - Sin Ruedas";
            }

        }else{
            condiciones = "No especificado";
        }
        try {
            //Info vehiculo
            carinfo.put("model", this.auto);

            //Info origen
            JSONArray cordO = new JSONArray();
            cordO.put(this.lngO);
            cordO.put(this.latO);
            origenJSON.put("denomination", this.origen);
            origenJSON.put("cord", cordO);

            //Info destino
            JSONArray cordD = new JSONArray();
            cordD.put(this.lngD);
            cordD.put(this.latD);
            destinoJSON.put("denomination", this.destino);
            destinoJSON.put("cord", cordD);

            //Info Orden
            order.put("user_id", this.userID);
            order.put("carinfo", carinfo);
            order.put("origin", origenJSON);
            order.put("destiny", destinoJSON);
            order.put("conditions", condiciones);

            String mes="";
            String dia="";
            String hora="";
            String minuto = "";

            if(fechaCotizacion.getMonth()<10){
                mes = "0" + fechaCotizacion.getMonth();
            }else{
                mes = "" + fechaCotizacion.getMonth();
            }

            if(fechaCotizacion.getDayofmonth()<10){
                dia = "0" + fechaCotizacion.getDayofmonth();
            }else{
                dia = "" + fechaCotizacion.getDayofmonth();
            }

            if (fechaCotizacion.getHour()<10){
                hora = "0" + fechaCotizacion.getHour();
            }else{
                hora = "" + fechaCotizacion.getHour();
            }

            if (fechaCotizacion.getMinute()<10){
                minuto = "0" + fechaCotizacion.getMinute();
            }else{
                minuto = "" + fechaCotizacion.getMinute();
            }

            String txtFecha = fechaCotizacion.getYear() + "-" + mes + "-" + dia
                    + "T" + hora + ":" + minuto + ":00.000Z";

            if(cotizar){
                order.put("isQuotation", true);
                if(reservar){
                    order.put("isSchedule", true);
                    order.put("dateSchedule", txtFecha);
                }
            }else{
                if(reservar){
                    order.put("isSchedule", true);
                    order.put("dateSchedule", txtFecha);
                }
            }


        } catch (JSONException e) {
            e.printStackTrace();
        }

        sendOrder(order);

    }

    public void sendOrder(JSONObject order){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {


            StringEntity entity = null;
            try {
                entity = new StringEntity(order.toString());
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/order", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject order;
                    try {
                        order = response.getJSONObject("order");
                        String order_id = order.getString("_id");
                        socket.searchForVendor(order_id, userID);
                        finish();

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }


            });
        } else {
            Toast.makeText(this, this.getString(R.string.sinConexionException), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public boolean isForeground(Context context,String appPackageName) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
        if (appProcesses == null) {
            return false;
        }
        final String packageName = appPackageName;
        for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName.equals(packageName)) {
                //                Log.e("app",appPackageName);
                return true;
            }
        }
        return false;
    }

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
        String appID = com.example.gargui3.gruasgorilas.BuildConfig.APPLICATION_ID.toString();
        if(!isForeground(this, appID))
            this.socket.isEnded();
    }

}
