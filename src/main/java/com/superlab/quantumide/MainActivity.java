package com.superlab.quantumide;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.janeasystems.cdv.nodejsmobile.NodeJS;

public class MainActivity extends AppCompatActivity {

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();

        // Enable JavaScript, which is crucial for our terminal and its dependencies.
        webSettings.setJavaScriptEnabled(true);

        // Enable DOM Storage API, needed for some libraries.
        webSettings.setDomStorageEnabled(true);

        // Start the Node.js server in a background thread.
        startNodeJS();

        // Load the local HTML file that will connect to the Node.js server.
        webView.loadUrl("file:///android_asset/index.html");
    }

    private void startNodeJS() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                // This will extract the node project from the APK's assets and run the server.js script.
                NodeJS.startWithScript("var start = require('server.js');");
            }
        }).start();
    }
}
