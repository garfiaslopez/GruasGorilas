package com.example.gargui3.gruasgorilas;

import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.net.Uri;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
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

public class TransportingOrder extends AppCompatActivity implements OnMapReadyCallback, android.location.LocationListener {

    private SocketIO socket;
    private JSONObject orderActual;
    private TextView operador;
    private TextView origen;
    private String userID;
    private String token;
    private String ip;
    private String rol;

    private LocationManager locManager;
    private double lat = 19.416668;
    private double lng = -99.116669;
    private GoogleMap mapa;
    private String phone;
    private boolean permisos;
    private boolean isClickOk = false;
    private double latD;
    private double lngD;
    private double latO;
    private double lngO;
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

        getSupportActionBar().setTitle(getString(R.string.servicioProceso));

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

        if(this.rol.equals("user")) {

            setContentView(R.layout.activity_transporting_order);

            rellenar("operator_id");

            //Geolocalizacion al dar click en el boton
            FloatingActionButton btn = (FloatingActionButton) findViewById(R.id.getMyLocationTransporting);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    getMyLocation();
                }
            });

            SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                    .findFragmentById(R.id.map);
            mapFragment.getMapAsync(this);

        }else if(this.rol.equals("operator")){

            setContentView(R.layout.activity_transporting_orden_operator);
            getMyLocation();
            //Geolocalizacion al dar click en el boton
            FloatingActionButton btn = (FloatingActionButton) findViewById(R.id.getMyLocationTransporting);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    getMyLocation();
                }
            });

            SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                    .findFragmentById(R.id.map);
            mapFragment.getMapAsync(this);
            rellenar("user_id");

        }
    }

    public void rellenar(String user) {

        TextView cliente = (TextView) findViewById(R.id.clienteNombre);
        TextView origen = (TextView) findViewById(R.id.origenCliente);
        TextView destino = (TextView) findViewById(R.id.destinoCliente);
        TextView automovil = (TextView) findViewById(R.id.autoCliente);
        TextView condiciones = (TextView) findViewById(R.id.condicionesCliente);

        try {
            JSONObject orderActual = this.orderActual;
            JSONObject operadorJSON = orderActual.getJSONObject(user);
            JSONObject origenJSON = orderActual.getJSONObject("origin");
            JSONObject destinoJSON = orderActual.getJSONObject("destiny");
            JSONObject autoJSON;
            String auto;
            String placas;
            if(user.equals("user_id")) {
                autoJSON = orderActual.getJSONObject("carinfo");
                auto = autoJSON.getString("model");
                automovil.setText(auto);
            }else{
                autoJSON = orderActual.getJSONObject("tow");
                auto = autoJSON.getString("serialNumber");
                placas = autoJSON.getString("plate");
                automovil.setText(auto + " - " + placas);
            }
            String name = operadorJSON.getString("name");
            this.phone = operadorJSON.getString("phone");
            String origenDireccion = origenJSON.getString("denomination");
            String destinoDireccion = destinoJSON.getString("denomination");
            String condicionesAuto = orderActual.getString("conditions");
            JSONArray cordO = origenJSON.getJSONArray("cord");
            JSONArray cordD = destinoJSON.getJSONArray("cord");
            if(user.equals("operator_id")) {
                latO = cordO.getDouble(1);
                lngO = cordO.getDouble(0);
                latD = cordD.getDouble(1);
                lngD = cordD.getDouble(0);
            }else{
                latO = this.lat;
                lngO = this.lng;
                latD = cordD.getDouble(1);
                lngD = cordD.getDouble(0);
            }

            trazarRuta(latO, lngO, latD, lngD);

            cliente.setText(name);
            origen.setText(origenDireccion);
            destino.setText(destinoDireccion);
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

    @Override
    public void onBackPressed() {

    }


    public void navegacionWazeTransporting(View v){
        try {
            String url = "waze://?ll=" + this.latD + "," + this.lngD + "&navigate=yes";
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            startActivity(intent);
        } catch (ActivityNotFoundException ex) {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.waze"));
            startActivity(intent);
        }
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

    public void finalizarViaje(View v){
        if(!isClickOk) {
            isClickOk = true;
            String order_id = null;
            try {
                order_id = this.orderActual.getString("_id");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            if (order_id != null)
                this.socket.endTravel(order_id, userID);
        }
    }



    public void getMyLocation(){
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

                onLocationChanged(lc);

                if(mapa != null)
                    mapa.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 20));

            }
        }
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
        ActivityManager activityManager = (ActivityManager) context.getSystemService(this.ACTIVITY_SERVICE);
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
