#!/bin/bash

# Clean up previous run
rm -f polyglot_state.yaml guest_config.json orchestrator_thought_log.txt guest_thought_log.txt

# 1. Initialize a new SCM
echo "--- Initializing SCM ---"
sascctl init
if [ $? -ne 0 ]; then
    echo "sascctl init failed"
    exit 1
fi

# 2. Launch the orchestrator and pipe the commands
echo "--- Launching Orchestrator and Agent ---"
echo -e "!launch_agent\n!exit" | python sasc_orchestrator/main.py
if [ $? -ne 0 ]; then
    echo "Orchestrator failed"
    exit 1
fi

# 3. Verify the output logs
echo "--- Verifying Output ---"

# Verify Host Log
if [ ! -f orchestrator_thought_log.txt ]; then
    echo "Host log file not found!"
    exit 1
fi
echo "Host log file content:"
cat orchestrator_thought_log.txt
if ! grep -q "Orchestrator initialized on host: Android 10+ (AArch64)" orchestrator_thought_log.txt; then
    echo "❌ Demo failed: Host log is incorrect."
    exit 1
fi

# Verify Guest Log
if [ ! -f guest_thought_log.txt ]; then
    echo "Guest log file not found!"
    exit 1
fi
echo "Guest log file content:"
cat guest_thought_log.txt
if ! grep -q "Initializing on virtual device: Cuttlefish (x86_64)" guest_thought_log.txt; then
    echo "❌ Demo failed: Guest log is incorrect."
    exit 1
fi

echo "✅ Demo successful: Host and Guest thought logs verified."