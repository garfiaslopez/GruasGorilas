package layout;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import cz.msebera.android.httpclient.Header;
import modelo.Taller;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_catalogoTalleres extends Fragment implements OnMapReadyCallback {

    private String token;
    private String ip;
    private double lat = -34.61587176137625;
    private double lng = -58.433298449999995;
    private ViewGroup rootView;
    private Taller[] datos;
    private GoogleMap mapa;
    private ProgressDialog pDialog;
    private String[] array = {"ALL", "talleres", "gomerias", "repuesteras", "estServicios", "estacionamientos", "farmacias", "cerrajeria"};

    public fragment_catalogoTalleres() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        pDialog = new ProgressDialog(this.getContext());
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_catalogo_talleres, container, false);

        Spinner spinner = (Spinner) rootView.findViewById(R.id.talleres);
        // Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(rootView.getContext(),
                R.array.talleres, android.R.layout.simple_spinner_item);
        // Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        // Apply the adapter to the spinner
        spinner.setAdapter(adapter);

        SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                getTalleres(array[position]);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        return rootView;

    }

    public void addMaker(JSONArray talleres) {
        BitmapDescriptor icon = BitmapDescriptorFactory.fromResource(R.mipmap.shopmini);
        for (int i=0; i<talleres.length(); i++) {
            try {
                JSONObject taller = talleres.getJSONObject(i);
                String name = taller.getString("name");
                JSONArray coords = taller.getJSONArray("subsidiary_id");
                if(coords.length() > 0) {
                    JSONObject subsidiary = coords.getJSONObject(0);
                    JSONArray position = subsidiary.getJSONArray("coords");
                    LatLng pos = new LatLng(position.getDouble(1), position.getDouble(0));
                    this.mapa.addMarker(new MarkerOptions()
                            .position(pos).title(name).icon(icon));
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public void getTalleres(final String tipo){
        Internet i = new Internet();
        final View v = this.getView();

        if (i.verificaConexion(this.getContext())) {

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/carworkshop/by/type/" + tipo, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    try {
                        JSONArray talleres = response.getJSONArray("carworkshops");
                        mapa.clear();
                        addMaker(talleres);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
        this.pDialog.dismiss();
    }

    public void onViewCreated(View v, Bundle savedInstanceState) {
        super.onViewCreated(v, savedInstanceState);
        MapView mapView = (MapView) v.findViewById(R.id.map);
        mapView.onCreate(savedInstanceState);
        mapView.onResume();
        mapView.getMapAsync(this);
    }

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }

    @Override
    public void onMapReady(GoogleMap map) {
        this.mapa = map;
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 11));
    }
}