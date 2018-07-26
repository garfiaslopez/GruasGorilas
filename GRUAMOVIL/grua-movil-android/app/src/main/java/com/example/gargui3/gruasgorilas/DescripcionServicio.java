package com.example.gargui3.gruasgorilas;

import android.app.Activity;
import android.app.ActivityManager;
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
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TabHost;
import android.widget.TextView;
import android.widget.Toast;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import Adapters.AdaptadorTarjetas;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import io.conekta.conektasdk.Card;
import io.conekta.conektasdk.Conekta;
import io.conekta.conektasdk.Token;
import modelo.Tarjeta;

public class DescripcionServicio extends AppCompatActivity {


    private SocketIO socket;
    private JSONObject orderActual;
    private TextView operador;
    private TextView origen;
    private TextView destino;
    private TextView auto;
    private TextView costoViaje;
    private String userID;
    private String token;
    private String ip;
    private double costo;
    private String rol;

    private Tarjeta tarjeta = null;
    private Tarjeta[] t;
    private String mes;
    private String ano;
    private Button btnModalTarjeta;
    private ImageView v = null;

    private boolean isEfectivo = true;
    private boolean isClickOk = false;
    private boolean isClickConfirm = false;
    private boolean isClickCancel = false;
    private boolean isPaidCard = true;
    private ProgressDialog pDialog;

    private Button btnPedir;
    private Button btnFinalizar;
    private Button btnCancelar;
    private Button btnConfirmar;
    private TextView txtFecha;
    private boolean isQuoted;
    private boolean isSchedule;


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
        this.token = prefs.getString("token", "sintoken");
        this.rol = prefs.getString("rol", "sinrol");
        this.ip = getString(R.string.ipaddress);

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.orderActual = this.socket.getOrderActual();

        if(rol.equals("user")){

            setContentView(R.layout.activity_descripcion_servicio);

            btnModalTarjeta = (Button) findViewById(R.id.btnModalTarjeta);

            this.operador = (TextView) findViewById(R.id.operadorNombreServicio);
            this.origen = (TextView) findViewById(R.id.origenViajeServicio);
            this.destino = (TextView) findViewById(R.id.destinoViajeServicio);
            this.auto = (TextView) findViewById(R.id.automovilServicio);
            this.costoViaje = (TextView) findViewById(R.id.costoViajeServicio);

            btnPedir = (Button) findViewById(R.id.btnPedirAhora);
            btnFinalizar = (Button) findViewById(R.id.btnFinalizar);
            btnCancelar = (Button) findViewById(R.id.btnCancelarOrden);
            btnConfirmar = (Button) findViewById(R.id.btnConfirmar);
            txtFecha = (TextView) findViewById(R.id.fechaCotizarServicio);

            try {
                isQuoted = this.orderActual.getBoolean("isQuotation");
                isSchedule = this.orderActual.getBoolean("isSchedule");
                if(isSchedule){
                    btnPedir.setText(getString(R.string.txtAgendar));
                }
                if(!isQuoted){
                    btnPedir.setVisibility(View.GONE);
                    btnFinalizar.setVisibility(View.GONE);
                    btnCancelar.setVisibility(View.VISIBLE);
                    btnConfirmar.setVisibility(View.VISIBLE);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            try {
                JSONObject operadorJSON = this.orderActual.getJSONObject("operator_id");
                JSONObject origenJSON = this.orderActual.getJSONObject("origin");
                JSONObject destinoJSON = this.orderActual.getJSONObject("destiny");
                JSONObject carinfo = this.orderActual.getJSONObject("carinfo");
                String fecha="INMEDIATAMENTE";
                if(this.orderActual.getBoolean("isSchedule"))
                    fecha = this.orderActual.getString("dateSchedule");
                String name = operadorJSON.getString("name");
                String origenDireccion = origenJSON.getString("denomination");
                String destinoDireccion = destinoJSON.getString("denomination");
                String car = carinfo.getString("model");
                this.costo = this.orderActual.getDouble("total");
                this.operador.setText(name);
                this.origen.setText(origenDireccion);
                this.txtFecha.setText(fecha);
                this.destino.setText(destinoDireccion);
                this.auto.setText(car);
                this.costoViaje.setText("$"+costo);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            //Tabs
            TabHost tabs=(TabHost)findViewById(R.id.tabModoPago);
            tabs.setup();

            TabHost.TabSpec spec=tabs.newTabSpec("Efectivo");
            spec.setContent(R.id.Efectivo);
            spec.setIndicator("Efectivo");
            tabs.addTab(spec);

            spec = tabs.newTabSpec("mitab2");
            spec.setContent(R.id.Tarjeta);
            spec.setIndicator("Tarjeta Bancaria");
            tabs.addTab(spec);
            if(this.costo > 2000) {
                this.isPaidCard = false;
            }

            final Activity a = this;

            tabs.setCurrentTab(0);
            tabs.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
                @Override
                public void onTabChanged(String tabId) {
                    if(tabId.equals("Efectivo")){
                        isEfectivo = true;
                        LinearLayout lnS = (LinearLayout) findViewById(R.id.descripcionServicio);
                        lnS.setVisibility(View.VISIBLE);
                    }else {
                        LinearLayout lnS = (LinearLayout) findViewById(R.id.descripcionServicio);
                        lnS.setVisibility(View.GONE);
                        if(isPaidCard) {
                            isEfectivo = false;
                            getTarjetas();
                        }else{
                            isEfectivo = true;
                            Button btn = (Button) findViewById(R.id.btnModalTarjeta);
                            btn.setVisibility(View.GONE);
                            ListView lst = (ListView) findViewById(R.id.listaTarjeta);
                            lst.setVisibility(View.GONE);
                            Toast.makeText(a, getString(R.string.notCardMethodException),
                                    Toast.LENGTH_LONG).show();
                        }
                    }
                }
            });
            //fin tabs

        }else if(this.rol.equals("operator")){

            setContentView(R.layout.activity_esperando_cliente);

        }
        pDialog.dismiss();
    }

    @Override
    public void onBackPressed() {

    }

    public void crearTarjeta(String name, String numTarjeta, String CVC, String mes, String ano, final Dialog d, final View view){
        Conekta.setPublicKey(this.getString(R.string.conektaKey)); //Set public key
        Conekta.setApiVersion("1.0.0"); //Set api version (optional)
        Conekta.collectDevice(this); //Collect device

        Card card = new Card(name, numTarjeta, CVC, mes, ano);
        Token token = new Token(this);

        token.onCreateTokenListener( new Token.CreateToken(){
            @Override
            public void onCreateTokenReady(JSONObject data) {
                try {
                    //TODO: Create charge
                    String tkn = data.getString("id");
                    guardarTarjeta(tkn, d, view);
                } catch (Exception err) {
                    //TODO: Handle error
                }
            }
        });

        token.create(card);
    }

    public void guardarTarjeta(final String tkn, final Dialog d, final View v){
        Internet i = new Internet();

        if(i.verificaConexion(this)){

            SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("user_id", id);
                params.put("card_token", tkn);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/conekta/card", entity, "application/json", new JsonHttpResponseHandler() {

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

                    if (valor == true) {

                        d.dismiss();
                        getTarjetas();
                        Snackbar.make(v, "Agregado Correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    } else {
                        d.dismiss();
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

            });
        }else{
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void agregarTarjeta(final View view){
        final Dialog dialog = new Dialog(view.getContext());
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.dialog_agregar_tarjeta);

        TextView dialogButton = (TextView) dialog.findViewById(R.id.btnAgregarTarjeta);
        TextView cancelar = (TextView) dialog.findViewById(R.id.btnCancelarTarjeta);

        cancelar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dialog.dismiss();
            }
        });

        // if button is clicked, close the custom dialog
        dialogButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText nombre = (EditText) dialog.findViewById(R.id.txtNombrePropietario);
                EditText tarjeta = (EditText) dialog.findViewById(R.id.txtNumTarjeta);
                EditText cvc = (EditText) dialog.findViewById(R.id.txtCVC);
                String name = nombre.getText().toString();
                String num = tarjeta.getText().toString();
                String codigo = cvc.getText().toString();
                if(!name.equals("") && !num.equals("") && !codigo.equals("") && mes!=null && ano!=null) {
                    crearTarjeta(name, num, codigo, mes, ano, dialog, view);
                }else{
                    dialog.dismiss();
                    Snackbar.make(v, getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }
            }
        });

        dialog.show();



        Spinner spinMes = (Spinner) dialog.findViewById(R.id.mesesSpinner);
        Spinner spinAno = (Spinner) dialog.findViewById(R.id.anosSpinner);
        spinMes.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                mes = parent.getItemAtPosition(position).toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }

        });

        spinAno.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                ano = parent.getItemAtPosition(position).toString();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }

        });

    }

    public void createListTarjetas(){
        AdaptadorTarjetas adaptadorTarjetas =
                new AdaptadorTarjetas(this, t, this);

        final ListView lstOpciones2 = (ListView)findViewById(R.id.listaTarjeta);

        lstOpciones2.setAdapter(adaptadorTarjetas);
    }

    public void getTarjetas(){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {


            SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/conekta/cards/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray cards = null;
                    try {
                        cards = response.getJSONArray("cards");
                        t = new Tarjeta[cards.length()];
                        for(int i = 0; i < cards.length(); i++)
                        {
                            try {
                                JSONObject tarjeta = cards.getJSONObject(i);
                                Tarjeta t1 = new Tarjeta();
                                t1.setTipoTarjeta(tarjeta.getString("brand"));
                                t1.setNumTarjeta(tarjeta.getString("last4"));
                                t1.setToken(tarjeta.getString("id"));
                                t[i] = t1;
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        if(cards.length() > 0){
                            btnModalTarjeta.setVisibility(View.GONE);
                        }else{
                            btnModalTarjeta.setVisibility(View.VISIBLE);
                        }
                        createListTarjetas();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }


            });
        } else {

        }
    }

    public void setTarjeta(Tarjeta tarjeta, ImageView v){
        if(this.tarjeta != null) {
            if (this.tarjeta.getToken() == tarjeta.getToken()) {
                this.tarjeta = null;
                this.v.setVisibility(View.INVISIBLE);
            } else {
                this.tarjeta = tarjeta;
                if (this.v != null) {
                    this.v.setVisibility(View.INVISIBLE);
                }
                this.v = v;
                this.v.setVisibility(View.VISIBLE);
            }
        }else{
            this.tarjeta = tarjeta;
            if (this.v != null) {
                this.v.setVisibility(View.INVISIBLE);
            }
            this.v = v;
            this.v.setVisibility(View.VISIBLE);
        }
        LinearLayout lnS = (LinearLayout) findViewById(R.id.descripcionServicio);
        lnS.setVisibility(View.VISIBLE);
    }


    public void finalizarCotizacion(View v){
        String order_id = "";
        try {
            order_id = this.orderActual.getString("_id");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        this.socket.endQuotation(order_id, this.userID);
    }

    public void confirmarPrecio(final View v){
        if(!isSchedule) {
            if (!isClickOk) {
                isClickOk = true;
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                // Get the layout inflater
                LayoutInflater inflater = this.getLayoutInflater();

                // Inflate and set the layout for the dialog
                // Pass null as the parent view because its going in the dialog layout
                builder.setView(inflater.inflate(R.layout.dialog_confirmar_compra, null))
                        // Add action buttons
                        .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int id) {
                                if (!isClickConfirm) {
                                    isClickConfirm = true;
                                    String order_id = "";
                                    try {
                                        order_id = orderActual.getString("_id");
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                    if (!order_id.equals("")) {
                                        if (isEfectivo) {
                                            socket.acceptPayOrder(order_id, userID, "CASH", "");
                                        } else {
                                            if (tarjeta != null) {
                                                socket.acceptPayOrder(order_id, userID, "DEBT", tarjeta.getToken());
                                            } else {
                                                isClickOk = false;
                                                isClickConfirm = false;
                                                Snackbar.make(v, getString(R.string.sinTarjetaException), Snackbar.LENGTH_LONG)
                                                        .setAction("Action", null).show();
                                            }
                                        }
                                    }
                                }
                            }
                        })
                        .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                isClickOk = false;
                                dialog.dismiss();
                            }
                        });

                AlertDialog d = builder.create();

                d.show();

                d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(this, R.color.colorPrimaryYellow));

                d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(this, R.color.colorPrimaryYellow));

            }
        }else{
            String order_id = "";
            try {
                order_id = this.orderActual.getString("_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            this.socket.scheduleOrder(order_id, this.userID);
        }
    }

    public void pedirAhora(View v){
        btnPedir.setVisibility(View.GONE);
        btnFinalizar.setVisibility(View.GONE);
        btnCancelar.setVisibility(View.VISIBLE);
        btnConfirmar.setVisibility(View.VISIBLE);
    }

    public void cancel(View v){
        if(!isQuoted) {
            if (!isClickCancel) {
                isClickCancel = true;
                try {
                    socket.cancelOrder(socket.getOrderActual().getString("_id"), userID);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                Intent i = new Intent(this, MainActivity.class);
                startActivity(i);
            }
        }else{
            btnPedir.setVisibility(View.VISIBLE);
            btnFinalizar.setVisibility(View.VISIBLE);
            btnCancelar.setVisibility(View.GONE);
            btnConfirmar.setVisibility(View.GONE);
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
