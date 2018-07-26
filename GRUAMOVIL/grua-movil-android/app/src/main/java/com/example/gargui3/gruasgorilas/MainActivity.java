package com.example.gargui3.gruasgorilas;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.DataAsyncHttpResponseHandler;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.urbanairship.UAirship;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import io.realm.Realm;
import io.realm.RealmConfiguration;
import layout.*;


public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    private SocketIO socket;
    private String rol;
    private String id;
    private String token;
    private boolean valor;
    private ImageView img;
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

        setContentView(R.layout.activity_main);

        sendChannelId(UAirship.shared().getPushManager().getChannelId());

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close) {

            @Override
            public void onDrawerClosed(View drawerView) {
                // Code here will be triggered once the drawer closes as we dont want anything to happen so we leave this blank
                super.onDrawerClosed(drawerView);
                InputMethodManager inputMethodManager = (InputMethodManager)
                        getSystemService(Context.INPUT_METHOD_SERVICE);
                inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                // Code here will be triggered once the drawer open as we dont want anything to happen so we leave this blank
                super.onDrawerOpened(drawerView);
                InputMethodManager inputMethodManager = (InputMethodManager)
                        getSystemService(Context.INPUT_METHOD_SERVICE);
                inputMethodManager.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
            }
        };

        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
            this.socket.conectar(this.getString(R.string.ipaddress));
        }

        valor = getIntent().getBooleanExtra("dontBack", false);

        //Open menu principal
        Fragment fragment = new fragment_principal();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.content_frame, fragment)
                .addToBackStack("gruamovil")
                .commit();

        navigationView.getMenu().getItem(0).setChecked(true);
        getSupportActionBar().setTitle(getString(R.string.app_name));

        navigationView.setNavigationItemSelectedListener(this);

        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        rol = prefs.getString("rol", "sinrol");
        id = prefs.getString("idUsuario", "sinID");
        token = prefs.getString("token", "sintoken");



        if (rol.equals("operator")) {
            navigationView.getMenu().getItem(2).setTitle("Aliados Estrategicos");
            navigationView.getMenu().getItem(0).setTitle("Dashboard");
            //navigationView.getMenu().getItem(5).setVisible(false);
        }

        //init config realm
        RealmConfiguration config = new RealmConfiguration.Builder(this).build();
        Realm.setDefaultConfiguration(config);

        img = (ImageView) navigationView.getHeaderView(0).findViewById(R.id.profileImg);
        cargarFoto();

    }

    public void cargarFoto(){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            Context context = this;

            String ip = getString(R.string.ipaddress);

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/profile/images/" + id, new DataAsyncHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                    Glide.with(getApplicationContext()).load(responseBody).into(img);
                    if(statusCode == 200){
                        pDialog.dismiss();
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {

                }

            });

        }
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (valor){

        }else if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else if (getSupportFragmentManager().getBackStackEntryCount() >= 1) {
            getSupportFragmentManager().popBackStackImmediate();
            Fragment fragment = new fragment_principal();
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.content_frame, fragment)
                    .addToBackStack("gruamovil")
                    .commit();
            NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
            getSupportActionBar().setTitle(getString(R.string.app_name));
            navigationView.getMenu().getItem(0).setChecked(true);
        } else {
            this.finish();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        SharedPreferences prefs = getSharedPreferences("Datos",Context.MODE_PRIVATE);
        String correo = prefs.getString("correoUsuario", "sin usuario");
        String nombre = prefs.getString("nombreUsuario", "Usuario");

        TextView t = (TextView) findViewById(R.id.correoUser);
        TextView u = (TextView) findViewById(R.id.nombreUsuario);


        if(t != null)
            t.setText(correo);
        if(u != null)
            u.setText(nombre);
        return true;
    }

    public void sendChannelId(String channel){

        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");
            String token = prefs.getString("token", "sintoken");
            final String rol = prefs.getString("rol", "sinrol");

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("push_id", channel);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            String ip = getString(R.string.ipaddress);

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    UAirship.shared().getPushManager().editTags()
                            .addTag(rol)
                            .addTag("Android")
                            .apply();
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }


            });

        }else {

        }

    }

    //finaliza llamada de actividades

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.

        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.

        boolean fragmentTransaction = false;
        Fragment fragment = null;

        switch (item.getItemId()) {
            case R.id.principal:
                fragment = new fragment_principal();
                fragmentTransaction = true;
                break;
            case R.id.reservaciones:
                fragment = new fragment_solicitarGrua();
                fragmentTransaction = true;
                break;
            case R.id.catalogo:
                fragment = new fragment_catalogoTalleres();
                fragmentTransaction = true;
                break;
            /*case R.id.tarifas:
                fragment = new fragment_tarifas();
                fragmentTransaction = true;
                break;*/
            case R.id.historial:
                fragment = new fragment_historialSolicitudes();
                fragmentTransaction = true;
                break;
            case R.id.acercade:
                fragment = new fragment_acercade();
                fragmentTransaction = true;
                break;
            /*case R.id.datosPago:
                fragment = new fragment_datos_pago();
                fragmentTransaction = true;
                break;*/
            case R.id.perfil:
                fragment = new fragment_perfil();
                fragmentTransaction = true;
                break;
            case R.id.ayuda:
                fragment = new fragment_ayuda();
                fragmentTransaction = true;
                break;
        }

        if(fragmentTransaction) {

            getSupportFragmentManager().popBackStackImmediate();
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.content_frame, fragment)
                    .addToBackStack("gruamovil")
                    .commit();
            item.setChecked(true);
            getSupportActionBar().setTitle(item.getTitle());

        }else {
            close();
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    public void close(){

        pDialog = new ProgressDialog(this);
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        Internet i = new Internet();

        if (i.verificaConexion(this)) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {

                if(rol.equals("user")) {
                    params.put("user_id", this.id);
                } else if(rol.equals("operator")) {
                    params.put("operator_id", this.id);
                }

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            String ip = getString(R.string.ipaddress);

            final Activity a = this;
            final Context ctx = this;
            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/authenticate/logoutuser", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    SharedPreferences prefs = getSharedPreferences("Datos", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = prefs.edit();
                    editor.putString("token", "sintoken");
                    editor.commit();

                    socket.isEnded();

                    pDialog.dismiss();
                    Intent intent = new Intent(a, Login.class);
                    finish();
                    startActivity(intent);

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }


            });
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
