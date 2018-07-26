package com.example.gargui3.gruasgorilas;

import android.content.Intent;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.bumptech.glide.Glide;

import Adapters.AdaptadorSucursales;
import modelo.Sucursal;
import modelo.Taller;

public class DetalleTaller extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detalle_taller);
        Intent intent = getIntent();
        Taller t = (Taller) intent.getExtras().getSerializable("taller");

        TextView promo = (TextView) findViewById(R.id.promo);
        if(t.getActivo()){
            promo.setText(t.getPromoDescription());
            promo.setVisibility(View.VISIBLE);
        }

        ImageView imgLogo = (ImageView) findViewById(R.id.imgLogo);
        String url = getString(R.string.ipaddress) + "/images/" +
                t.getName().replace(" ", "") + "/" + t.getLogo();

        Glide.with(this).load(url).into(imgLogo);

        TextView descripcion = (TextView) findViewById(R.id.descripcionTaller);
        descripcion.setText(t.getDescription());

        TextView numS = (TextView) findViewById(R.id.numSucursal);
        numS.setText(t.getSucursales().size() + " Sucursales");

        TextView c = (TextView) findViewById(R.id.categoria);
        c.setText(t.getCategorie());

        ImageView imgUno = (ImageView) findViewById(R.id.imgUno);
        String urlUno = getString(R.string.ipaddress) + "/images/" +
                t.getName().replace(" ", "") + "/" + t.getFirstPhoto();

        Glide.with(this).load(urlUno).into(imgUno);

        ImageView imgDos = (ImageView) findViewById(R.id.imgDos);
        String urlDos = getString(R.string.ipaddress) + "/images/" +
                t.getName().replace(" ", "") + "/" + t.getSecondPhoto();

        Glide.with(this).load(urlDos).into(imgDos);

        ImageView imgTres = (ImageView) findViewById(R.id.imgTres);
        String urlTres = getString(R.string.ipaddress) + "/images/" +
                t.getName().replace(" ", "") + "/" + t.getThirdPhoto();

        Glide.with(this).load(urlTres).into(imgTres);

        final Sucursal[] datos = new Sucursal[t.getSucursales().size()];

        for(int i=0; i<datos.length; i++){
            datos[i] = t.getSucursales().get(i);
        }

        AdaptadorSucursales adaptador = new AdaptadorSucursales(this, datos);

        ListView lstOpciones = (ListView) findViewById(R.id.lstSucursal);

        assert lstOpciones != null;
        lstOpciones.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

                // Create a Uri from an intent string. Use the result to create an Intent.
                Uri gmmIntentUri = Uri.parse("google.streetview:cbll=" + datos[position].getLat() + "," + datos[position].getLng());

                Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                mapIntent.setPackage("com.google.android.apps.maps");

                startActivity(mapIntent);

            }
        });

        lstOpciones.setAdapter(adaptador);

    }
}
