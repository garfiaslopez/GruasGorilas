package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.telephony.TelephonyManager;
import android.view.View;
import android.widget.EditText;
import android.Manifest;
import android.widget.TextView;


import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;


import java.io.UnsupportedEncodingException;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class Login extends AppCompatActivity {

    private String ip;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        SharedPreferences prefs = getSharedPreferences("Datos", Context.MODE_PRIVATE);
        String token = prefs.getString("token", "sintoken");

        TextView txtOlvide = (TextView) findViewById(R.id.olvideContra);
        txtOlvide.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                olvideContra(v);
            }
        });

        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                Manifest.permission.CALL_PHONE)
                != PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {

            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.READ_CONTACTS) && ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.CALL_PHONE) && ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.READ_EXTERNAL_STORAGE)) {

                // Show an expanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.

            } else {

                // No explanation needed, we can request the permission.

                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.CALL_PHONE, Manifest.permission.READ_EXTERNAL_STORAGE},
                        3);


                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }

        }


        if(!token.equals("sintoken")){
            final Intent intent = new Intent(this, MainActivity.class);
            finish();
            startActivity(intent);
        }else{
            this.ip = getString(R.string.ipaddress);
        }

    }

    public void call(View v) {
        String telefono = getString(R.string.telefonoCentral);

        Intent sendIntent = new Intent(Intent.ACTION_CALL);
        sendIntent.setData(Uri.parse("tel:" + telefono));
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
    public void olvideContra(View view){
        Intent i = new Intent(this, RecuperarContrasena.class);
        startActivity(i);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    public void signup(View view) {
        Intent in = new Intent(this, Register.class);
        finish();
        startActivity(in);
    }

    public String getDeviceId() {
        String deviceId = "";
        final TelephonyManager mTelephony = (TelephonyManager) getSystemService(this.TELEPHONY_SERVICE);
        if (mTelephony.getDeviceId() != null) {
            deviceId = mTelephony.getDeviceId();
        } else {
            deviceId = Settings.Secure.getString(getApplicationContext()
                    .getContentResolver(), Settings.Secure.ANDROID_ID);
        }
        return deviceId;
    }

    public void signin(final View view) {

        Internet i = new Internet();

        if (i.verificaConexion(this)) {

            EditText email = (EditText) findViewById(R.id.txtLoginEmail);
            EditText password = (EditText) findViewById(R.id.txtLoginPassword);

            final Intent intent = new Intent(this, MainActivity.class);

            String deviceId = getDeviceId();

            final View v = view;
            final String correo = email.getText().toString();

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("email", email.getText().toString());
                params.put("password", password.getText().toString());
                params.put("uuid", deviceId);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            final Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.post(context, ip + "/authenticate", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    Boolean valor = null;
                    Object msj = null;
                    Object tkn = null;
                    JSONObject user = null;
                    try {
                        valor = response.getBoolean("success");
                        msj = response.get("message");
                        if (valor) {
                            tkn = response.get("token");
                            user = response.getJSONObject("user");
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                    // Do something with the response

                    if (valor) {
                        String idd = "";
                        String phone = "";
                        String rol = "";
                        String name = "";
                        try {
                            idd = user.getString("_id");
                            phone = user.getString("phone");
                            name = user.getString("name");
                            rol = user.getString("typeuser");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        SharedPreferences prefs = getSharedPreferences("Datos", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("token", tkn.toString());
                        editor.putString("nombreUsuario", name);
                        editor.putString("correoUsuario", correo);
                        editor.putString("telefonoUsuario", phone);
                        editor.putString("idUsuario", idd);
                        editor.putBoolean("switch", true);
                        editor.putBoolean("isRejected", false);
                        editor.putBoolean("isExpired", false);
                        editor.putBoolean("isAlreadyTaked", false);
                        editor.putString("rol", rol);
                        editor.commit();
                        finish();
                        startActivity(intent);

                    } else {
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });
        }else{
            Snackbar.make(view, getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

}
