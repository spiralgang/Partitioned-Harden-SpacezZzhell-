import logging
import subprocess
import vertexai
from vertexai.generative_models import GenerativeModel

# --- Configuration ---
# IMPORTANT: You must replace these with your actual project details.
GCP_PROJECT_ID = "your-gcp-project-id"
GCP_LOCATION = "us-central1"
GEMMA_MODEL_NAME = "gemma-2b"

class SascOrchestrator:
    def __init__(self):
        self.logger = self._setup_logger()
        self._initialize_vertex_ai()

    def _setup_logger(self):
        logger = logging.getLogger("OrchestratorThoughtLogger")
        logger.setLevel(logging.INFO)
        handler = logging.FileHandler("orchestrator_thought_log.txt")
        formatter = logging.Formatter('%(asctime)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def _initialize_vertex_ai(self):
        try:
            vertexai.init(project=GCP_PROJECT_ID, location=GCP_LOCATION)
            self.gemma_model = GenerativeModel(GEMMA_MODEL_NAME)
            self.logger.info(f"THOUGHT: Successfully initialized Vertex AI for project '{GCP_PROJECT_ID}' and model '{GEMMA_MODEL_NAME}'.")
        except Exception as e:
            print(f"Error initializing Vertex AI: {e}")
            print("Please ensure you have authenticated with `gcloud auth application-default login` and set the correct project ID.")
            self.logger.error(f"ERROR: Failed to initialize Vertex AI: {e}")
            self.gemma_model = None

    def run(self):
        print("SASC Orchestrator Initialized. Type a prompt for Gemma, or '!help' for commands.")
        while True:
            try:
                user_input = input(">> ")
                if user_input.lower() in ['!exit', '!quit']:
                    print("Exiting SASC Orchestrator.")
                    break
                self.process_input(user_input)
            except KeyboardInterrupt:
                print("\nExiting SASC Orchestrator.")
                break

    def process_input(self, user_input):
        if not user_input.startswith('!'):
            self.invoke_gemma_model(user_input)
            return

        parts = user_input[1:].split()
        command = parts[0]
        args = parts[1:]

        self.logger.info(f"THOUGHT: Parsed command '{command}' with arguments {args}.")

        if command == "help":
            self.show_help()
        elif command == "launch_agent":
            self.launch_agent(args)
        elif command == "qwen":
            self.invoke_qwen_local_mock(" ".join(args))
        else:
            print(f"Unknown command: {command}")

    def invoke_gemma_model(self, prompt):
        self.logger.info(f"THOUGHT: Received natural language prompt. Invoking Gemma on Vertex AI.")
        if not self.gemma_model:
            print("Vertex AI is not initialized. Cannot process prompt.")
            return

        try:
            print("...Asking Gemma...")
            response = self.gemma_model.generate_content(prompt)
            print("\n--- Gemma's Response ---")
            print(response.text)
            print("------------------------\n")
            self.logger.info(f"SUCCESS: Received response from Gemma.")
        except Exception as e:
            print(f"Error invoking Gemma model: {e}")
            self.logger.error(f"ERROR: Failed to invoke Gemma model: {e}")

    def launch_agent(self, args):
        self.logger.info("THOUGHT: Executing `sascctl launch-agent` command.")
        try:
            result = subprocess.run(["sascctl", "launch-agent"], capture_output=True, text=True, check=True)
            print("--- Agent Output ---")
            print(result.stdout)
            print("--------------------")
            self.logger.info(f"SUCCESS: `sascctl launch-agent` executed successfully.")
        except FileNotFoundError:
            print("Error: `sascctl` command not found. Make sure it is installed and in your PATH.")
            self.logger.error("ERROR: `sascctl` command not found.")
        except subprocess.CalledProcessError as e:
            print(f"Error executing `sascctl launch-agent`:")
            print(e.stderr)
            self.logger.error(f"ERROR: `sascctl launch-agent` failed with stderr:\n{e.stderr}")

    def invoke_qwen_local_mock(self, prompt):
        self.logger.info(f"THOUGHT: Invoking local Qwen-Coder via MLC LLM (mock). Prompt: '{prompt}'")
        print("\n--- Qwen-Coder (Mock) Response ---")
        mock_response = """
```python
def sort_and_filter(data, filter_threshold=10):
    \"\"\"
    Sorts a list of numbers and filters out values below a threshold.
    This is a mock response from Qwen-Coder.
    \"\"\"
    sorted_data = sorted(data)
    filtered_data = [x for x in sorted_data if x >= filter_threshold]
    return filtered_data
```
"""
        print(mock_response)
        print("----------------------------------\n")
        self.logger.info("SUCCESS: Received mock response from Qwen-Coder.")

    def show_help(self):
        print("\nSASC Orchestrator Commands:")
        print("  !help              - Show this help message.")
        print("  !exit / !quit      - Exit the orchestrator.")
        print("  !launch_agent      - Launch a simulated native agent (Workforce Layer).")
        print("  !qwen <prompt>     - Send a prompt to the local Qwen-Coder model (mock).")
        print("  <prompt>           - Send a natural language prompt to Gemma on Vertex AI.")
        print("")

if __name__ == "__main__":
    orchestrator = SascOrchestrator()
    orchestrator.run()