package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;

public class RegistrarGrua extends AppCompatActivity {

    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        getSupportActionBar().hide();
        setContentView(R.layout.activity_registrar_grua);
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }


    public void enviarDatos(View view){

        InputMethodManager inputMethodManager = (InputMethodManager)
                getSystemService(this.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);

        Internet i = new Internet();
        final View v = view;
        String url = "https://api.mailgun.net/v3/gorilasapp.com.mx/messages";


        if(i.verificaConexion(this)) {
            final EditText nombre = (EditText) findViewById(R.id.txtNombrePersonalGrua);
            final EditText phone = (EditText) findViewById(R.id.txtCellphoneGrua);
            final EditText email = (EditText) findViewById(R.id.txtEmailGrua);
            final EditText description = (EditText) findViewById(R.id.txtDescripcionGrua);
            final EditText empresa = (EditText) findViewById(R.id.txtEmpresaGrua);
            final EditText ciudad = (EditText) findViewById(R.id.txtCiudadGrua);
            final EditText numGrua = (EditText) findViewById(R.id.txtNumGrua);

            if (validarEmail(email.getText().toString())) {

                final RequestParams params = new RequestParams();

                params.put("from", email.getText().toString());
                params.put("to", "operaciones@gorilasapp.com.mx");
                params.put("subject", "Solicitud de: " + nombre.getText().toString());
                params.put("text", "Nombre: " + nombre.getText().toString() + "\n\n" + "Correo: " + email.getText().toString() + "\n\n"
                        + "Mensaje: " + description.getText().toString() + "\n\n" + "Celular: " + phone.getText().toString() + "\n\n" + "Empresa: "
                        + empresa.getText().toString() + "\n\n" + "Ciudad: " + ciudad.getText().toString() + "\n\n" + "Número de Grúas: " + numGrua.getText().toString());


                Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.setBasicAuth("api", getString(R.string.keymailgun));
                client.post(context, url, params, new AsyncHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                        email.setText("");
                        email.setHint("Correo");
                        nombre.setText("");
                        nombre.setHint("Nombre");
                        phone.setText("");
                        phone.setHint("Celular");
                        description.setText("");
                        description.setHint("Descripcion");
                        Snackbar.make(v, "Solicitud enviada correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                        Snackbar.make(v, "La solicitud no se pudo enviar", Snackbar.LENGTH_LONG)
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
