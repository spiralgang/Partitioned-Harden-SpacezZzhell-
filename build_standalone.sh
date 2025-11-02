#!/bin/bash
# build_standalone.sh
# A simple, one-step script to build the Superlab Quantum IDE Android application.
# This script is independent of GitHub Actions and can be run on any machine with
# the Android SDK and Node.js installed.

set -e
echo "Starting standalone Android build..."

# --- Step 1: Install Frontend Dependencies ---
echo "Installing web terminal dependencies..."
(cd web-terminal && npm install)

# --- Step 2: Make Gradle Wrapper Executable ---
echo "Setting Gradle Wrapper permissions..."
chmod +x ./gradlew

# --- Step 3: Run the Gradle Build ---
echo "Building the Android application with Gradle..."
./gradlew :app:assembleDebug

# --- Step 4: Organize the Output ---
echo "Build complete. Organizing output..."
mkdir -p build/outputs/apk/
cp app/build/outputs/apk/debug/app-debug.apk build/outputs/apk/superlab-quantum-debug.apk

echo "--------------------------------------------------"
echo "Success! The APK has been built and is located at:"
echo "build/outputs/apk/superlab-quantum-debug.apk"
echo "--------------------------------------------------"
