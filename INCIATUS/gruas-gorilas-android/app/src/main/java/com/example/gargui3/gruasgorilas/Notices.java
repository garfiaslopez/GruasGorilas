package com.example.gargui3.gruasgorilas;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import java.util.ArrayList;

public class Notices extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notices);
        Intent i = getIntent();
        ArrayList<String> notices = i.getStringArrayListExtra("notices");


        ArrayAdapter<String> adaptador =
                new ArrayAdapter<String>(this,
                        android.R.layout.simple_list_item_1, notices);

        ListView lstNotices = (ListView)findViewById(R.id.lstNotices);

        lstNotices.setAdapter(adaptador);
    }
}
