package com.example.gargui3.gruasgorilas;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

/**
 * Created by gargui3 on 18/06/16.
 * Clase que sirve para verificaciones de internet
 */
public class Internet {
    public static boolean verificaConexion(Context ctx) {
        if(ctx != null) {
            ConnectivityManager connectivityManager = (ConnectivityManager)
                    ctx.getSystemService(Context.CONNECTIVITY_SERVICE);

            NetworkInfo actNetInfo = connectivityManager.getActiveNetworkInfo();

            return (actNetInfo != null && actNetInfo.isConnected());
        }else{
            return true;
        }
    }
}
