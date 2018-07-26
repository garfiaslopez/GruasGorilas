package Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.gruasgorilas.R;

import modelo.Agenda;

/**
 * Created by alejandro on 7/03/17.
 */

public class AdaptadorAgendados extends ArrayAdapter<Agenda> {

    Agenda[] datos;

    public AdaptadorAgendados(Context context, Agenda[] datos) {
        super(context, R.layout.lista_agendados, datos);
        this.datos = datos;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());
        View item = inflater.inflate(R.layout.lista_agendados, null);

        TextView txtNum = (TextView) item.findViewById(R.id.numPedidos);
        txtNum.setText(datos[position].getNumPedido());

        TextView txtFecha = (TextView) item.findViewById(R.id.fechaPedidos);
        txtFecha.setText(datos[position].getFechaPedido());

        TextView txtOrigen = (TextView) item.findViewById(R.id.origenPedidos);
        txtOrigen.setText(datos[position].getOrigenPedido());

        TextView txtDestino = (TextView) item.findViewById(R.id.destinoPedidos);
        txtDestino.setText(datos[position].getDestinoPedido());

        TextView txtGruyero = (TextView) item.findViewById(R.id.gruaPedidos);
        txtGruyero.setText(datos[position].getGruyero());

        TextView txtPrecio = (TextView) item.findViewById(R.id.precioPedidos);
        txtPrecio.setText(datos[position].getPrecioPedido());

        return (item);
    }
}