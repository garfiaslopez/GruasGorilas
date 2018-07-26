package com.example.gargui3.gruasgorilas;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Window;
import android.webkit.WebView;

public class Terminos extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().requestFeature(Window.FEATURE_ACTION_BAR);
        getSupportActionBar().hide();
        setContentView(R.layout.activity_terminos);

        WebView myWebView = (WebView) this.findViewById(R.id.webView);
        myWebView.loadUrl("http://gorilasapp.com.mx/index.php/terms-and-conditions/");

    }
}
