package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import modelo.Agenda;

public class OrdenAgendada extends AppCompatActivity {

    private String token;
    private String ip;
    private String user_id;
    private String rol;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_orden_agendada);

        SharedPreferences prefs = this.getSharedPreferences("Datos", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        this.user_id = prefs.getString("idUsuario", "sinid");
        this.rol = prefs.getString("rol", "sinrol");

        Intent i = getIntent();

        Agenda a = (Agenda) i.getSerializableExtra("orden");
        boolean tipo = i.getBooleanExtra("tipo", false);

        TextView nombre = (TextView) findViewById(R.id.clienteNombreAgenda);
        TextView fecha = (TextView) findViewById(R.id.fechaPedidoAgenda);
        TextView origen = (TextView) findViewById(R.id.origenClienteAgenda);
        TextView destino = (TextView) findViewById(R.id.destinoClienteAgenda);
        TextView total = (TextView) findViewById(R.id.totalAgenda);
        Button continuar = (Button) findViewById(R.id.btnContinuarOrden);

        if(!tipo){
            continuar.setVisibility(View.GONE);
        }

        if(this.rol.equals("user")){

            continuar.setVisibility(View.GONE);
            TextView txt = (TextView) findViewById(R.id.nombreAgenda);
            txt.setText("Nombre del Operador");
            nombre.setText(a.getNombreOperador());
            fecha.setText(a.getFechaPedido());
            origen.setText(a.getOrigenPedido());
            destino.setText(a.getDestinoPedido());
            total.setText(a.getPrecioPedido());

        }else{

            nombre.setText(a.getNombreCliente());
            fecha.setText(a.getFechaPedido());
            origen.setText(a.getOrigenPedido());
            destino.setText(a.getDestinoPedido());
            total.setText(a.getPrecioPedido());
        }

    }
}
