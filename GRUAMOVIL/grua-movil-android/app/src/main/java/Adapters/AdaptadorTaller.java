package Adapters;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.example.gargui3.gruasgorilas.R;

import modelo.Taller;

/**
 * Created by gargui3 on 21/11/16.
 */
public class AdaptadorTaller extends ArrayAdapter<Taller> {

    Taller[] datos;

    public AdaptadorTaller(Context context, Taller[] datos) {
        super(context, R.layout.formato_listatalleres, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.formato_listatalleres, null);

        RelativeLayout r = (RelativeLayout) item.findViewById(R.id.layoutImagen);
        if(datos[position] != null) {
            if (!datos[position].getColor().equals("null")) {
                if (!datos[position].getColor().equals("undefined"))
                    r.setBackgroundColor(Color.parseColor(datos[position].getColor()));
            }

            TextView nombre = (TextView) item.findViewById(R.id.nombreAfiliado);
            nombre.setText(datos[position].getName());

            TextView locales = (TextView) item.findViewById(R.id.locales);
            locales.setText(datos[position].getSucursales().size() + " Sucursales");

            TextView tipo = (TextView) item.findViewById(R.id.tipo);
            tipo.setText(datos[position].getCategorie());

            TextView numero = (TextView) item.findViewById(R.id.numero);
            numero.setText(datos[position].getPhone());

            ImageView img = (ImageView) item.findViewById(R.id.imgTaller);
            String url = this.getContext().getString(R.string.ipaddress) + "/images/" +
                    datos[position].getName().replace(" ", "") + "/" + datos[position].getLogo();

            Glide.with(this.getContext()).load(url).into(img);
        }

        return(item);
    }
}
