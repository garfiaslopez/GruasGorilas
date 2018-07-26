package layout;


import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import Adapters.AdaptadorMiTarjeta;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import io.conekta.conektasdk.Card;
import io.conekta.conektasdk.Conekta;
import io.conekta.conektasdk.Token;
import modelo.Tarjeta;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_datos_pago extends Fragment {

    private ViewGroup rootView;
    private String ip;
    private String token;
    private JSONArray tarjetas;
    private String mes = null;
    private String ano = null;
    private ProgressDialog pDialog;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        pDialog = new ProgressDialog(this.getContext());
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_datos_pago, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        getTarjetas();

        Button btnAgregar = (Button) rootView.findViewById(R.id.modalTarjeta);

        btnAgregar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                agregarTarjeta(v);
            }
        });

        return rootView;

    }

    public void createList(){
        final Tarjeta[] datos = new Tarjeta[tarjetas.length()];

        for(int i = 0; i < tarjetas.length(); i++)
        {
            datos[i] = new Tarjeta();
            try {
                JSONObject tarjeta = tarjetas.getJSONObject(i);
                datos[i].setTipoTarjeta(tarjeta.getString("brand"));
                datos[i].setNumTarjeta(tarjeta.getString("last4"));
                datos[i].setToken(tarjeta.getString("id"));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        AdaptadorMiTarjeta adaptadorTarjetas =
                new AdaptadorMiTarjeta(this.getContext(), datos, this);

        final ListView lstOpciones = (ListView)rootView.findViewById(R.id.listaMisTarjetas);

        lstOpciones.setAdapter(adaptadorTarjetas);


        lstOpciones.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {

            public boolean onItemLongClick(AdapterView<?> arg0, View v,
                                           final int index, long arg3) {

                new AlertDialog.Builder(getActivity())
                        .setTitle("Eliminar")
                        .setMessage("Deseas eliminar este elemento?")
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setPositiveButton("Si", new DialogInterface.OnClickListener() {

                            public void onClick(DialogInterface dialog, int whichButton) {
                                try {
                                    JSONObject card = tarjetas.getJSONObject(index);
                                    String idCard = card.getString("id");
                                    eliminarTarjeta(idCard);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        })
                        .setNegativeButton("No", null).show();
                return false;
            }
        });
        pDialog.dismiss();
    }

    public void eliminarTarjeta(String idCard){
        Internet i = new Internet();

        if(i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");


            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.delete(context, ip + "/conekta/card/" + id + "/" + idCard, new JsonHttpResponseHandler() {

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

                        getTarjetas();
                        Snackbar.make(getView(), "Eliminado Correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    } else {
                        Snackbar.make(getView(), msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

            });
        }else{
            Snackbar.make(getView(), this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void getTarjetas(){
        Internet i = new Internet();
        final View v = this.getView();

        if(i.verificaConexion(getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/conekta/cards/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray cards = null;
                    try {
                        cards = response.getJSONArray("cards");
                        tarjetas = cards;
                        createList();
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

    public void crearTarjeta(String name, String numTarjeta, String CVC, String mes, String ano, final Dialog d, final View view){
        Conekta.setPublicKey(this.getString(R.string.conektaKey)); //Set public key
        Conekta.setApiVersion("1.0.0"); //Set api version (optional)
        Conekta.collectDevice(this.getActivity()); //Collect device

        Card card = new Card(name, numTarjeta, CVC, mes, ano);
        Token token = new Token(this.getActivity());

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

        if(i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
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

            Context context = this.getActivity().getApplicationContext();

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

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }


}
