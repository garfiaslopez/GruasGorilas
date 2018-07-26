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
import android.widget.ListView;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import Adapters.AdaptadorTarifas;
import cz.msebera.android.httpclient.Header;
import modelo.Tarifa;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_tarifas extends Fragment {

    private String ip;
    private String token;
    private ViewGroup rootView;
    private ProgressDialog pDialog;


    public fragment_tarifas() {
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
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_tarifas, container, false);
        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        obtenerTarifas();

        return rootView;

    }

    public void obtenerTarifas(){
        Internet i = new Internet();
        final View v = this.getView();
        final Context ctx = this.getContext();
        final ListView lstTarifas = (ListView) rootView.findViewById(R.id.lstTarifas);

        if (i.verificaConexion(this.getContext())) {

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/routeexample", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray tarifas;

                    try {
                        tarifas = response.getJSONArray("routes");
                        Tarifa[] datos = new Tarifa[tarifas.length()];
                        for(int i=0; i<tarifas.length();i++){
                            JSONObject t = tarifas.getJSONObject(i);
                            Tarifa ta = new Tarifa(t.getString("origin") + " - " + t.getString("destiny"), "$" + t.getDouble("price"));
                            datos[i] = ta;
                            AdaptadorTarifas adaptador = new AdaptadorTarifas(ctx, datos);
                            lstTarifas.setAdapter(adaptador);
                        }
                        pDialog.dismiss();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    pDialog.dismiss();
                }


            });


        } else {
            pDialog.dismiss();
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
