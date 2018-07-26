package Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import modelo.Sucursal;

/**
 * Created by gargui3 on 1/01/16.
 */
public class AdaptadorSucursales extends ArrayAdapter<Sucursal> {

    Sucursal[] datos;

    public AdaptadorSucursales(Context context, Sucursal[] datos) {
        super(context, R.layout.formato_listatalleres, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.formato_listasucursal, null);

        TextView nombre = (TextView)item.findViewById(R.id.tituloSucursal);
        nombre.setText(datos[position].getCountry());

        TextView locales = (TextView)item.findViewById(R.id.numeroSucursal);
        locales.setText(datos[position].getPhone());

        TextView tipo = (TextView)item.findViewById(R.id.direccionSucursal);
        tipo.setText(datos[position].getAddress());

        return(item);
    }
}
