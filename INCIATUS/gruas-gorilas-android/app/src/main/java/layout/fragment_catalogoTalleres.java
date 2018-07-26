package layout;


import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TabHost;

import com.example.gargui3.gruasgorilas.DetalleTaller;
import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

import Adapters.AdaptadorTaller;
import cz.msebera.android.httpclient.Header;
import modelo.Sucursal;
import modelo.Taller;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_catalogoTalleres extends Fragment {

    private String token;
    private String ip;
    private ViewGroup rootView;
    private Taller[] datos;
    private ProgressDialog pDialog;

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

        SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        String rol = prefs.getString("rol", "sinrol");

        if(rol.equals("user")) {
            //Tabs
            TabHost tabs = (TabHost) rootView.findViewById(R.id.tabAfiliados);
            tabs.setup();

            TabHost.TabSpec spec = tabs.newTabSpec("Todos");
            spec.setContent(R.id.Todos);
            spec.setIndicator("Todos");
            tabs.addTab(spec);

            spec = tabs.newTabSpec("Franquicias");
            spec.setContent(R.id.Franquicias);
            spec.setIndicator("Franquicias");
            tabs.addTab(spec);

            spec = tabs.newTabSpec("Independientes");
            spec.setContent(R.id.Independientes);
            spec.setIndicator("Independientes");
            tabs.addTab(spec);

            spec = tabs.newTabSpec("Bajio");
            spec.setContent(R.id.Bajio);
            spec.setIndicator("Bajio");
            tabs.addTab(spec);

            tabs.setCurrentTab(0);
            tabs.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
                @Override
                public void onTabChanged(String tabId) {
                    if (tabId.equals("Todos")) {
                        getTalleres("ALL");
                    } else if (tabId.equals("Franquicias")) {
                        getTalleres("FRANQUICIA");
                    } else if (tabId.equals("Independientes")) {
                        getTalleres("INDEPENDIENTE");
                    } else if (tabId.equals("Bajio")) {
                        getTalleres("BAJIO");
                    }
                }
            });
            //fin tabs

            getTalleres("ALL");
        }else if(rol.equals("operator")){
            getTalleres("ALLY");
        }

        return rootView;

    }

    public void createList(JSONArray talleres, String tipo){

        this.datos = new Taller[talleres.length()];

        for(int i=0; i<talleres.length(); i++){
            Taller t = new Taller();
            try {
                JSONObject o = (JSONObject) talleres.getJSONObject(i);
                t.setId(o.getString("_id"));
                t.setName(o.getString("name"));
                t.setDescription(o.getString("description"));
                t.setActivo(o.getJSONObject("promo").getBoolean("active"));
                t.setPromoDescription(o.getJSONObject("promo").getString("description"));
                t.setPhone(o.getString("phone"));
                if(!o.isNull("firstPhoto"))
                    t.setFirstPhoto(o.getString("firstPhoto"));
                if(!o.isNull("secondPhoto"))
                    t.setSecondPhoto(o.getString("secondPhoto"));
                if(!o.isNull("thirdPhoto"))
                    t.setThirdPhoto(o.getString("thirdPhoto"));
                t.setCategorie(o.getString("categorie"));
                t.setColor(o.getString("color"));
                JSONArray s = o.getJSONArray("subsidiary_id");
                if(!o.isNull("logo"))
                    t.setLogo(o.getString("logo"));

                ArrayList<Sucursal> a = new ArrayList<Sucursal>();

                for (int j=0; j<s.length(); j++) {
                    JSONObject so = s.getJSONObject(j);
                    Sucursal sucursal = new Sucursal();
                    sucursal.setId(so.getString("_id"));
                    sucursal.setTaller_id(so.getString("carworkshop_id"));
                    sucursal.setAddress(so.getString("address"));
                    sucursal.setCountry(so.getString("country"));
                    sucursal.setPhone(so.getString("phone"));
                    JSONArray c = so.getJSONArray("coords");
                    sucursal.setLng(c.getDouble(0));
                    sucursal.setLat(c.getDouble(1));
                    a.add(sucursal);
                }
                t.setSucursales(a);

                this.datos[i] = t;
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        AdaptadorTaller adaptador = new AdaptadorTaller(this.getContext(), datos);

        ListView lstOpciones = null;

        if(tipo.equals("ALL")) {
            lstOpciones = (ListView) rootView.findViewById(R.id.lstAfiliados);
        } else if(tipo.equals("FRANQUICIA")) {
            lstOpciones = (ListView) rootView.findViewById(R.id.lstAfiliadosFranquicias);
        } else if(tipo.equals("INDEPENDIENTE")) {
            lstOpciones = (ListView) rootView.findViewById(R.id.lstAfiliadosIndependientes);
        } else if(tipo.equals("BAJIO")) {
            lstOpciones = (ListView) rootView.findViewById(R.id.lstAfiliadosBajio);
        } else if(tipo.equals("ALLY")) {
            lstOpciones = (ListView) rootView.findViewById(R.id.lstAlly);
        }

        final Activity a = this.getActivity();

        assert lstOpciones != null;
        lstOpciones.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                Taller t = datos[position];
                Intent intent = new Intent(a, DetalleTaller.class);
                intent.putExtra("taller", t);
                startActivity(intent);

            }
        });

        lstOpciones.setAdapter(adaptador);

        pDialog.dismiss();

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
                        createList(talleres, tipo);
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

    }

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }

}


