package com.example.gargui3.gruasgorilas;

import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

public class DescripcionOrden extends AppCompatActivity {

    private SocketIO socket;
    private JSONObject orderActual;
    private TextView operador;
    private TextView cliente;
    private TextView origen;
    private TextView destino;
    private TextView auto;
    private String rol;
    private String token;
    private String ip;
    private String userID;
    private String phone;
    private boolean permisos;
    private boolean isClickOk = false;
    private boolean isClickCancel = false;
    private ProgressDialog pDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.userID = prefs.getString("idUsuario", "sinID");
        this.rol = prefs.getString("rol", "sinrol");
        this.token = prefs.getString("token", "sintoken");
        this.ip = getString(R.string.ipaddress);

        this.socket = SocketIO.getInstance();
        if (!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        } else {
            this.socket.setActivity(this);
        }
        this.orderActual = this.socket.getOrderActual();

        if (rol.equals("user")) {

            setContentView(R.layout.activity_descripcion_orden);

            this.operador = (TextView) findViewById(R.id.operadorNombre);
            this.origen = (TextView) findViewById(R.id.origenViaje);
            this.destino = (TextView) findViewById(R.id.destinoViaje);
            this.auto = (TextView) findViewById(R.id.automovil);

            try {
                JSONObject operadorJSON = this.orderActual.getJSONObject("operator_id");
                JSONObject origenJSON = this.orderActual.getJSONObject("origin");
                JSONObject destinoJSON = this.orderActual.getJSONObject("destiny");
                JSONObject carinfo = this.orderActual.getJSONObject("carinfo");
                String name = operadorJSON.getString("name");
                String origenDireccion = origenJSON.getString("denomination");
                String destinoDireccion = destinoJSON.getString("denomination");
                String car = carinfo.getString("model");
                this.operador.setText(name);
                this.origen.setText(origenDireccion);
                this.destino.setText(destinoDireccion);
                this.auto.setText(car);
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }else if(rol.equals("operator")) {
            setContentView(R.layout.activity_asignar_precio_operator);

            TextView cliente = (TextView) findViewById(R.id.clienteNombre);
            TextView origen = (TextView) findViewById(R.id.origenCliente);
            TextView destino = (TextView) findViewById(R.id.destinoCliente);
            TextView automovil = (TextView) findViewById(R.id.autoCliente);
            TextView condiciones = (TextView) findViewById(R.id.condicionesCliente);

            try {
                JSONObject orderActual = this.socket.getOrderActual();
                JSONObject operadorJSON = orderActual.getJSONObject("user_id");
                JSONObject origenJSON = orderActual.getJSONObject("origin");
                JSONObject destinoJSON = orderActual.getJSONObject("destiny");
                this.phone = operadorJSON.getString("phone");
                JSONObject autoJSON = orderActual.getJSONObject("carinfo");
                String name = operadorJSON.getString("name");
                String origenDireccion = origenJSON.getString("denomination");
                String destinoDireccion = destinoJSON.getString("denomination");
                String auto = autoJSON.getString("model");
                String condicionesAuto = orderActual.getString("conditions");

                cliente.setText(name);
                origen.setText(origenDireccion);
                destino.setText(destinoDireccion);
                automovil.setText(auto);
                condiciones.setText(condicionesAuto);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        pDialog.dismiss();
    }

    @Override
    public void onBackPressed() {

    }

    public void llamar(View view) {
        Intent sendIntent = new Intent(Intent.ACTION_CALL);
        sendIntent.setData(Uri.parse("tel:" + this.phone));
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        startActivity(sendIntent);
    }

    public void confirmarPrecioOperator(View v) {
        InputMethodManager inputMethodManager = (InputMethodManager)
                getSystemService(this.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        if(!isClickOk) {
            EditText editPrecio = (EditText) findViewById(R.id.precioViaje);
            if (!editPrecio.getText().toString().isEmpty()) {
                isClickOk = true;
                Double precio = Double.parseDouble(editPrecio.getText().toString());

                String order_id = null;
                try {
                    order_id = this.orderActual.getString("_id");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (order_id != null)
                    this.socket.confirmPrice(order_id, this.userID, precio);

            } else {
                Snackbar.make(v, getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }
    }

    public void cancelarOperatorPrecio(View v) {
        if(!isClickCancel) {
            isClickCancel = true;
            try {
                socket.cancelOrder(socket.getOrderActual().getString("_id"), userID);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            Intent i = new Intent(this, MainActivity.class);
            startActivity(i);
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
