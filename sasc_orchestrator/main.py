import logging
import subprocess

class SascOrchestrator:
    def __init__(self):
        self.logger = self._setup_logger()

    def _setup_logger(self):
        logger = logging.getLogger("OrchestratorThoughtLogger")
        logger.setLevel(logging.INFO)
        handler = logging.FileHandler("orchestrator_thought_log.txt")
        formatter = logging.Formatter('%(asctime)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        return logger

    def run(self):
        print("SASC Orchestrator Initialized. Type '!help' for commands.")
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
            # For now, we just acknowledge natural language input.
            # In the future, this could be sent to a conversational AI.
            self.logger.info(f"THOUGHT: Received natural language input. Acknowledging and waiting for command.")
            print("Natural language input received. Please use '!' for commands.")
            return

        parts = user_input[1:].split()
        command = parts[0]
        args = parts[1:]

        self.logger.info(f"THOUGHT: Parsed command '{command}' with arguments {args}.")

        if command == "help":
            self.show_help()
        elif command == "launch_agent":
            self.launch_agent(args)
        else:
            print(f"Unknown command: {command}")

    def launch_agent(self, args):
        self.logger.info("THOUGHT: Executing `sascctl launch-agent` command.")
        # We can add argument parsing here in the future.
        # For now, we just call the command directly.
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

    def show_help(self):
        print("\nSASC Orchestrator Commands:")
        print("  !help              - Show this help message.")
        print("  !exit / !quit      - Exit the orchestrator.")
        print("  !launch_agent      - Launch a simulated native agent.")
        print("  !get_status        - (Not Implemented) Get the status of running agents.")
        print("")

if __name__ == "__main__":
    orchestrator = SascOrchestrator()
    orchestrator.run()