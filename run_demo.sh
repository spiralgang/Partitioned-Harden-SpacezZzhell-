#!/bin/bash

# Clean up previous run
rm -f polyglot_state.yaml agent_config.json demo_thought_log.txt thought_log.txt

# 1. Initialize a new SCM
echo "--- Initializing SCM ---"
sascctl init
if [ $? -ne 0 ]; then
    echo "sascctl init failed"
    exit 1
fi

# 2. Modify the manifest for the demo
echo "--- Modifying SCM for Demo ---"
# Using sed to change the log_file path in the manifest
sed -i 's/thought_log.txt/demo_thought_log.txt/' polyglot_state.yaml

# 3. Launch the agent with the modified SCM
echo "--- Launching Agent ---"
sascctl launch-agent
if [ $? -ne 0 ]; then
    echo "sascctl launch-agent failed"
    exit 1
fi

# 4. Verify the output
echo "--- Verifying Output ---"
if [ ! -f demo_thought_log.txt ]; then
    echo "Demo log file not found!"
    exit 1
fi

echo "Demo log file content:"
cat demo_thought_log.txt

# Check for expected content
if grep -q "Decoding image" demo_thought_log.txt && grep -q "Running inference" demo_thought_log.txt; then
    echo "✅ Demo successful: Thought logs verified."
else
    echo "❌ Demo failed: Thought logs are incorrect."
    exit 1
fi