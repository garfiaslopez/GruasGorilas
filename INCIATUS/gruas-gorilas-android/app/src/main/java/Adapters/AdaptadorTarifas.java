package Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import modelo.Tarifa;

/**
 * Created by gargui3 on 10/04/16.
 */
public class AdaptadorTarifas extends ArrayAdapter<Tarifa> {

    Tarifa[] datos;

    public AdaptadorTarifas(Context context, Tarifa[] datos) {
        super(context, R.layout.formato_tarifas, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.formato_tarifas, null);

        TextView ruta = (TextView)item.findViewById(R.id.rutaTarifa);
        ruta.setText(datos[position].getRuta());

        TextView precio = (TextView)item.findViewById(R.id.precioTarifa);
        precio.setText(datos[position].getPrecio());

        return(item);
    }
}