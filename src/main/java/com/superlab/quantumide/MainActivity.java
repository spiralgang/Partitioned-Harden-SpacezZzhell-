package com.superlab.quantumide;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.EditText;
import com.janeasystems.cdv.nodejsmobile.NodeJS;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private EditText urlInput;
    private Button connectButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        urlInput = findViewById(R.id.url_input);
        connectButton = findViewById(R.id.connect_button);

        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);

        // Start the embedded Node.js server in a background thread.
        startNodeJS();

        // Load the local HTML file that contains the terminal UI.
        webView.loadUrl("file:///android_asset/index.html");

        connectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String url = urlInput.getText().toString();
                if (url != null && !url.isEmpty()) {
                    // Call the JavaScript function inside the WebView to connect the terminal.
                    webView.evaluateJavascript("connectToTerminal('" + url + "')", null);
                }
            }
        });
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
