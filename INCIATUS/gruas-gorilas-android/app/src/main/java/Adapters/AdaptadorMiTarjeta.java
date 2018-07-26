package Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import layout.fragment_datos_pago;
import modelo.Tarjeta;

/**
 * Created by gargui3 on 19/06/16.
 */
public class AdaptadorMiTarjeta extends ArrayAdapter<Tarjeta> {

    Tarjeta[] datos;
    fragment_datos_pago r;

    public AdaptadorMiTarjeta(Context context, Tarjeta[] datos, fragment_datos_pago r) {
        super(context, R.layout.activity_descripcion_servicio, datos);
        this.datos = datos;
        this.r = r;
    }

    public View getView(final int position, final View convertView, ViewGroup parent) {

        final LayoutInflater inflater = LayoutInflater.from(getContext());
        final View item = inflater.inflate(R.layout.lista_tarjetas, null);

        TextView lblNumTarjeta = (TextView) item.findViewById(R.id.numeroTarjeta);
        String numTarjeta = datos[position].getNumTarjeta();
        lblNumTarjeta.setText("   •••• •••• •••• " + numTarjeta);

        ImageView imgTarjeta = (ImageView)item.findViewById(R.id.tipo);
        String tipo = datos[position].getTipoTarjeta();

        if(tipo.equals("MC"))
            imgTarjeta.setImageResource(R.mipmap.mastercard);
        else if(tipo.equals("VISA"))
            imgTarjeta.setImageResource(R.mipmap.visa);
        else if(tipo.equals("AMERICAN_EXPRESS"))
            imgTarjeta.setImageResource(R.mipmap.amex);

        return(item);
    }
}
