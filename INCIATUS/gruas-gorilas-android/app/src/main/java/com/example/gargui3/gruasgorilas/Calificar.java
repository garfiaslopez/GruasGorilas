package com.example.gargui3.gruasgorilas;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.DataAsyncHttpResponseHandler;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class Calificar extends AppCompatActivity {

    private SocketIO socket;
    private JSONObject orderActual;
    private String rol;
    private String order_id;
    private String user_id;
    private String token;
    private String ip;
    private Activity activity;
    private boolean isClickOk = false;
    private ImageView img;
    private ProgressDialog pDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.orderActual = this.socket.getOrderActual();

        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");
        this.token = prefs.getString("token", "sintoken");

        this.ip = this.getString(R.string.ipaddress);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_calificar);

        img = (ImageView) findViewById(R.id.profileFinal);

        this.activity = this;

        TextView txtUsuario = (TextView) findViewById(R.id.nombreUsuarioCalificar);
        TextView txtTipo = (TextView) findViewById(R.id.calificaUsuario);

        String name = "";

        if (this.rol.equals("user")){
            txtTipo.setText(getString(R.string.calificaRepartidor));
            try {
                order_id = orderActual.getString("_id");
                JSONObject vendor = orderActual.getJSONObject("operator_id");
                user_id = vendor.getString("_id");
                name = vendor.getString("name");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }else if(this.rol.equals("operator")) {
            txtTipo.setText("Califica a tu cliente");
            try {
                order_id = orderActual.getString("_id");
                JSONObject user = orderActual.getJSONObject("user_id");
                user_id = user.getString("_id");
                name = user.getString("name");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        cargarFoto();

        Boolean isPaid = true;
        String paymethod = "";
        try {
            isPaid = this.orderActual.getBoolean("isPaid");
            paymethod = this.orderActual.getString("paymethod");
        } catch (JSONException e) {
            e.printStackTrace();
        }


        if(paymethod.equals("CASH")) {
            new AlertDialog.Builder(this)
                    .setTitle("Pago procesado")
                    .setMessage(this.getString(R.string.cashMethod))
                    .setIcon(android.R.drawable.stat_notify_error)
                    .setPositiveButton("OK", null).show();
        } else if(!isPaid) {
            new AlertDialog.Builder(this)
                    .setTitle("Erro al procesar el pago")
                    .setMessage(this.getString(R.string.notPaidAcceptedException))
                    .setIcon(android.R.drawable.stat_notify_error)
                    .setPositiveButton("OK", null).show();
        } else {
            new AlertDialog.Builder(this)
                    .setTitle("Pago procesado")
                    .setMessage("Pago procesado correctamente")
                    .setIcon(android.R.drawable.stat_notify_more)
                    .setPositiveButton("OK", null).show();
        }

        txtUsuario.setText(name);

    }

    public void cargarFoto(){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            final Context context = this;

            String ip = getString(R.string.ipaddress);

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/profile/images/" + user_id, new DataAsyncHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                    if(responseBody != null) Glide.with(context).load(responseBody).into(img);
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {

                }

            });

        }
        pDialog.dismiss();
    }

    @Override
    public void onBackPressed() {

    }

    public void calificarUsuario(int calificacion, View v){

        if(!isClickOk) {
            isClickOk = true;

            Internet i = new Internet();

            SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString("isCalifico", "true");
            editor.commit();

            if (i.verificaConexion(this)) {

                pDialog = new ProgressDialog(this);
                pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                pDialog.setMessage("Cargando...");
                pDialog.setCancelable(false);
                pDialog.setMax(100);
                pDialog.show();


                StringEntity entity = null;
                JSONObject calf = new JSONObject();
                try {
                    calf.put("user_id", user_id);
                    calf.put("rate", calificacion);
                    entity = new StringEntity(calf.toString());
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                final Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", token);
                client.post(context, ip + "/rateuser", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        SharedPreferences prefs = getSharedPreferences("Datos", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("isCalifico", "true");
                        editor.commit();
                        pDialog.dismiss();

                        socket.ratedUser(order_id, user_id);

                        Intent i = new Intent(activity, MainActivity.class);
                        i.putExtra("dontBack", true);
                        finish();
                        startActivity(i);

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        pDialog.dismiss();
                    }


                });
            } else {
                Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }

    }

    public void uno(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.ic_action_star_0);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.ic_action_star_10);

        calificarUsuario(1, view);

    }

    public void dos(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.ic_action_star_0);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.ic_action_star_10);

        calificarUsuario(2, view);

    }

    public void tres(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.ic_action_star_0);



        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.ic_action_star_10);

        calificarUsuario(3, view);

    }

    public void cuatro(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.ic_action_star_0);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img4 = (ImageView) findViewById(R.id.cuatro);
        img4.setImageResource(R.mipmap.ic_action_star_10);

        calificarUsuario(4, view);

    }

    public void cinco(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.ic_action_star_0);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.ic_action_star_0);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img4 = (ImageView) findViewById(R.id.cuatro);
        img4.setImageResource(R.mipmap.ic_action_star_10);
        ImageView img5 = (ImageView) findViewById(R.id.cinco);
        img5.setImageResource(R.mipmap.ic_action_star_10);

        calificarUsuario(5, view);

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
