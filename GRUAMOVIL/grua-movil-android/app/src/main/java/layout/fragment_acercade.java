package layout;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

/**
 * Created by gargui3 on 10/04/16.
 */
public class fragment_acercade extends Fragment {

    private ViewGroup rootView;
    private ImageView fb;
    private ImageView twitter;
    private ImageView lk;
    private ImageView yt;
    private ImageView web;
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
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_acercade, container, false);

        fb = (ImageView) rootView.findViewById(R.id.facebook);
        twitter = (ImageView) rootView.findViewById(R.id.twitter);
        lk = (ImageView) rootView.findViewById(R.id.linkedin);
        yt = (ImageView) rootView.findViewById(R.id.youtube);
        web = (ImageView) rootView.findViewById(R.id.web);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("Datos", Context.MODE_PRIVATE);
        final String rol = prefs.getString("rol", "sinrol");

        TextView calificar = (TextView) rootView.findViewById(R.id.calificanos);
        calificar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openPlayStore();
            }
        });

        TextView tutorial = (TextView) rootView.findViewById(R.id.tutorial);
        tutorial.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(rol.equals("user"))
                    openTutorial("https://www.youtube.com/watch?v=Zq-eDrnqW1s");
                else
                    openTutorial("https://www.youtube.com/watch?v=TKMAVZL0JvQ");
            }
        });

        final String[] datos ={"CDMX", "San Juan del Río, Qro", "Querétaro, Qro", "León, Gto"};

        ArrayAdapter<String> adaptador =
                new ArrayAdapter<String>(this.getActivity(), android.R.layout.simple_list_item_1, datos);

        ListView lstOpciones = (ListView)rootView.findViewById(R.id.listaLugaresDisponibles);

        lstOpciones.setAdapter(adaptador);

        fb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBrowser(fb);
            }
        });

        twitter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBrowser(twitter);
            }
        });

        lk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBrowser(lk);
            }
        });

        yt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBrowser(yt);
            }
        });

        web.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openBrowser(web);
            }
        });

        pDialog.dismiss();

        return rootView;

    }

    public void openTutorial(String url){
        startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
    }

    public void openPlayStore(){
        final String appPackageName = this.getContext().getPackageName();
        try {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)));
        } catch (android.content.ActivityNotFoundException e) {
            startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)));
        }
    }

    public void openBrowser(ImageView img){

        //Get url from tag
        String url = (String) img.getTag();

        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        intent.addCategory(Intent.CATEGORY_BROWSABLE);

        //pass the url to intent data
        intent.setData(Uri.parse(url));

        startActivity(intent);

    }
    @Override
    public void onStop(){
        super.onStop();
        pDialog.dismiss();
    }

}
