package Adapters;

import android.content.Context;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import java.io.UnsupportedEncodingException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import modelo.Historial;

/**
 * Created by gargui3 on 20/11/16.
 */
public class AdaptadorHistorial extends ArrayAdapter<Historial> {

    Historial[] datos;

    public AdaptadorHistorial(Context context, Historial[] datos) {
        super(context, R.layout.formato_listahistorial, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.formato_listahistorial, null);

        String oldstring = datos[position].getFecha();
        oldstring = oldstring.substring(0, 10);

        String input = oldstring;
        SimpleDateFormat parser = new SimpleDateFormat("yyyy-MM-dd");
        Date date = null;
        try {
            date = parser.parse(input);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        SimpleDateFormat formatter = new SimpleDateFormat("dd MMMMMMM yyyy");
        String formattedDate = formatter.format(date);

        try {
            String value = new String(datos[position].getDestino().getBytes("ISO-8859-1"), "UTF-8");
            String decodedName = Html.fromHtml(value).toString();
            TextView txtDestino = (TextView) item.findViewById(R.id.destinoOrden);
            txtDestino.setText(decodedName);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        TextView txtOrden = (TextView) item.findViewById(R.id.orderID);
        txtOrden.setText("# " + datos[position].getOrder_id() + " | ");

        TextView txtFecha = (TextView) item.findViewById(R.id.fechaOrden);
        txtFecha.setText("" + formattedDate);

        TextView txtTotal = (TextView) item.findViewById(R.id.precioOrden);
        txtTotal.setText("$" + datos[position].getTotal());

        return (item);
    }
}
