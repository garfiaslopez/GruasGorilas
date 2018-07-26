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

import java.io.UnsupportedEncodingException;

import Adapters.AdaptadorHistorial;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import modelo.Historial;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_historialSolicitudes extends Fragment {

    private String ip;
    private String user_id;
    private String token;
    private String rol;
    private ListView lstHistorial;
    private ProgressDialog pDialog;

    public fragment_historialSolicitudes() {
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

        ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.fragment_historial_solicitudes, container, false);

        this.ip = getString(R.string.ipaddress);
        SharedPreferences prefs = rootView.getContext().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.user_id = prefs.getString("idUsuario", "sinID");
        this.token = prefs.getString("token", "sintoken");
        this.rol = prefs.getString("rol", "sinrol");

        lstHistorial = (ListView) rootView.findViewById(R.id.listaHistorial);

        obtenerDatos();

        return rootView;
    }

    public void obtenerDatos(){

        Internet i = new Internet();
        final View v = this.getView();

        if (i.verificaConexion(this.getContext())) {

            if(!this.user_id.equals("sinID")) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    if(this.rol.equals("user")) {
                        params.put("user_id", this.user_id);
                    }else if(this.rol.equals("operator")){
                        params.put("operator_id", this.user_id);
                    }
                    params.put("page", "1");
                    params.put("limit", "10");
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getActivity().getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", this.token);
                client.post(context, ip + "/orders/byFilters", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        JSONObject orders = null;
                        JSONArray docs = null;
                        try {
                            orders = response.getJSONObject("orders");
                            docs = orders.getJSONArray("docs");
                            createList(docs);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        pDialog.dismiss();
                    }


                });
            }else{
                pDialog.dismiss();
                Snackbar.make(v, this.getString(R.string.sinUsuarioException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        } else {
            pDialog.dismiss();
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void createList(JSONArray results){
        Historial[] datos =
                new Historial[results.length()];

        for(int i=0; i<results.length(); i++){
            JSONObject v = null;
            try {
                v = (JSONObject) results.get(i);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            Historial h = new Historial();
            try {
                JSONObject destino = v.getJSONObject("destiny");
                h.setOrder_id(v.getString("order_id"));
                h.setFecha(v.getString("date"));
                h.setTotal(v.getString("total"));
                h.setDestino(destino.getString("denomination"));
            } catch (JSONException e) {
                e.printStackTrace();
            }
            datos[i] = h;
        }

        AdaptadorHistorial adaptador =
                new AdaptadorHistorial(this.getContext(), datos);


        lstHistorial.setAdapter(adaptador);

        pDialog.dismiss();
    }

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }

}
