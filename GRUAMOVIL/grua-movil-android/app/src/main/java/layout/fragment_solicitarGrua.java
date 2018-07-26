package layout;


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
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.OrdenAgendada;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import Adapters.AdaptadorAgendados;
import cz.msebera.android.httpclient.Header;
import modelo.Agenda;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_solicitarGrua extends Fragment {

    private String token;
    private String ip;
    private String user_id;
    private ViewGroup rootView;

    public fragment_solicitarGrua() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_solicitar_grua, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        this.user_id = prefs.getString("idUsuario", "sinid");

        getUltimo();
        getAgenda();

        return rootView;
    }

    public void getUltimo(){
        Internet i = new Internet();
        final View v = this.getView();

        final TextView txtNum = (TextView) rootView.findViewById(R.id.numPedidos);
        final TextView txtFecha = (TextView) rootView.findViewById(R.id.fechaPedidos);
        final TextView txtOrigen = (TextView) rootView.findViewById(R.id.origenPedidos);
        final TextView txtDestino = (TextView) rootView.findViewById(R.id.destinoPedidos);
        final TextView txtGruyero = (TextView) rootView.findViewById(R.id.gruaPedidos);
        final TextView txtPrecio = (TextView) rootView.findViewById(R.id.precioPedidos);

        if(i.verificaConexion(this.getContext())) {

            Context context = this.getContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/orders/lastQuotationByUser/" + this.user_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    try {
                        JSONObject order = response.getJSONObject("order");

                        txtNum.setText("#" + order.getString("order_id"));
                        txtOrigen.setText(order.getJSONObject("origin").getString("denomination"));
                        txtDestino.setText(order.getJSONObject("destiny").getString("denomination"));
                        txtFecha.setText(order.getString("date"));
                        txtGruyero.setText(order.getJSONObject("group").getString("name"));
                        txtPrecio.setText("$" + order.getString("total"));

                        System.out.println(order);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });

        } else {
            Snackbar.make(v, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void createList(JSONArray response){

        final Agenda[] datos =
                new Agenda[response.length()];

        for(int i=0; i<response.length(); i++){
            try {
                JSONObject v = response.getJSONObject(i);
                Agenda a = new Agenda();
                a.setDestinoPedido(v.getJSONObject("destiny").getString("denomination"));
                a.setFechaPedido(v.getString("date"));
                a.setGruyero("");
                a.setNumPedido("#" + v.getString("order_id"));
                a.setOrigenPedido(v.getJSONObject("origin").getString("denomination"));
                a.setPrecioPedido("$" + v.getString("total"));
                a.setNombreCliente(v.getJSONObject("user_id").getString("name"));
                a.setNombreOperador("Operador");
                datos[i] = a;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        AdaptadorAgendados adaptador = new AdaptadorAgendados(rootView.getContext(), datos);

        ListView lstAgenda = (ListView) rootView.findViewById(R.id.lstAgendados);

        lstAgenda.setAdapter(adaptador);

        final Intent i = new Intent(this.getActivity(), OrdenAgendada.class);

        lstAgenda.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                i.putExtra("orden", datos[position]);
                i.putExtra("tipo", true);
                startActivity(i);
            }
        });

    }

    public void getAgenda(){

        Internet i = new Internet();
        final View v = this.getView();

        if(i.verificaConexion(this.getContext())) {

            Context context = this.getContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/orders/schedulesByUser/" + this.user_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    //System.out.println(response);

                    try {
                        createList(response.getJSONObject("orders").getJSONArray("docs"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });

        } else {
            Snackbar.make(v, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

}
