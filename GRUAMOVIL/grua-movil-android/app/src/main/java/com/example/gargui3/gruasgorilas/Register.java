package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.provider.Settings;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.telephony.TelephonyManager;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class Register extends AppCompatActivity {

    private String ip;

    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        TextView txtTerminos = (TextView) findViewById(R.id.terminos);
        final Intent i = new Intent(this, Terminos.class);
        assert txtTerminos != null;
        txtTerminos.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(i);
            }
        });
        this.ip = getString(R.string.ipaddress);
    }

    public void abrirRegistrarGrua(View view){
        Intent i = new Intent(this, RegistrarGrua.class);
        startActivity(i);
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }

    @Override
    public void onBackPressed(){
        Intent i = new Intent(this, Login.class);
        finish();
        startActivity(i);
    }

    public void signin(String email, String password, View view) {

        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            final Intent intent = new Intent(this, MainActivity.class);

            String deviceId = getDeviceId();

            final View v = view;
            final String correo = email;

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("email", email);
                params.put("password", password);
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
                        try {
                            idd = user.getString("_id");
                            phone = user.getString("phone");
                            rol = user.getString("typeuser");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        SharedPreferences prefs = getSharedPreferences("Datos", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("token", tkn.toString());
                        editor.putString("nombreUsuario", "Usuario");
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

    public void signup(View view){

        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            InputMethodManager inputMethodManager = (InputMethodManager)
                    getSystemService(this.INPUT_METHOD_SERVICE);
            inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);

            EditText cellphone = (EditText) findViewById(R.id.txtCellphone);
            EditText email = (EditText) findViewById(R.id.txtEmail);
            EditText password = (EditText) findViewById(R.id.txtPassword);
            EditText nombre = (EditText) findViewById(R.id.txtNombrePersonal);

            final View v = view;

            if (validarEmail(email.getText().toString())) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("name", nombre.getText().toString());
                    params.put("email", email.getText().toString());
                    params.put("password", password.getText().toString());
                    params.put("phone", cellphone.getText().toString());
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                final String correo = email.getText().toString();
                final String pass = password.getText().toString();

                Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.post(context, ip + "/user", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        boolean valor = false;
                        Object msj = null;
                        try {
                            valor = response.getBoolean("success");
                            msj = response.get("message");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }


                        // Do something with the response

                        if (valor) {
                            signin(correo, pass, v);
                        } else {
                            Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                    .setAction("Action", null).show();
                        }

                    }

                });
            } else {
                Snackbar.make(v, getString(R.string.correoInvalidoException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else{
            Snackbar.make(view, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

}
