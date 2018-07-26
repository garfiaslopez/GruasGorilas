package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.content.Intent;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class RecuperarContrasena extends AppCompatActivity {

    private String ip;
    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        getSupportActionBar().hide();
        setContentView(R.layout.activity_recuperar_contrasena);
        this.ip = getString(R.string.ipaddress);
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }

    public void olvideContraseñaEnviar(View view){
        InputMethodManager inputMethodManager = (InputMethodManager)
                getSystemService(this.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        Internet i = new Internet();
        final View v = view;

        if(i.verificaConexion(this)) {

            EditText email = (EditText) findViewById(R.id.correoRecuperar);

            final Intent intent = new Intent(this, Login.class);

            if (validarEmail(email.getText().toString())) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("email", email.getText().toString());
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.post(context, ip + "/forgotpassword", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        Boolean valor = null;
                        Object msj = null;
                        try {
                            valor = response.getBoolean("success");
                            msj = response.get("message");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }


                        // Do something with the response

                        if (valor == true) {
                            startActivity(intent);
                        } else {
                            Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                    .setAction("Action", null).show();
                        }

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        Snackbar.make(v, "No hay servicio por el momento, gracias", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }


                });

            } else {
                Snackbar.make(v, this.getString(R.string.correoInvalidoException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else{
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }
}
