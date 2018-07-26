package layout;


import android.Manifest;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;

import com.example.gargui3.gruasgorilas.Calificar;
import com.example.gargui3.gruasgorilas.Login;
import com.example.gargui3.gruasgorilas.Notices;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.places.AutocompletePrediction;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AutoCompleteTextView;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.example.gargui3.gruasgorilas.SeleccionPedido;
import com.example.gargui3.gruasgorilas.SocketIO;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.location.places.PlaceBuffer;
import com.google.android.gms.location.places.Places;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_principal extends Fragment implements OnMapReadyCallback, android.location.LocationListener, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private LocationManager locManager;
    private ViewGroup rootView;
    private double lat = 19.416668;
    private double lng = -99.116669;
    private double latO = 0.0;
    private double lngO = 0.0;
    private double latD = 0.0;
    private double lngD = 0.0;
    private String rol;
    private GoogleMap mapa;
    private AutoCompleteTextView direccionEdit;
    private AutoCompleteTextView direccionBtnCasa;
    private AutoCompleteTextView direccionBtn;
    private Switch s;
    private String vendor_id;
    private boolean firtsUse = true;
    private ArrayList<String> noticias = new ArrayList<String>();
    private boolean firstConected = true;
    private Geocoder geocoder;

    private String token;
    private String ip;
    private Boolean operatorsDisponibles = false;

    private SocketIO socket;
    private boolean isAccepted;
    private Boolean permisos = true;
    private boolean firstOpen = true;

    private PlaceAutocompleteAdapter mToAdapter;
    private GoogleApiClient mGoogleApiClient = null;
    private ProgressDialog pDialog;

    private static Context ctx;

    public fragment_principal() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        pDialog = new ProgressDialog(this.getActivity());
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();


        //Recuperar rol de usuario
        final SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");
        this.token = prefs.getString("token", "sintoken");
        this.isAccepted = prefs.getBoolean("isAccepted", true);
        boolean isRejected = prefs.getBoolean("isRejected", false);
        boolean isExpired = prefs.getBoolean("isExpired", false);
        boolean isAlreadyTaked = prefs.getBoolean("isAlreadyTaked", false);
        this.ip = this.getString(R.string.ipaddress);

        geocoder = new Geocoder(this.getContext());

        // Iniciar Socket
        this.socket = SocketIO.getInstance();
        if (!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this.getActivity());
        } else {
            this.socket.setActivity(this.getActivity());
        }

        ctx = this.getContext();

        buildGoogleApiClient();


        if(this.socket.isQuoted()){

            this.socket.setQuoted(false);

            AlertDialog.Builder builderM = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1M = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builderM.setView(inflater1M.inflate(R.layout.dialog_mensaje_quoted, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
            final AlertDialog mensaje = builderM.create();
            mensaje.show();

            mensaje.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        }

        if(this.socket.isSchedule()){

            this.socket.setSchedule(false);

            AlertDialog.Builder builderM = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1M = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builderM.setView(inflater1M.inflate(R.layout.dialog_mensaje_schedule, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
            final AlertDialog mensaje = builderM.create();
            mensaje.show();

            mensaje.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        }

        if(isRejected){

            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isRejected", false);
            editor.commit();

            AlertDialog.Builder builderM = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1M = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builderM.setView(inflater1M.inflate(R.layout.dialog_mensaje_rejected, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
            final AlertDialog mensaje = builderM.create();
            mensaje.show();

            mensaje.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        }



        if(isExpired){

            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isExpired", false);
            editor.commit();

            AlertDialog.Builder builderM = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1M = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builderM.setView(inflater1M.inflate(R.layout.dialog_mensaje_expired, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
            final AlertDialog mensaje = builderM.create();
            mensaje.show();

            mensaje.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        }

        if(isAlreadyTaked){
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("isAlreadyTaked", false);
            editor.commit();
            AlertDialog.Builder builderM = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1M = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builderM.setView(inflater1M.inflate(R.layout.dialog_mensaje_alreadytaked, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });
            final AlertDialog mensaje = builderM.create();
            mensaje.show();

            mensaje.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        }

        String isCalifico = prefs.getString("isCalifico", "true");

        if(isCalifico.equals("false")){
            Intent i = new Intent(this.getActivity(), Calificar.class);
            startActivity(i);
        }


        if (rol.equals("user")) {
            rootView = (ViewGroup) inflater.inflate(R.layout.fragment_principal, container, false);
            TextView btnEnviar = (TextView) rootView.findViewById(R.id.btncontinuarPedido);
            TextView btnCotizar = (TextView) rootView.findViewById(R.id.btnCotizar);

            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1 = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builder.setView(inflater1.inflate(R.layout.dialog_llamar_central, null))
                    // Add action buttons
                    .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            SharedPreferences.Editor editor = prefs.edit();
                            editor.putBoolean("isAccepted", true);
                            editor.commit();
                            //llamar();
                        }
                    })
                    .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                            SharedPreferences.Editor editor = prefs.edit();
                            editor.putBoolean("isAccepted", true);
                            editor.commit();
                        }
                    });

            final AlertDialog d = builder.create();

            if (!this.isAccepted) {
                d.show();
                d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

            }

            btnCotizar.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (latO != 0.0 && lngO != 0.0 && latD != 0.0 && lngD != 0.0 && operatorsDisponibles) {
                        Intent intent = new Intent(getActivity(), SeleccionPedido.class);
                        intent.putExtra("direccionO", direccionBtn.getText().toString());
                        intent.putExtra("direccionD", direccionBtnCasa.getText().toString());
                        intent.putExtra("latO", latO);
                        intent.putExtra("lngO", lngO);
                        intent.putExtra("latD", latD);
                        intent.putExtra("lngD", lngD);
                        intent.putExtra("cotizar", true);
                        startActivity(intent);
                    } else if (!operatorsDisponibles) {
                        d.show();
                        d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                        d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                    } else {
                        Toast.makeText(ctx, getString(R.string.lugaresNoSelccionadoException), Toast.LENGTH_LONG).show();
                    }
                }
            });

            btnEnviar.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    if (latO != 0.0 && lngO != 0.0 && latD != 0.0 && lngD != 0.0 && operatorsDisponibles) {
                        Intent intent = new Intent(getActivity(), SeleccionPedido.class);
                        intent.putExtra("direccionO", direccionBtn.getText().toString());
                        intent.putExtra("direccionD", direccionBtnCasa.getText().toString());
                        intent.putExtra("latO", latO);
                        intent.putExtra("lngO", lngO);
                        intent.putExtra("latD", latD);
                        intent.putExtra("lngD", lngD);
                        intent.putExtra("cotizar", false);
                        startActivity(intent);
                    } else if (!operatorsDisponibles) {
                        d.show();
                        d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                        d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                    } else {
                        Toast.makeText(ctx, getString(R.string.lugaresNoSelccionadoException), Toast.LENGTH_LONG).show();
                    }
                }
            });
            //Geolocalizacion al dar click en el boton
            FloatingActionButton btn = (FloatingActionButton) rootView.findViewById(R.id.getMyLocation);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    getMyLocation();
                    getOperators();
                }
            });

            //Google places
            direccionBtn = (AutoCompleteTextView) rootView.findViewById(R.id.Direccion);
            direccionBtnCasa = (AutoCompleteTextView) rootView.findViewById(R.id.DireccionCasa);

            if (firtsUse) {
                direccionEdit = (AutoCompleteTextView) rootView.findViewById(R.id.Direccion);
                firtsUse = false;
            }

            return rootView;
        } else if (rol.equals("operator")) {
            this.vendor_id = prefs.getString("idUsuario", "sinID");
            rootView = (ViewGroup) inflater.inflate(R.layout.fragment_principal_operator, container, false);
            this.s = (Switch) rootView.findViewById(R.id.disponibilidad);
            Boolean status = prefs.getBoolean("switch", true);
            this.s.setChecked(status);
            this.s.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    updateChecked(s.isChecked());
                }
            });
            inicializarDatosOperator();
            updateLoc();
            notices();
        }

        return rootView;
    }

    public void notices(){
        Internet i = new Internet();

        final Activity a = this.getActivity();

        final TextView txtNotice = (TextView) rootView.findViewById(R.id.txtNotice);
        txtNotice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(a, Notices.class);
                intent.putStringArrayListExtra("notices", noticias);
                startActivityForResult(intent, 2);
            }
        });

        if (i.verificaConexion(getContext())) {

            Context context = ctx;

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/notice", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    try {
                        JSONArray notices = response.getJSONArray("notices");
                        if(notices.length() > 0) {
                            JSONObject n = notices.getJSONObject(0);
                            String noticia = n.getString("description");
                            txtNotice.setText(noticia);
                            noticias.add(noticia);
                            for (int i = 1; i < notices.length(); i++) {
                                JSONObject notice = notices.getJSONObject(i);
                                String txt = notice.getString("description");
                                noticias.add(txt);
                            }
                            pDialog.dismiss();
                        }else{
                            txtNotice.setVisibility(View.GONE);
                            pDialog.dismiss();
                        }
                    } catch (JSONException e) {
                        pDialog.dismiss();
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    pDialog.dismiss();
                    Snackbar.make(rootView, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });
        } else {
            pDialog.dismiss();
        }
    }

    private ResultCallback<PlaceBuffer> mToUpdatePlaceDetailsCallback = new ResultCallback<PlaceBuffer>() {
        @Override
        public void onResult(PlaceBuffer places) {
            if (!places.getStatus().isSuccess()) {
                places.release();
                return;
            }

            latO = places.get(0).getLatLng().latitude;
            lngO = places.get(0).getLatLng().longitude;

            mapa.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(latO, lngO), 15));

            places.release();
        }
    };

    private ResultCallback<PlaceBuffer> mToUpdatePlaceDetailsCallbackDestino = new ResultCallback<PlaceBuffer>() {
        @Override
        public void onResult(PlaceBuffer places) {
            if (!places.getStatus().isSuccess()) {
                places.release();
                return;
            }

            latD = places.get(0).getLatLng().latitude;
            lngD = places.get(0).getLatLng().longitude;

            places.release();
        }
    };

    public void getOperators() {


        Internet i = new Internet();

        if (i.verificaConexion(ctx)) {

            final Context context = ctx;

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/users/byavailablevendors/bylocation/" + this.latO + "/" + this.lngO, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray users = null;
                    try {
                        users = response.getJSONArray("vendors");
                        if (users.length() > 0) {
                            TextView txtContinuar = (TextView) rootView.findViewById(R.id.btncontinuarPedido);
                            txtContinuar.setText(getString(R.string.txtRealizarPedido));
                            operatorsDisponibles = true;
                            for (int i = 0; i < users.length(); i++) {
                                JSONObject user = users.getJSONObject(i);
                                JSONObject loc = user.getJSONObject("loc");
                                JSONArray cord = loc.getJSONArray("cord");
                                BitmapDescriptor icon = BitmapDescriptorFactory.fromResource(R.mipmap.makergrua);
                                LatLng pos = new LatLng(cord.getDouble(1), cord.getDouble(0));
                                mapa.addMarker(new MarkerOptions()
                                        .position(pos).title("Operador").icon(icon));
                            }
                            pDialog.dismiss();
                        } else {

                            TextView txtContinuar = (TextView) rootView.findViewById(R.id.btncontinuarPedido);

                            txtContinuar.setText(getString(R.string.txtSinServicio));

                            if(firstOpen) {

                                firstOpen = false;

                                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                                // Get the layout inflater
                                LayoutInflater inflater1 = getActivity().getLayoutInflater();

                                // Inflate and set the layout for the dialog
                                // Pass null as the parent view because its going in the dialog layout
                                builder.setView(inflater1.inflate(R.layout.dialog_llamar_central, null))
                                        // Add action buttons
                                        .setPositiveButton(R.string.llamar, new DialogInterface.OnClickListener() {
                                            @Override
                                            public void onClick(DialogInterface dialog, int id) {
                                                dialog.dismiss();
                                            }
                                        })
                                        .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int id) {
                                                dialog.dismiss();
                                            }
                                        });

                                final AlertDialog d = builder.create();

                                if(isAccepted) {

                                    d.show();

                                    d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                                    d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));
                                }

                                operatorsDisponibles = false;
                            }
                            pDialog.dismiss();
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        pDialog.dismiss();
                    }
                    pDialog.dismiss();
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    operatorsDisponibles = false;
                    if(statusCode == 403){
                        SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos",Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("token", "sintoken");
                        editor.commit();
                        Intent i = new Intent(rootView.getContext(), Login.class);
                        getActivity().finish();
                        startActivity(i);
                    }
                    pDialog.dismiss();
                    Snackbar.make(rootView, "No hay vendedores disponibles", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });
        } else {
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            // Get the layout inflater
            LayoutInflater inflater1 = getActivity().getLayoutInflater();

            // Inflate and set the layout for the dialog
            // Pass null as the parent view because its going in the dialog layout
            builder.setView(inflater1.inflate(R.layout.dialog_llamar_central, null))
                    // Add action buttons
                    .setPositiveButton(R.string.llamar, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    })
                    .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.dismiss();
                        }
                    });

            final AlertDialog d = builder.create();

            if(isAccepted) {
                d.show();

                d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

                d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));
            }
            pDialog.dismiss();
        }

    }

    public void updateLoc() {
        getMyLocation();
        updateLocOperator();
    }

    public void updateLocOperator() {
        Internet i = new Internet();

        final View v = this.getView();

        if (i.verificaConexion(ctx)) {

            JSONObject params = new JSONObject();
            JSONObject cord = new JSONObject();
            JSONObject loc = new JSONObject();
            StringEntity entity = null;
            try {
                cord.put("long", this.lng);
                cord.put("lat", this.lat);
                loc.put("denomination", "update location");
                loc.put("cord", cord);
                params.put("loc", loc);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            final Context context = ctx;

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + this.vendor_id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    if(firstConected) {
                        firstConected = false;
                        Toast toast = Toast.makeText(context, getString(R.string.conectadoServicio), Toast.LENGTH_LONG);
                        toast.show();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, "No se pudo cambiar tu disponibilidad", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void updateChecked(final Boolean status) {
        Internet i = new Internet();

        final View v = this.getView();

        if (i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("available", status);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            final Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + this.vendor_id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = prefs.edit();
                    editor.putBoolean("switch", status);
                    editor.commit();

                    if(status) {
                        agregarConexion();
                    }else{
                        cerrarConexion();
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, "No se pudo cambiar tu disponibilidad", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void agregarConexion() {
        Internet i = new Internet();

        final View v = this.getView();

        if (i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {

                params.put("operator_id", this.vendor_id);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/connection", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, "No se pudo cambiar tu disponibilidad", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void cerrarConexion() {
        Internet i = new Internet();

        final View v = this.getView();

        if (i.verificaConexion(getContext())) {

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(ip + "/connectionclose/" + this.vendor_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, "No se pudo cambiar tu disponibilidad", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void inicializarDatosOperator() {
        final TextView txtServicios = (TextView) rootView.findViewById(R.id.serviciosDia);
        final TextView txtTotal = (TextView) rootView.findViewById(R.id.totalDia);

        Internet i = new Internet();

        if (i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("isTotals", true);
                params.put("dateFilter", "today");
                params.put("operator_id", this.vendor_id);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/orders/byFilters", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject datos = null;
                    try {
                        txtServicios.setText("#" + response.getString("count"));
                        txtTotal.setText("$" + response.getString("total"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    if(statusCode == 403){
                        SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos",Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("token", "sintoken");
                        editor.commit();
                        Intent i = new Intent(rootView.getContext(), Login.class);
                        getActivity().finish();
                        startActivity(i);
                    }
                    Snackbar.make(rootView, "No se pudieron obtener los datos del dia", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(rootView, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }


    }


    @Override
    public void onViewCreated(View v, Bundle savedInstanceState) {
        super.onViewCreated(v, savedInstanceState);
        if (rol.equals("user")) {
            MapView mapView = (MapView) v.findViewById(R.id.map);
            mapView.onCreate(savedInstanceState);
            mapView.onResume();
            mapView.getMapAsync(this);

            double offset = 200.0/1000.0;
            double latMax = this.lat + offset;
            double latMin = this.lat - offset;
            double lngOffset = offset * Math.cos(this.lat*Math.PI/200.0);
            double lngMax = this.lng + lngOffset;
            double lngMin = this.lng - lngOffset;

            final LatLngBounds BOUNDS = new LatLngBounds(new LatLng((double)Math.round(latMin * 1000000d) / 1000000d, (double)Math.round(lngMin * 1000000d) / 1000000d), new LatLng((double)Math.round(latMax * 1000000d) / 1000000d, (double)Math.round(lngMax * 1000000d) / 1000000d));


            mToAdapter = new PlaceAutocompleteAdapter(this.getContext(), mGoogleApiClient, BOUNDS, null);


            final Context context = this.getContext();

            direccionBtn.setAdapter(mToAdapter);
            direccionBtn.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    AutocompletePrediction item = mToAdapter.getItem(position);
                    final String placeId = String.valueOf(item.getPlaceId());
                    InputMethodManager imm = (InputMethodManager) context.getSystemService(context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                    PendingResult<PlaceBuffer> placeResult = Places.GeoDataApi
                            .getPlaceById(mGoogleApiClient, placeId);
                    placeResult.setResultCallback(mToUpdatePlaceDetailsCallback);
                    getOperators();
                }
            });
            direccionBtnCasa.setAdapter(mToAdapter);
            direccionBtnCasa.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    AutocompletePrediction item = mToAdapter.getItem(position);
                    final String placeId = String.valueOf(item.getPlaceId());
                    InputMethodManager imm = (InputMethodManager) context.getSystemService(context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                    PendingResult<PlaceBuffer> placeResult = Places.GeoDataApi
                            .getPlaceById(mGoogleApiClient, placeId);
                    placeResult.setResultCallback(mToUpdatePlaceDetailsCallbackDestino);
                }
            });

        }
    }

    public void getMyLocation() {
        if (ContextCompat.checkSelfPermission(this.getActivity(),
                Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) getActivity().getSystemService(this.getContext().LOCATION_SERVICE);

            Criteria criteria = new Criteria();
            criteria.setAccuracy(Criteria.ACCURACY_FINE);
            final String provider = locManager.getBestProvider(criteria, true);


            locManager.requestLocationUpdates(provider, 0, 0, this);

            Location lc = locManager.getLastKnownLocation(provider);

            if (lc != null && mapa != null) {

                mapa.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lc.getLatitude(), lc.getLongitude()), 15));

            }

        }
    }

    public void onMapReady(GoogleMap map) {

        map.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {

            @Override
            public void onCameraChange(CameraPosition cameraPosition) {
                try {
                    List<Address> lista = geocoder.getFromLocation(cameraPosition.target.latitude, cameraPosition.target.longitude, 1);
                    lat = cameraPosition.target.latitude;
                    lng = cameraPosition.target.longitude;
                    if (lista != null && lista.size() > 0) {
                        Address direccion = lista.get(0);

                        direccionBtn.setText(direccion.getAddressLine(0) + " " + direccion.getLocality() + " " + direccion.getCountryName());
                        direccionBtn.dismissDropDown();
                        latO = direccion.getLatitude();
                        lngO = direccion.getLongitude();
                        getOperators();

                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });

        this.mapa = map;

        getMyLocation();

    }

    @Override
    public void onLocationChanged(Location location) {
        this.lat = location.getLatitude();
        this.lng = location.getLongitude();

        if(this.rol.equals("operator"))updateLocOperator();

    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {
        getMyLocation();
    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    @Override
    public void onConnected(@Nullable Bundle bundle) {

    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }

    public synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this.getActivity())
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(Places.GEO_DATA_API)
                .build();
    }

    @Override
    public void onStart() {
        super.onStart();
        mGoogleApiClient.connect();
    }

    @Override
    public void onStop() {
        pDialog.dismiss();
        if (mGoogleApiClient.isConnected()) {
            mGoogleApiClient.disconnect();
        }
        super.onStop();
    }

}
