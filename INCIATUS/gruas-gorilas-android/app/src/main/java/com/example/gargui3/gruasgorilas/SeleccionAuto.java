package com.example.gargui3.gruasgorilas;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import Adapters.AdaptadorAutos;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import modelo.Vehiculo;

public class SeleccionAuto extends AppCompatActivity {

    private ListView lstVehiculos;
    private JSONArray vehiculos;
    private String correo;
    private String user_id;
    private String token;
    private String ip;
    private ProgressDialog pDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_seleccion_auto);
        lstVehiculos = (ListView) findViewById(R.id.lstAutos);
        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        correo = prefs.getString("correoUsuario", "sincorreo");
        user_id = prefs.getString("idUsuario", "sinid");
        token = prefs.getString("token", "sintoken");
        ip = getString(R.string.ipaddress);
        obtenerVehiculos();
    }

    public void createList(JSONArray response){

        vehiculos = response;

        Vehiculo[] datos =
                new Vehiculo[response.length()];

        for(int i=0; i<response.length(); i++){
            Vehiculo v = new Vehiculo();
            try {
                JSONObject obj = response.getJSONObject(i);
                v.setMarca(obj.getString("brand"));
                v.setModelo(obj.getString("model"));
                v.setColor(obj.getString("color"));
                v.setPlacas(obj.getString("plates"));
            } catch (JSONException e) {
                e.printStackTrace();
            }
            datos[i] = v;
        }

        AdaptadorAutos adaptador = new AdaptadorAutos(this, datos);

        lstVehiculos.setAdapter(adaptador);

        lstVehiculos.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                try {
                    JSONObject v = vehiculos.getJSONObject(position);
                    String auto = v.getString("brand") + " " + v.getString("model") + " - " + v.getString("plates");
                    Intent intent = getIntent();
                    intent.putExtra("auto", auto);
                    setResult(RESULT_OK, intent);
                    finish();
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });

        pDialog.dismiss();

    }

    public void nuevoVehiculo(final View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        // Get the layout inflater
        LayoutInflater inflater = this.getLayoutInflater();

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        builder.setView(inflater.inflate(R.layout.dialog_nuevo_vehiculo, null))
                // Add action buttons
                .setPositiveButton(R.string.btnAgregar, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        guardarVehiculo(view, dialog);
                    }
                })
                .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                    }
                });

        AlertDialog d = builder.create();

        d.show();

        d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(this, R.color.colorPrimaryYellow));

        d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(this, R.color.colorPrimaryYellow));

    }

    public void guardarVehiculo(final View view, final DialogInterface d){

        Dialog dialog = (Dialog) d;

        EditText txtMarca = (EditText) dialog.findViewById(R.id.txtMarcaVehiculoNuevo);
        EditText txtModelo = (EditText) dialog.findViewById(R.id.txtModeloVehiculoNuevo);
        EditText txtPlacas = (EditText) dialog.findViewById(R.id.txtPlacasVehiculoNuevo);
        EditText txtColor = (EditText) dialog.findViewById(R.id.txtColorVehiculoNuevo);

        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            if (!txtMarca.getText().toString().equals("") && !txtModelo.getText().toString().equals("") && !txtPlacas.getText().toString().equals("") && !txtPlacas.getText().toString().equals("")) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("user_id", user_id);
                    params.put("brand", txtMarca.getText().toString());
                    params.put("plates", txtPlacas.getText().toString());
                    params.put("model", txtModelo.getText().toString());
                    params.put("color", txtColor.getText().toString());
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this;

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", this.token);
                client.post(context, ip + "/car", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        d.dismiss();
                        Snackbar.make(view, getString(R.string.guardadoCorrectamente), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                        obtenerVehiculos();

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        d.dismiss();
                        Snackbar.make(view, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                });

            } else {
                d.dismiss();
                Snackbar.make(view, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else{
            d.dismiss();
            Snackbar.make(view, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void obtenerVehiculos(){

        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            Context context = this;

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/cars/" + user_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    try {
                        createList(response.getJSONArray("cars"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }

            });

        }else{

        }

    }


}
