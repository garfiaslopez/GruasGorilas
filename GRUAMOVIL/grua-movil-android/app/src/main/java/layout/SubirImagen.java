package layout;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.widget.Toast;

import com.example.gargui3.gruasgorilas.R;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

import cz.msebera.android.httpclient.HttpResponse;
import cz.msebera.android.httpclient.client.HttpClient;
import cz.msebera.android.httpclient.client.methods.HttpPost;
import cz.msebera.android.httpclient.entity.mime.MultipartEntityBuilder;
import cz.msebera.android.httpclient.entity.mime.content.FileBody;
import cz.msebera.android.httpclient.impl.client.DefaultHttpClient;

/**
 * Created by gargui3 on 7/12/16.
 */
public class SubirImagen extends AsyncTask<Void, Integer, Boolean> {

    private ProgressDialog pDialog;
    private Context context;
    private File file;
    private String user_id;
    private String token;

    public SubirImagen(ProgressDialog pDialog, Context context, File file, String user_id, String token){
        this.pDialog = pDialog;
        this.context = context;
        this.file = file;
        this.user_id = user_id;
        this.token = token;
    }

    @Override
    protected Boolean doInBackground(Void... params) {

        for(int i=0; i<=10; i++) {

            if(i==0)subir();

            publishProgress(i*10);

            if(isCancelled())
                break;
        }

        return true;
    }

    public void subir(){
        HttpClient httpclient;
        HttpPost httppost;


        httpclient = new DefaultHttpClient();
        httppost = new HttpPost(context.getString(R.string.ipaddress) + "/profile/images/" + user_id);
        httppost.addHeader("Authorization", token);

        httpclient.getParams().setParameter("Connection", "Keep-Alive");
        httpclient.getParams().setParameter("Content-Type", "multipart/form-data;");

        MultipartEntityBuilder entity = MultipartEntityBuilder.create();

        entity.addPart("profilePhoto", new FileBody(file));

        httppost.setEntity(entity.build());

        HttpResponse response = null;
        try {
            response = httpclient.execute(httppost);
            String json;
            BufferedReader reader = null;
            reader = new BufferedReader(new InputStreamReader(response.getEntity().getContent(), "UTF-8"));
            json = reader.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onProgressUpdate(Integer... values) {
        int progreso = values[0].intValue();

        pDialog.setProgress(progreso);
    }

    @Override
    protected void onPreExecute() {

        pDialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                SubirImagen.this.cancel(true);
            }
        });

        pDialog.setProgress(0);
        pDialog.show();
    }

    @Override
    protected void onPostExecute(Boolean result) {
        if(result)
        {
            pDialog.dismiss();
            Toast.makeText(context, "Foto de perfil cargada correctamente",
                    Toast.LENGTH_SHORT).show();
        }else{
            Toast.makeText(context, "No se pudo cargar la foto",
                    Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    protected void onCancelled() {
        Toast.makeText(context, "No se pudo cargar la foto!",
                Toast.LENGTH_SHORT).show();
    }

}
