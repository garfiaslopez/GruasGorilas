package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import modelo.Condicion;

public class Condiciones extends AppCompatActivity {

    private Drawable img;
    private Condicion c = new Condicion();
    private boolean perfecto = false;
    private boolean descompuesto = false;
    private boolean siniestro = false;
    private boolean ruedasGiran = false;
    private boolean sinRuedas = false;
    private boolean sinLlaves = false;
    private boolean fallaMotor = false;
    private LinearLayout siguiente;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_condiciones);
        img = this.getResources().getDrawable(R.mipmap.ic_action_tick);
        TextView txt = (TextView) findViewById(R.id.btnAceptar);
        siguiente = (LinearLayout) findViewById(R.id.siguienteProceso);
        siguiente.setVisibility(View.INVISIBLE);
        final Context ctx = this;
        txt.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View v) {

                Intent intent = getIntent();
                intent.putExtra("condicion", c);
                setResult(RESULT_FIRST_USER, intent);
                finish();

            }
        });
    }

    public void showButton(){
        if(perfecto || descompuesto || siniestro){
            if(ruedasGiran || sinRuedas || sinLlaves || fallaMotor) {
                siguiente.setVisibility(View.VISIBLE);
            }else{
                siguiente.setVisibility(View.INVISIBLE);
            }
        }else{
            siguiente.setVisibility(View.INVISIBLE);
        }
    }

    public void perfecto(View v){
        if(!perfecto) {
            TextView txt = (TextView) findViewById(R.id.perfectoAuto);
            TextView txt2 = (TextView) findViewById(R.id.descompuestoAuto);
            TextView txt3 = (TextView) findViewById(R.id.siniestroAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(txt.getText().toString());
            perfecto = true;
            descompuesto = false;
            siniestro = false;
        } else {
            TextView txt = (TextView) findViewById(R.id.perfectoAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(null);
            perfecto = false;
        }
        showButton();
    }

    public void descompuesto(View v){
        if(!descompuesto) {
            TextView txt = (TextView) findViewById(R.id.descompuestoAuto);
            TextView txt2 = (TextView) findViewById(R.id.perfectoAuto);
            TextView txt3 = (TextView) findViewById(R.id.siniestroAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(txt.getText().toString());
            descompuesto = true;
            perfecto = false;
            siniestro = false;
        } else {
            TextView txt = (TextView) findViewById(R.id.descompuestoAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(null);
            descompuesto = false;
        }
        showButton();
    }

    public void siniestro(View v){
        if(!siniestro) {
            TextView txt = (TextView) findViewById(R.id.siniestroAuto);
            TextView txt2 = (TextView) findViewById(R.id.descompuestoAuto);
            TextView txt3 = (TextView) findViewById(R.id.perfectoAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(txt.getText().toString());
            siniestro = true;
            perfecto = false;
            descompuesto = false;
        } else {
            TextView txt = (TextView) findViewById(R.id.siniestroAuto);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setEstado(null);
            siniestro = false;
        }
        showButton();
    }

    public void ruedasGiran(View v){
        if(!ruedasGiran) {
            TextView txt = (TextView) findViewById(R.id.libreRuedas);
            TextView txt2 = (TextView) findViewById(R.id.faltanRuedas);
            TextView txt3 = (TextView) findViewById(R.id.sinLlaves);
            TextView txt4 = (TextView) findViewById(R.id.fallaMotor);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt4.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setRuedasGiran(true);
            ruedasGiran = true;
        } else {
            TextView txt = (TextView) findViewById(R.id.libreRuedas);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setRuedasGiran(false);
            ruedasGiran = false;
        }
        showButton();
    }

    public void sinRuedas(View v){
        if(!sinRuedas) {
            TextView txt = (TextView) findViewById(R.id.libreRuedas);
            TextView txt2 = (TextView) findViewById(R.id.faltanRuedas);
            TextView txt3 = (TextView) findViewById(R.id.sinLlaves);
            TextView txt4 = (TextView) findViewById(R.id.fallaMotor);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt4.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setSinRuedas(true);
            sinRuedas = true;
        } else {
            TextView txt = (TextView) findViewById(R.id.faltanRuedas);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setSinRuedas(false);
            sinRuedas = false;
        }
        showButton();
    }

    public void sinLlaves(View v){
        if(!sinLlaves) {
            TextView txt = (TextView) findViewById(R.id.libreRuedas);
            TextView txt2 = (TextView) findViewById(R.id.faltanRuedas);
            TextView txt3 = (TextView) findViewById(R.id.sinLlaves);
            TextView txt4 = (TextView) findViewById(R.id.fallaMotor);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            txt4.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setSinLlaves(true);
            sinLlaves = true;
        } else {
            TextView txt = (TextView) findViewById(R.id.sinLlaves);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setSinLlaves(false);
            sinLlaves = false;
        }
        showButton();
    }

    public void fallaMotor(View v){
        if(!fallaMotor) {
            TextView txt = (TextView) findViewById(R.id.libreRuedas);
            TextView txt2 = (TextView) findViewById(R.id.faltanRuedas);
            TextView txt3 = (TextView) findViewById(R.id.sinLlaves);
            TextView txt4 = (TextView) findViewById(R.id.fallaMotor);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt2.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt3.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            txt4.setCompoundDrawablesWithIntrinsicBounds(null, null, img, null);
            c.setFallaMotor(true);
            fallaMotor = true;
        } else {
            TextView txt = (TextView) findViewById(R.id.fallaMotor);
            txt.setCompoundDrawablesWithIntrinsicBounds(null, null, null, null);
            c.setFallaMotor(false);
            fallaMotor = false;
        }
        showButton();
    }
}
