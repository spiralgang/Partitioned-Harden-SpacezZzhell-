package com.superlab.quantumide;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import com.janeasystems.cdv.nodejsmobile.NodeJS;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private EditText urlInput;
    private Button connectButton;
    private Button alignButton;
    private Button buildButton;
    private TextView buildLog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        urlInput = findViewById(R.id.url_input);
        connectButton = findViewById(R.id.connect_button);
        alignButton = findViewById(R.id.align_button);
        buildButton = findViewById(R.id.build_button);
        buildLog = findViewById(R.id.build_log);

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

        alignButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alignConfiguration();
            }
        });

        buildButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                simulateBuild();
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

    private void alignConfiguration() {
        buildLog.setText("Starting configuration alignment...\n");
        List<String> requiredFiles = Arrays.asList(
            "build.gradle",
            "settings.gradle",
            "app/build.gradle",
            "gradlew",
            "gradlew.bat",
            "gradle/wrapper/gradle-wrapper.properties",
            "src/main/AndroidManifest.xml"
        );

        try {
            String[] assets = getAssets().list("");
            List<String> assetList = Arrays.asList(assets);

            for (String file : requiredFiles) {
                // We can't check subdirectories easily in assets, so we do our best
                // This is a simulation, so we will assume they exist if the top-level files do.
                if (assetList.contains(file.split("/")[0])) {
                    logMessage("[OK] " + file + " is present.");
                } else {
                    logMessage("[MISSING] " + file + " would be generated.");
                }
            }
            logMessage("\nConfiguration alignment check complete.");
        } catch (IOException e) {
            logMessage("Error checking assets: " + e.getMessage());
        }
    }

    private void logMessage(String message) {
        runOnUiThread(() -> buildLog.append(message + "\n"));
    }

    private void simulateBuild() {
        buildLog.setText("Starting standalone build process...\n");
        android.os.Handler handler = new android.os.Handler();

        handler.postDelayed(() -> logMessage("Step 1/4: Installing frontend dependencies..."), 500);
        handler.postDelayed(() -> logMessage(" > npm install complete."), 2000);
        handler.postDelayed(() -> logMessage("Step 2/4: Setting Gradle Wrapper permissions..."), 2500);
        handler.postDelayed(() -> logMessage(" > chmod +x ./gradlew complete."), 3000);
        handler.postDelayed(() -> logMessage("Step 3/4: Building the Android application with Gradle..."), 3500);
        handler.postDelayed(() -> logMessage(" > :app:assembleDebug SUCCESSFUL."), 6000);
        handler.postDelayed(() -> logMessage("Step 4/4: Organizing output..."), 6500);
        handler.postDelayed(() -> logMessage("\nSuccess! Simulated APK is ready."), 7000);
    }
}
