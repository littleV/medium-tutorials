package com.example.fancy;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;

import com.example.fancylib.UnifiedSDK;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        UnifiedSDK.init(this);
    }
    public void hello(View view) {
        UnifiedSDK.helloWorld();
    }
}
