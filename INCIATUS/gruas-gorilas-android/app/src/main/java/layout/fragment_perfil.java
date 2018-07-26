package layout;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.example.gargui3.gruasgorilas.Internet;
import com.example.gargui3.gruasgorilas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.DataAsyncHttpResponseHandler;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

/**
 * Created by gargui3 on 10/04/16.
 */
public class fragment_perfil extends Fragment {

    private String ip;
    private String token;
    private String nombre;
    private String correo;
    private String telefono;
    private String user_id;
    private JSONArray vehiculos;

    private ListView lstVehiculos;
    private ViewGroup rootView;
    private ImageView btnImage;
    private ProgressDialog progressDialog;

    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";


    public fragment_perfil() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        progressDialog = new ProgressDialog(this.getContext());
        progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        progressDialog.setMessage("Cargando...");
        progressDialog.setCancelable(false);
        progressDialog.setMax(100);
        progressDialog.show();

        // Inflate the layout for this fragment

        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_perfil, container, false);
        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        String rol = prefs.getString("rol", "sinrol");
        this.user_id = prefs.getString("idUsuario", "sinid");
        String url = prefs.getString("imgProfile", "sinfoto");
        cargarFoto();

        actualizarDatos();

        btnImage = (ImageView) rootView.findViewById(R.id.profile);
        btnImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cargarImagen(v);
            }
        });

        if(!url.equals("sinfoto")){
            Glide.with(this.getContext()).load(url.toString()).into(btnImage);
        }

        Button btnEditar = (Button) rootView.findViewById(R.id.btnEditarPerfil);
        btnEditar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                editar(v);
            }
        });

        FloatingActionButton btnNuevoVehiculo = (FloatingActionButton) rootView.findViewById(R.id.btnNuevoVehiculo);
        if(rol.equals("operator")){
            btnNuevoVehiculo.setVisibility(View.GONE);
        }else {
            btnNuevoVehiculo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    nuevoVehiculo(v);
                }
            });
        }

        lstVehiculos = (ListView)rootView.findViewById(R.id.lstVehiculos);

        obtenerVehiculos(this.getView());

        return rootView;

    }

    public void actualizarDatos(){
        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        TextView txtUsuario = (TextView) rootView.findViewById(R.id.txtNombreUsuario);
        nombre = prefs.getString("nombreUsuario", "Usuario");
        txtUsuario.setText(nombre);

        TextView txtCorreo = (TextView) rootView.findViewById(R.id.txtCorreoUsuario);
        correo = prefs.getString("correoUsuario", "Sin correo");
        txtCorreo.setText(correo);

        TextView txtTelefono = (TextView) rootView.findViewById(R.id.txtTelefonoUsuario);
        telefono = prefs.getString("telefonoUsuario", "Sin telefono");
        txtTelefono.setText(telefono);
    }

    public void cargarImagen(View v){
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("image/*");
        startActivityForResult(intent, 2);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 2 && resultCode == Activity.RESULT_OK) {
            if (data == null) {
                //Display an error
                return;
            }

            Uri url = data.getData();
            ProgressDialog pDialog = new ProgressDialog(this.getContext());
            pDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
            pDialog.setMessage("Cargando...");
            pDialog.setCancelable(false);
            pDialog.setMax(100);

            Uri imageUri = data.getData();
            try {
                Bitmap photo = MediaStore.Images.Media.getBitmap(this.getActivity().getContentResolver(), imageUri);
                Uri tempUri = getImageUri(this.getContext(), photo);

                String path = getRealPathFromURI(this.getContext(), tempUri);

                File file = new File(path);
                BitmapFactory.Options bmOptions = new BitmapFactory.Options();
                Bitmap finalPhoto = BitmapFactory.decodeFile(file.getAbsolutePath(),bmOptions);

                File f = createImage(finalPhoto, user_id + ".jpeg");

                SubirImagen subir = new SubirImagen(pDialog, this.getContext(), f, user_id, token);

                subir.execute();
            } catch (IOException e) {
                e.printStackTrace();
            }

            Glide.with(this.getContext()).load(url.toString()).into(btnImage);

            //Now you can do whatever you want with your inpustream, save it as file, upload to a server, decode a bitmap...
        }
    }

    private File createImage(Bitmap imageToSave, String fileName) {

        File direct = new File(Environment.getExternalStorageDirectory() + "/GruasGorilas");

        if (!direct.exists()) {
            File wallpaperDirectory = new File("/sdcard/GruasGorilas/");
            wallpaperDirectory.mkdirs();
        }

        File file = new File(new File("/sdcard/GruasGorilas/"), fileName);
        if (file.exists()) {
            file.delete();
        }
        try {
            FileOutputStream out = new FileOutputStream(file);
            imageToSave.compress(Bitmap.CompressFormat.JPEG, 100, out);
            out.flush();
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return file;
    }

    public Uri getImageUri(Context inContext, Bitmap inImage) {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        inImage.compress(Bitmap.CompressFormat.JPEG, 100, bytes);
        String path = MediaStore.Images.Media.insertImage(inContext.getContentResolver(), inImage, user_id, null);
        return Uri.parse(path);
    }

    public String getRealPathFromURI(Context context, Uri contentUri) {
        Cursor cursor = null;
        try {
            String[] proj = { MediaStore.Images.Media.DATA };
            cursor = context.getContentResolver().query(contentUri,  proj, null, null, null);
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToFirst();
            return cursor.getString(column_index);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
    }

    public void createList(JSONArray response){

        vehiculos = response;

        String[] datos =
                new String[response.length()];

        for(int i=0; i<response.length(); i++){
            try {
                JSONObject v = response.getJSONObject(i);
                datos[i] = v.getString("brand") + " " + v.getString("model") + " - " + v.getString("plates");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        ArrayAdapter<String> adaptador =
                new ArrayAdapter<String>(this.getContext(),
                        android.R.layout.simple_list_item_1, datos);


        lstVehiculos.setAdapter(adaptador);

        lstVehiculos.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, final View view, final int position, long id) {
                new AlertDialog.Builder(getActivity())
                        .setTitle("Eliminar")
                        .setMessage("Deseas eliminar este elemento?")
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setPositiveButton("Si", new DialogInterface.OnClickListener() {

                            public void onClick(DialogInterface dialog, int whichButton) {
                                try {
                                    JSONObject v = vehiculos.getJSONObject(position);
                                    String car_id = v.getString("_id");
                                    deleteVehiculo(view, car_id);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        })
                        .setNegativeButton("No", null).show();
                return false;
            }
        });
    }

    public void editar(final View view){

        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        // Get the layout inflater
        LayoutInflater inflater = getActivity().getLayoutInflater();

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        builder.setView(inflater.inflate(R.layout.dialog_editar_perfil, null))
                // Add action buttons
                .setPositiveButton(R.string.btnAceptar, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        editarPerfil(view, dialog);
                    }
                })
                .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                    }
                });

        AlertDialog d = builder.create();

        d.show();

        d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        TextView txtNombre = (TextView) d.findViewById(R.id.txtNombreUsuarioEditar);
        txtNombre.setText(nombre);

        TextView txtCorreo = (TextView) d.findViewById(R.id.txtCorreoUsuarioEditar);
        txtCorreo.setText(correo);

        TextView txtTelefono = (TextView) d.findViewById(R.id.txtTelefonoUsuarioEditar);
        txtTelefono.setText(telefono);

    }

    public void nuevoVehiculo(final View view){
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        // Get the layout inflater
        LayoutInflater inflater = getActivity().getLayoutInflater();

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        builder.setView(inflater.inflate(R.layout.dialog_nuevo_vehiculo, null))
                // Add action buttons
                .setPositiveButton(R.string.btnAgregar, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        guardarVehiculo(view, dialog);
                    }
                })
                .setNegativeButton(R.string.btnCancelar, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        dialog.dismiss();
                    }
                });

        AlertDialog d = builder.create();

        d.show();

        d.getButton(DialogInterface.BUTTON_NEGATIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

        d.getButton(DialogInterface.BUTTON_POSITIVE).setTextColor(ContextCompat.getColor(getContext(), R.color.colorPrimaryYellow));

    }

    public void deleteVehiculo(final View view, String car_id){
        Internet i = new Internet();
        if(i.verificaConexion(this.getContext())) {

            Context context = this.getContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.delete(context, ip + "/car/" + car_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    obtenerVehiculos(view);

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(view, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });

        } else {
            Snackbar.make(view, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void guardarVehiculo(final View view, final DialogInterface d){

        Dialog dialog = (Dialog) d;

        EditText txtMarca = (EditText) dialog.findViewById(R.id.txtMarcaVehiculoNuevo);
        EditText txtModelo = (EditText) dialog.findViewById(R.id.txtModeloVehiculoNuevo);
        EditText txtPlacas = (EditText) dialog.findViewById(R.id.txtPlacasVehiculoNuevo);
        EditText txtColor = (EditText) dialog.findViewById(R.id.txtColorVehiculoNuevo);

        Internet i = new Internet();

        if(i.verificaConexion(this.getContext())) {

            if (!txtMarca.getText().toString().equals("") && !txtModelo.getText().toString().equals("") && !txtPlacas.getText().toString().equals("") && !txtPlacas.getText().toString().equals("")) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("user_id", user_id);
                    params.put("brand", txtMarca.getText().toString());
                    params.put("plates", txtPlacas.getText().toString());
                    params.put("model", txtModelo.getText().toString());
                    params.put("color", txtColor.getText().toString());
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", this.token);
                client.post(context, ip + "/car", entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        d.dismiss();
                        Snackbar.make(view, getString(R.string.guardadoCorrectamente), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                        obtenerVehiculos(view);

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        d.dismiss();
                        Snackbar.make(view, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                });

            } else {
                d.dismiss();
                Snackbar.make(view, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else{
            d.dismiss();
            Snackbar.make(view, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void obtenerVehiculos(final View view){

        Internet i = new Internet();

        if(i.verificaConexion(this.getContext())) {

            Context context = this.getContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/cars/" + user_id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    try {
                        createList(response.getJSONArray("cars"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                }

            });

        }else{
            Snackbar.make(view, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void cargarFoto(){
        Internet i = new Internet();

        if(i.verificaConexion(this.getContext())) {

            Context context = this.getContext();

            String ip = getString(R.string.ipaddress);

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/profile/images/" + user_id, new DataAsyncHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                    Glide.with(getContext()).load(responseBody).into(btnImage);
                    if(statusCode == 200){
                        progressDialog.dismiss();
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {

                }


            });

        }

    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }

    public void editarPerfil(View view, DialogInterface dialog) {

        Internet i = new Internet();
        final View v = view;

        if (i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
            final SharedPreferences.Editor editor = prefs.edit();
            String id = prefs.getString("idUsuario", "sinID");

            if(!id.equals("sinID")) {

                Dialog d = (Dialog) dialog;

                final EditText nombre = (EditText) d.findViewById(R.id.txtNombreUsuarioEditar);
                final EditText correo = (EditText) d.findViewById(R.id.txtCorreoUsuarioEditar);
                final EditText telefono = (EditText) d.findViewById(R.id.txtTelefonoUsuarioEditar);
                final EditText pswd = (EditText) d.findViewById(R.id.txtContrasenaActualEditar);
                final EditText pswdNueva = (EditText) d.findViewById(R.id.txtContrasenaNuevaEditar);

                if (!nombre.getText().toString().equals("") && !correo.getText().toString().equals("") && !telefono.getText().toString().equals("")) {

                    if(validarEmail(correo.getText().toString())) {
                        if (pswd.getText().toString().equals(pswdNueva.getText().toString())){
                            JSONObject params = new JSONObject();
                            StringEntity entity = null;
                            try {
                                params.put("name", nombre.getText().toString());
                                params.put("email", correo.getText().toString());
                                params.put("phone", telefono.getText().toString());
                                if(!pswd.getText().toString().equals("") && !pswdNueva.getText().toString().equals("")){
                                    params.put("oldPassword", pswd.getText().toString());
                                    params.put("password", pswdNueva.getText().toString());
                                }
                                entity = new StringEntity(params.toString());
                            } catch (JSONException e) {
                                e.printStackTrace();
                            } catch (UnsupportedEncodingException e) {
                                e.printStackTrace();
                            }

                            Context context = this.getActivity().getApplicationContext();

                            AsyncHttpClient client = new AsyncHttpClient();
                            client.addHeader("Authorization", token);
                            client.put(context, ip + "/user/" + id, entity, "application/json", new JsonHttpResponseHandler() {

                                @Override
                                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                                    // If the response is JSONObject instead of expected JSONArray

                                    Object msj = null;
                                    try {
                                        msj = response.get("message");
                                        editor.putString("nombreUsuario", nombre.getText().toString());
                                        editor.putString("correoUsuario", correo.getText().toString());
                                        editor.putString("telefonoUsuario", telefono.getText().toString());
                                        editor.apply();
                                        actualizarDatos();
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }

                                    //Response
                                    Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                            .setAction("Action", null).show();

                                }

                                @Override
                                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                                    Snackbar.make(v, getString(R.string.sinServicioException), Snackbar.LENGTH_LONG)
                                            .setAction("Action", null).show();
                                }
                            });
                        }else{
                            Snackbar.make(v, getString(R.string.noCoincidenContrasenaException), Snackbar.LENGTH_LONG)
                                    .setAction("Action", null).show();
                        }
                    }else{
                        Snackbar.make(v, getString(R.string.correoInvalidoException), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }
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
    }

    @Override
    public void onStop(){
        super.onStop();
        progressDialog.dismiss();
    }

}
