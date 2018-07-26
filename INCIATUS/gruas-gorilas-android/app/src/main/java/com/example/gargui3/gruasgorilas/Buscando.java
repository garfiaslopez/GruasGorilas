package com.example.gargui3.gruasgorilas;

import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.maps.android.PolyUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

import cz.msebera.android.httpclient.Header;

public class Buscando extends AppCompatActivity implements OnMapReadyCallback, android.location.LocationListener {

    private String userID;
    private String ip;
    private String token;
    private SocketIO socket;
    private String rol;

    private LocationManager locManager;
    private double lat = 19.416668;
    private double lng = -99.116669;
    private GoogleMap mapa;
    private JSONObject orderActual;
    private boolean isClickOk = false;
    private boolean isClickCancel = false;
    private ProgressDialog pDialog;

    double latO;
    double lngO;
    double latD;
    double lngD;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

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

        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();


        if(this.rol.equals("user")){

            setContentView(R.layout.activity_buscando);

            TextView btn = (TextView) findViewById(R.id.btnCancelarPedido);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    cancelarOrdenBuscandoCliente(v);
                }
            });
            pDialog.dismiss();

        }else if(this.rol.equals("operator")){

            setContentView(R.layout.activity_aceptar_orden_operator);

            rellenar();

            TextView txtOrdenTitulo = (TextView) findViewById(R.id.txtOrden);
            Button btnAceptar = (Button) findViewById(R.id.btnAceptarOrdenOperador);

            orderActual = this.socket.getOrderActual();

            try {
                boolean isQuote = orderActual.getBoolean("isQuotation");
                if(isQuote){
                    txtOrdenTitulo.setText(getString(R.string.txtDescripcionCotizar));
                    btnAceptar.setText(getString(R.string.btnCotizacionAceptar));
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            Button btn = (Button) findViewById(R.id.cancelarOperator);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    cancelarOrdenBuscando(v);
                }
            });

            SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                    .findFragmentById(R.id.map);
            mapFragment.getMapAsync(this);

        }

    }

    public void rellenar() {
        Button btnAceptar = (Button) findViewById(R.id.btnAceptarOrdenOperador);
        btnAceptar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                aceptarOrden(v);

            }
        });

        TextView cliente = (TextView) findViewById(R.id.clienteNombre);
        TextView fecha = (TextView) findViewById(R.id.fechaPedido);
        TextView origen = (TextView) findViewById(R.id.origenCliente);
        TextView destino = (TextView) findViewById(R.id.destinoCliente);
        TextView automovil = (TextView) findViewById(R.id.autoCliente);
        TextView condiciones = (TextView) findViewById(R.id.condicionesCliente);

        try {
            JSONObject orderActual = this.orderActual;
            JSONObject operadorJSON = orderActual.getJSONObject("user_id");
            JSONObject origenJSON = orderActual.getJSONObject("origin");
            JSONObject destinoJSON = orderActual.getJSONObject("destiny");
            JSONObject autoJSON = orderActual.getJSONObject("carinfo");
            String name = operadorJSON.getString("name");
            String origenDireccion = origenJSON.getString("denomination");
            String destinoDireccion = destinoJSON.getString("denomination");
            String auto = autoJSON.getString("model");
            String condicionesAuto = orderActual.getString("conditions");
            String fechaPedido = "INMEDIATAMENTE";
            if(!orderActual.optString("dateSchedule").isEmpty()){
                fechaPedido = orderActual.getString("dateSchedule");
            }
            JSONArray cordO = origenJSON.getJSONArray("cord");
            JSONArray cordD = destinoJSON.getJSONArray("cord");
            latO = cordO.getDouble(1);
            lngO = cordO.getDouble(0);
            latD = cordD.getDouble(1);
            lngD = cordD.getDouble(0);

            trazarRuta(latO, lngO, latD, lngD);

            cliente.setText(name);
            fecha.setText(fechaPedido);
            origen.setText(origenDireccion);
            destino.setText(destinoDireccion);
            automovil.setText(auto);
            condiciones.setText(condicionesAuto);

            /**/

        } catch (JSONException e) {
            e.printStackTrace();
        }
        pDialog.dismiss();
    }

    public void trazarRuta(double latO, double lngO, double latD, double lngD){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" + latO + "," + lngO + "&destination=" + latD + "," + lngD;


            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.get(context, url, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray route = null;
                    try {
                        route = response.getJSONArray("routes");
                        JSONObject objRoute = route.getJSONObject(0);
                        JSONObject overview = objRoute.getJSONObject("overview_polyline");
                        String polylineString = overview.getString("points");
                        List<LatLng> decodedPoints = PolyUtil.decode(polylineString);
                        PolylineOptions options = new PolylineOptions();
                        options.width(6);
                        options.color(R.color.colorAccent);
                        options.addAll(decodedPoints);

                        mapa.addPolyline(options);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }


            });
        }
    }

    public void aceptarOrden(View v){
        if(!isClickOk) {
            isClickOk = true;
            String order_id = null;
            try {
                order_id = this.orderActual.getString("_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (order_id != null)
                this.socket.acceptOrder(order_id, userID);
        }
    }

    public void cancelarOrdenBuscando(View v){
        if(!isClickCancel) {
            isClickCancel = true;
            String order_id = null;
            try {
                order_id = this.orderActual.getString("_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (order_id != null) {
                this.socket.rejectOrder(order_id, userID);
            }
        }
    }

    public void cancelarOrdenBuscandoCliente(View v){
        if(!isClickCancel) {
            isClickCancel = true;
            String order_id = null;
            try {
                order_id = this.orderActual.getString("_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (order_id != null) {
                this.finish();
                this.socket.cancelOrder(order_id, userID);
            }
        }
    }

    @Override
    public void onBackPressed() {

    }

    public void onMapReady(GoogleMap map) {

        final Geocoder geocoder = new Geocoder(this);

        this.mapa = map;

        if (ContextCompat.checkSelfPermission(this,
                android.Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) getSystemService(this.LOCATION_SERVICE);

            Criteria criteria = new Criteria();
            criteria.setAccuracy(Criteria.ACCURACY_FINE);
            String provider = locManager.getBestProvider(criteria, true);


            locManager.requestLocationUpdates(provider, 1000, 1, this);

            Location lc = locManager.getLastKnownLocation(provider);

            if (lc != null) {

                BitmapDescriptor icon = BitmapDescriptorFactory.fromResource(R.mipmap.ic_action_location);
                LatLng pos = new LatLng(latO, lngO);
                map.addMarker(new MarkerOptions()
                        .position(pos).title("Origen").icon(icon));

                LatLng pos2 = new LatLng(latD, lngD);
                map.addMarker(new MarkerOptions()
                        .position(pos2).title("Destino").icon(icon));

                onLocationChanged(lc);

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 11));

            }else{

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(19.416668, -99.116669), 11));

            }
        }else{

            map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(19.416668, -99.116669), 11));

        }

    }

    @Override
    public void onLocationChanged(Location location) {
        this.lat = location.getLatitude();
        this.lng = location.getLongitude();
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

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
