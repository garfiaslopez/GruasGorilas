package layout;


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
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.zopim.android.sdk.api.ZopimChat;
import com.zopim.android.sdk.model.VisitorInfo;
import com.zopim.android.sdk.prechat.ZopimChatActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

/**
 * A simple {@link Fragment} subclass.
 */
public class fragment_ayuda extends Fragment {

    private String ip;
    private String token;
    private ProgressDialog pDialog;
    private String nombreUsuario;
    private String correoUsuario;
    private String telefonoUsuario;


    public fragment_ayuda() {
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
        ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.fragment_ayuda, container, false);
        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        this.nombreUsuario = prefs.getString("nombreUsuario", "Usuario");
        this.correoUsuario = prefs.getString("correoUsuario", "Sin correo");
        this.telefonoUsuario = prefs.getString("telefonoUsuario", "Sin telefono");

        Button btnEnviar = (Button) rootView.findViewById(R.id.btnEnviarAyuda);
        btnEnviar.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                enviarPregunta(v);
            }
        });

        Button btnChat = (Button) rootView.findViewById(R.id.btnChat);
        btnChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ZopimChat.init(getString(R.string.chatKey));
                VisitorInfo visitorData = new VisitorInfo.Builder()
                        .name(nombreUsuario)
                        .email(correoUsuario)
                        .phoneNumber(telefonoUsuario)
                        .build();

                ZopimChat.setVisitorInfo(visitorData);
                startActivity(new Intent(getContext(), ZopimChatActivity.class));
            }
        });

        pDialog.dismiss();

        return rootView;
    }

    public void enviarPregunta(View view) {

        pDialog = new ProgressDialog(this.getContext());
        pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        pDialog.setMessage("Cargando...");
        pDialog.setCancelable(false);
        pDialog.setMax(100);
        pDialog.show();

        InputMethodManager inputMethodManager = (InputMethodManager)
                this.getActivity().getSystemService(this.getContext().INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(this.getActivity().getCurrentFocus().getWindowToken(), 0);

        Internet i = new Internet();
        final View v = view;

        if (i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
            String id = prefs.getString("idUsuario", "sinID");

            if(!id.equals("sinID")) {

                final EditText subject = (EditText) getView().findViewById(R.id.txtTituloAyuda);
                final EditText description = (EditText) getView().findViewById(R.id.txtDescripcionAyuda);

                if (!subject.getText().toString().equals("") && !description.getText().toString().equals("")) {

                    JSONObject params = new JSONObject();
                    StringEntity entity = null;
                    try {
                        params.put("subject", subject.getText().toString());
                        params.put("description", description.getText().toString());
                        params.put("user_id", id);
                        entity = new StringEntity(params.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }

                    Context context = this.getActivity().getApplicationContext();

                    AsyncHttpClient client = new AsyncHttpClient();
                    client.addHeader("Authorization", token);
                    client.post(context, ip + "/help", entity, "application/json", new JsonHttpResponseHandler() {

                        @Override
                        public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                            // If the response is JSONObject instead of expected JSONArray

                            Object msj = null;
                            try {
                                msj = response.get("message");
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            //Response
                            subject.setText("");
                            description.setText("");
                            Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                    .setAction("Action", null).show();

                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                        }


                    });
                } else {
                    Snackbar.make(v, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }
            }else{
                Snackbar.make(v, this.getString(R.string.sinUsuarioException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
        pDialog.dismiss();
    }

    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }

}
