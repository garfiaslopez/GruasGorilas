package Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import modelo.Vehiculo;

/**
 * Created by gargui3 on 8/10/16.
 */
public class AdaptadorAutos extends ArrayAdapter<Vehiculo> {

    Vehiculo[] datos;

    public AdaptadorAutos(Context context, Vehiculo[] datos) {
        super(context, R.layout.formato_listaautos, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.formato_listaautos, null);

        TextView txtVehiculo = (TextView) item.findViewById(R.id.txtVehiculo);
        txtVehiculo.setText(datos[position].getMarca() + " - " + datos[position].getModelo());

        return(item);
    }

}