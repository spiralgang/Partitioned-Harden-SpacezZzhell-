#!/bin/bash
# SMC (State Machine Compiler) Installation and Setup Pipeline
# Integrates with Mermaid Workflow Pipeline for FSM-based workorder jobs

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMC_DIR="$SCRIPT_DIR/smc"
SMC_VERSION="7.3.3"
SMC_URL="https://sourceforge.net/projects/smc/files/SMC/$SMC_VERSION/Smc.jar/download"
WORKFLOWS_DIR="$SCRIPT_DIR/workflows"
FSM_DIR="$SCRIPT_DIR/fsm-generated"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[SMC-INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SMC-SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[SMC-WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[SMC-ERROR]${NC} $1"
}

log_fsm() {
    echo -e "${PURPLE}[FSM]${NC} $1"
}

# Check system requirements
check_requirements() {
    log_info "Checking SMC requirements..."
    
    # Check Java
    if ! command -v java >/dev/null 2>&1; then
        log_error "Java is required for SMC but not installed"
        log_info "Install Java with: apt-get update && apt-get install -y openjdk-11-jdk"
        return 1
    fi
    
    # Check Java version
    # Robust Java version parsing for both old (1.8.0_xx) and new (11.0.1) formats
    java_version_str=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    if [[ "$java_version_str" == 1.* ]]; then
        java_major_version=$(echo "$java_version_str" | cut -d'.' -f2)
    else
        java_major_version=$(echo "$java_version_str" | cut -d'.' -f1)
    fi
    if [ "$java_major_version" -lt 8 ]; then
        log_error "Java 8 or higher required (found Java $java_version_str)"
        return 1
    fi
    
    log_success "Java $java_version_str detected - compatible with SMC"
    
    # Check for other required tools
    local missing_tools=()
    for tool in wget curl unzip; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: apt-get install -y ${missing_tools[*]}"
        return 1
    fi
    
    log_success "All SMC requirements satisfied"
}

# Install SMC
install_smc() {
    log_info "Installing SMC (State Machine Compiler)..."
    
    mkdir -p "$SMC_DIR"
    
    # Download SMC if not already present
    if [ ! -f "$SMC_DIR/smc.jar" ]; then
        log_info "Downloading SMC $SMC_VERSION..."
        
        # Try direct download
        if wget -O "$SMC_DIR/smc.jar" "$SMC_URL" 2>/dev/null; then
            log_success "SMC downloaded successfully"
        else
            log_warning "Direct download failed, trying alternative method..."
            
            # Alternative download using curl
            if curl -L -o "$SMC_DIR/smc.jar" "$SMC_URL" 2>/dev/null; then
                log_success "SMC downloaded successfully (alternative method)"
            else
                log_error "Failed to download SMC. Please download manually from:"
                log_error "https://sourceforge.net/projects/smc/files/"
                return 1
            fi
        fi
    else
        log_info "SMC already installed"
    fi
    
    # Verify SMC installation
    if java -jar "$SMC_DIR/smc.jar" -version >/dev/null 2>&1; then
        log_success "SMC installation verified"
    else
        log_error "SMC installation verification failed"
        return 1
    fi
    
    # Create SMC wrapper script
    cat > "$SMC_DIR/smc" << EOF
#!/bin/bash
# SMC Wrapper Script
java -jar "$SMC_DIR/smc.jar" "\$@"
EOF
    chmod +x "$SMC_DIR/smc"
    
    log_success "SMC wrapper created at $SMC_DIR/smc"
}

# Create FSM directories and structure
setup_fsm_structure() {
    log_info "Setting up FSM project structure..."
    
    mkdir -p "$FSM_DIR"/{state-machines,generated/{kotlin,react-native,sql,cpp,java},templates,workflows}
    
    # Create FSM configuration
    cat > "$FSM_DIR/fsm-config.json" << 'EOF'
{
  "smc_version": "7.3.3",
  "project_name": "PartitionedAndroidVirtualization",
  "supported_languages": [
    "kotlin",
    "react-native", 
    "sql",
    "cpp",
    "java"
  ],
  "default_language": "kotlin",
  "state_machine_dir": "state-machines",
  "output_dir": "generated",
  "template_dir": "templates"
}
EOF

    log_success "FSM project structure created"
}

# Create example state machine templates
create_fsm_templates() {
    log_info "Creating FSM templates for workorder jobs..."
    
    # Android Partition Bot FSM
    cat > "$FSM_DIR/state-machines/AndroidPartitionBot.sm" << 'EOF'
// AndroidPartitionBot.sm - State machine for Android partition management
%class AndroidPartitionBot
%header AndroidPartitionBot.h
%start Idle
%map PartitionMap
%%

Idle {
    startPartition(device: String)
        [device != null]
        CreatePartition {
            initializePartition(device);
        }
    
    startPartition(device: String)
        [device == null]
        Idle {
            logError("Invalid device specified");
        }
    
    shutdown()
        Shutdown {
            cleanup();
        }
}

CreatePartition {
    partitionCreated()
        MountOverlay {
            setupOverlayFS();
        }
    
    partitionFailed(error: String)
        Error {
            handleError(error);
            notifyFailure();
        }
    
    cancel()
        Cleanup {
            removePartialPartition();
        }
}

MountOverlay {
    overlayMounted()
        ConfigurePRoot {
            setupPRootEnvironment();
        }
    
    mountFailed(error: String)
        Error {
            handleError(error);
            unmountPartition();
        }
}

ConfigurePRoot {
    prootConfigured()
        Ready {
            notifyReady();
            startMonitoring();
        }
    
    configurationFailed(error: String)
        Error {
            handleError(error);
            cleanup();
        }
}

Ready {
    deployApplication(app: String)
        Deploying {
            startDeployment(app);
        }
    
    scalePartition(factor: Int)
        Scaling {
            adjustResources(factor);
        }
    
    stop()
        Cleanup {
            stopMonitoring();
            unmountOverlay();
        }
    
    healthCheck()
        Ready {
            reportHealthStatus();
        }
}

Deploying {
    deploymentComplete()
        Running {
            startApplication();
            updateStatus("running");
        }
    
    deploymentFailed(error: String)
        Error {
            handleError(error);
            rollbackDeployment();
        }
}

Running {
    updateApplication(app: String)
        Updating {
            startUpdate(app);
        }
    
    stop()
        Stopping {
            stopApplication();
        }
    
    healthCheck()
        Running {
            reportApplicationHealth();
        }
    
    applicationCrashed(error: String)
        Error {
            handleError(error);
            attemptRestart();
        }
}

Updating {
    updateComplete()
        Running {
            restartApplication();
            updateStatus("updated");
        }
    
    updateFailed(error: String)
        Running {
            rollbackUpdate();
            logError(error);
        }
}

Scaling {
    scalingComplete()
        Ready {
            updateResourceMetrics();
        }
    
    scalingFailed(error: String)
        Ready {
            handleError(error);
            revertScaling();
        }
}

Stopping {
    stopped()
        Cleanup {
            cleanupApplication();
        }
}

Cleanup {
    cleanupComplete()
        Idle {
            resetState();
        }
    
    cleanupFailed(error: String)
        Error {
            forceCleanup();
        }
}

Error {
    retry()
        Idle {
            resetErrorState();
        }
    
    abort()
        Shutdown {
            emergencyShutdown();
        }
}

Shutdown {
    // Terminal state - no transitions
}

%%
EOF

    # Workorder Job FSM
    cat > "$FSM_DIR/state-machines/WorkorderJob.sm" << 'EOF'
// WorkorderJob.sm - State machine for workorder job processing
%class WorkorderJob
%header WorkorderJob.h
%start Pending
%map WorkorderMap
%%

Pending {
    assign(worker: String)
        Assigned {
            assignWorker(worker);
            notifyAssignment();
        }
    
    cancel()
        Cancelled {
            markCancelled();
        }
    
    expire()
        Expired {
            markExpired();
        }
}

Assigned {
    start()
        InProgress {
            beginExecution();
            startTimer();
        }
    
    reassign(worker: String)
        Assigned {
            reassignWorker(worker);
        }
    
    cancel()
        Cancelled {
            notifyWorker();
            markCancelled();
        }
}

InProgress {
    reportProgress(percent: Int)
        InProgress {
            updateProgress(percent);
            notifyProgress();
        }
    
    pause()
        Paused {
            pauseExecution();
        }
    
    complete()
        Completed {
            finalizeJob();
            notifyCompletion();
        }
    
    fail(error: String)
        Failed {
            handleFailure(error);
            notifyFailure();
        }
    
    timeout()
        Failed {
            handleTimeout();
            notifyTimeout();
        }
}

Paused {
    resume()
        InProgress {
            resumeExecution();
        }
    
    cancel()
        Cancelled {
            stopExecution();
            markCancelled();
        }
}

Completed {
    archive()
        Archived {
            moveToArchive();
        }
}

Failed {
    retry()
        Pending {
            resetForRetry();
        }
    
    archive()
        Archived {
            moveToArchive();
        }
}

Cancelled {
    archive()
        Archived {
            moveToArchive();
        }
}

Expired {
    archive()
        Archived {
            moveToArchive();
        }
}

Archived {
    // Terminal state - no transitions
}

%%
EOF

    # MCP Bridge FSM
    cat > "$FSM_DIR/state-machines/MCPBridge.sm" << 'EOF'
// MCPBridge.sm - State machine for MCP (Model Context Protocol) bridge
%class MCPBridge
%header MCPBridge.h
%start Disconnected
%map MCPMap
%%

Disconnected {
    connect(server: String)
        Connecting {
            initiateConnection(server);
        }
}

Connecting {
    connected()
        Connected {
            registerCapabilities();
            startHeartbeat();
        }
    
    connectionFailed(error: String)
        Disconnected {
            handleConnectionError(error);
            scheduleReconnect();
        }
    
    timeout()
        Disconnected {
            handleTimeout();
            scheduleReconnect();
        }
}

Connected {
    receiveCommand(command: String)
        Processing {
            parseCommand(command);
            routeToFSM();
        }
    
    sendResponse(response: String)
        Connected {
            transmitResponse(response);
        }
    
    heartbeatFailed()
        Reconnecting {
            attemptReconnect();
        }
    
    disconnect()
        Disconnected {
            closeConnection();
            stopHeartbeat();
        }
}

Processing {
    commandProcessed(result: String)
        Connected {
            sendResult(result);
        }
    
    commandFailed(error: String)
        Connected {
            sendError(error);
        }
    
    commandTimeout()
        Connected {
            sendTimeout();
        }
}

Reconnecting {
    reconnected()
        Connected {
            restoreSession();
            resumeHeartbeat();
        }
    
    reconnectFailed()
        Disconnected {
            fallbackToPolling();
        }
}

%%
EOF

    log_success "FSM templates created"
}

# Compile FSM to target languages
compile_fsm() {
    local fsm_file="$1"
    local target_language="$2"
    local output_dir="$3"
    
    log_info "Compiling FSM: $(basename "$fsm_file") to $target_language..."
    
    case "$target_language" in
        kotlin)
            "$SMC_DIR/smc" -kotlin -d "$output_dir" "$fsm_file"
            ;;
        java)
            "$SMC_DIR/smc" -java -d "$output_dir" "$fsm_file"
            ;;
        cpp)
            "$SMC_DIR/smc" -c++ -d "$output_dir" "$fsm_file"
            ;;
        *)
            log_error "Unsupported target language: $target_language"
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_success "FSM compiled successfully to $target_language"
    else
        log_error "FSM compilation failed for $target_language"
        return 1
    fi
}

# Generate SQL FSM backend
generate_sql_fsm() {
    local fsm_file="$1"
    local output_dir="$2"
    
    log_info "Generating SQL FSM backend for $(basename "$fsm_file")..."
    
    local fsm_name=$(basename "$fsm_file" .sm)
    local sql_file="$output_dir/${fsm_name}_fsm.sql"
    
    cat > "$sql_file" << EOF
-- SQL FSM Backend for $fsm_name
-- Generated from $fsm_file

-- FSM State Table
CREATE TABLE IF NOT EXISTS ${fsm_name}_states (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    current_state VARCHAR(100) NOT NULL,
    previous_state VARCHAR(100),
    transition_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    context_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FSM Transition Log
CREATE TABLE IF NOT EXISTS ${fsm_name}_transitions (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    from_state VARCHAR(100) NOT NULL,
    to_state VARCHAR(100) NOT NULL,
    event_name VARCHAR(100) NOT NULL,
    event_data JSONB,
    transition_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- FSM Instance Management
CREATE TABLE IF NOT EXISTS ${fsm_name}_instances (
    instance_id VARCHAR(255) PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active',
    metadata JSONB
);

-- Trigger for state updates
CREATE OR REPLACE FUNCTION update_${fsm_name}_state()
RETURNS TRIGGER AS \$\$
BEGIN
    -- Update last activity
    UPDATE ${fsm_name}_instances 
    SET last_activity = CURRENT_TIMESTAMP 
    WHERE instance_id = NEW.instance_id;
    
    -- Log transition
    INSERT INTO ${fsm_name}_transitions (
        instance_id, from_state, to_state, event_name, 
        event_data, transition_time
    ) VALUES (
        NEW.instance_id, OLD.current_state, NEW.current_state,
        COALESCE(NEW.context_data->>'last_event', 'unknown'),
        NEW.context_data, CURRENT_TIMESTAMP
    );
    
    RETURN NEW;
END;
\$\$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS ${fsm_name}_state_change ON ${fsm_name}_states;
CREATE TRIGGER ${fsm_name}_state_change
    BEFORE UPDATE ON ${fsm_name}_states
    FOR EACH ROW
    EXECUTE FUNCTION update_${fsm_name}_state();

-- Helper functions for FSM operations
CREATE OR REPLACE FUNCTION create_${fsm_name}_instance(
    p_instance_id VARCHAR(255),
    p_initial_state VARCHAR(100) DEFAULT 'Idle',
    p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS BOOLEAN AS \$\$
BEGIN
    INSERT INTO ${fsm_name}_instances (instance_id, metadata)
    VALUES (p_instance_id, p_metadata);
    
    INSERT INTO ${fsm_name}_states (instance_id, current_state, context_data)
    VALUES (p_instance_id, p_initial_state, p_metadata);
    
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
\$\$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION transition_${fsm_name}(
    p_instance_id VARCHAR(255),
    p_event VARCHAR(100),
    p_event_data JSONB DEFAULT '{}'::jsonb
) RETURNS BOOLEAN AS \$\$
DECLARE
    current_state_val VARCHAR(100);
    new_state_val VARCHAR(100);
BEGIN
    -- Get current state
    SELECT current_state INTO current_state_val
    FROM ${fsm_name}_states
    WHERE instance_id = p_instance_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Instance % not found', p_instance_id;
    END IF;
    
    -- Determine new state based on current state and event
    -- This would need to be customized based on actual FSM logic
    new_state_val := current_state_val; -- Placeholder
    
    -- Update state
    UPDATE ${fsm_name}_states
    SET current_state = new_state_val,
        previous_state = current_state_val,
        context_data = context_data || p_event_data,
        updated_at = CURRENT_TIMESTAMP
    WHERE instance_id = p_instance_id;
    
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
\$\$ LANGUAGE plpgsql;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_${fsm_name}_states_instance ON ${fsm_name}_states(instance_id);
CREATE INDEX IF NOT EXISTS idx_${fsm_name}_states_current ON ${fsm_name}_states(current_state);
CREATE INDEX IF NOT EXISTS idx_${fsm_name}_transitions_instance ON ${fsm_name}_transitions(instance_id);
CREATE INDEX IF NOT EXISTS idx_${fsm_name}_transitions_time ON ${fsm_name}_transitions(transition_time);
EOF

    log_success "SQL FSM backend generated: $sql_file"
}

# Create MCP-to-SMC bridge script
create_mcp_bridge() {
    log_info "Creating MCP-to-SMC bridge..."
    
    cat > "$FSM_DIR/workflows/mcp_smc_bridge.py" << 'EOF'
#!/usr/bin/env python3
"""
MCP-to-SMC Bridge
Integrates Model Context Protocol with SMC-generated FSMs
"""

import json
import asyncio
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
from pathlib import Path

@dataclass
class FSMInstance:
    """Represents an FSM instance"""
    instance_id: str
    fsm_type: str
    current_state: str
    context: Dict[str, Any]
    created_at: str

class MCPSMCBridge:
    """Bridge between MCP and SMC-generated FSMs"""
    
    def __init__(self, fsm_dir: str):
        self.fsm_dir = Path(fsm_dir)
        self.instances: Dict[str, FSMInstance] = {}
        self.logger = logging.getLogger(__name__)
        
    async def create_fsm_instance(self, fsm_type: str, instance_id: str, 
                                 initial_context: Dict[str, Any] = None) -> bool:
        """Create a new FSM instance"""
        try:
            # Initialize FSM instance
            instance = FSMInstance(
                instance_id=instance_id,
                fsm_type=fsm_type,
                current_state="Idle",  # Default initial state
                context=initial_context or {},
                created_at=str(asyncio.get_event_loop().time())
            )
            
            self.instances[instance_id] = instance
            
            # If SQL backend is available, create database record
            await self._create_sql_instance(instance)
            
            self.logger.info(f"Created FSM instance {instance_id} of type {fsm_type}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to create FSM instance: {e}")
            return False
    
    async def send_event(self, instance_id: str, event: str, 
                        event_data: Dict[str, Any] = None) -> bool:
        """Send event to FSM instance"""
        try:
            if instance_id not in self.instances:
                self.logger.error(f"FSM instance {instance_id} not found")
                return False
            
            instance = self.instances[instance_id]
            
            # Process the event through the appropriate FSM
            success = await self._process_fsm_event(instance, event, event_data or {})
            
            if success:
                self.logger.info(f"Event {event} processed for instance {instance_id}")
            else:
                self.logger.error(f"Failed to process event {event} for instance {instance_id}")
            
            return success
            
        except Exception as e:
            self.logger.error(f"Failed to send event: {e}")
            return False
    
    async def get_instance_state(self, instance_id: str) -> Optional[Dict[str, Any]]:
        """Get current state of FSM instance"""
        if instance_id not in self.instances:
            return None
        
        instance = self.instances[instance_id]
        return {
            "instance_id": instance.instance_id,
            "fsm_type": instance.fsm_type,
            "current_state": instance.current_state,
            "context": instance.context
        }
    
    async def _process_fsm_event(self, instance: FSMInstance, event: str, 
                                event_data: Dict[str, Any]) -> bool:
        """Process event through SMC-generated FSM"""
        try:
            # This would interface with the actual SMC-generated code
            # For now, we'll simulate the state transition logic
            
            # Update instance context with event data
            instance.context.update(event_data)
            instance.context["last_event"] = event
            
            # Simulate state transition based on current state and event
            new_state = self._calculate_next_state(instance.current_state, event, instance.fsm_type)
            
            if new_state != instance.current_state:
                old_state = instance.current_state
                instance.current_state = new_state
                
                # Log transition
                await self._log_transition(instance, old_state, new_state, event, event_data)
                
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to process FSM event: {e}")
            return False
    
    def _calculate_next_state(self, current_state: str, event: str, fsm_type: str) -> str:
        """Calculate next state based on FSM logic"""
        # This is a simplified state transition logic
        # In practice, this would use the SMC-generated code
        
        if fsm_type == "AndroidPartitionBot":
            return self._android_partition_transitions(current_state, event)
        elif fsm_type == "WorkorderJob":
            return self._workorder_transitions(current_state, event)
        elif fsm_type == "MCPBridge":
            return self._mcp_bridge_transitions(current_state, event)
        
        return current_state  # No transition
    
    def _android_partition_transitions(self, current_state: str, event: str) -> str:
        """Android Partition Bot state transitions"""
        transitions = {
            ("Idle", "startPartition"): "CreatePartition",
            ("CreatePartition", "partitionCreated"): "MountOverlay",
            ("CreatePartition", "partitionFailed"): "Error",
            ("MountOverlay", "overlayMounted"): "ConfigurePRoot",
            ("MountOverlay", "mountFailed"): "Error",
            ("ConfigurePRoot", "prootConfigured"): "Ready",
            ("ConfigurePRoot", "configurationFailed"): "Error",
            ("Ready", "deployApplication"): "Deploying",
            ("Ready", "scalePartition"): "Scaling",
            ("Ready", "stop"): "Cleanup",
            ("Deploying", "deploymentComplete"): "Running",
            ("Deploying", "deploymentFailed"): "Error",
            ("Running", "updateApplication"): "Updating",
            ("Running", "stop"): "Stopping",
            ("Running", "applicationCrashed"): "Error",
            ("Updating", "updateComplete"): "Running",
            ("Updating", "updateFailed"): "Running",
            ("Scaling", "scalingComplete"): "Ready",
            ("Scaling", "scalingFailed"): "Ready",
            ("Stopping", "stopped"): "Cleanup",
            ("Cleanup", "cleanupComplete"): "Idle",
            ("Cleanup", "cleanupFailed"): "Error",
            ("Error", "retry"): "Idle",
            ("Error", "abort"): "Shutdown"
        }
        
        return transitions.get((current_state, event), current_state)
    
    def _workorder_transitions(self, current_state: str, event: str) -> str:
        """Workorder Job state transitions"""
        transitions = {
            ("Pending", "assign"): "Assigned",
            ("Pending", "cancel"): "Cancelled",
            ("Pending", "expire"): "Expired",
            ("Assigned", "start"): "InProgress",
            ("Assigned", "reassign"): "Assigned",
            ("Assigned", "cancel"): "Cancelled",
            ("InProgress", "pause"): "Paused",
            ("InProgress", "complete"): "Completed",
            ("InProgress", "fail"): "Failed",
            ("InProgress", "timeout"): "Failed",
            ("Paused", "resume"): "InProgress",
            ("Paused", "cancel"): "Cancelled",
            ("Completed", "archive"): "Archived",
            ("Failed", "retry"): "Pending",
            ("Failed", "archive"): "Archived",
            ("Cancelled", "archive"): "Archived",
            ("Expired", "archive"): "Archived"
        }
        
        return transitions.get((current_state, event), current_state)
    
    def _mcp_bridge_transitions(self, current_state: str, event: str) -> str:
        """MCP Bridge state transitions"""
        transitions = {
            ("Disconnected", "connect"): "Connecting",
            ("Connecting", "connected"): "Connected",
            ("Connecting", "connectionFailed"): "Disconnected",
            ("Connecting", "timeout"): "Disconnected",
            ("Connected", "receiveCommand"): "Processing",
            ("Connected", "heartbeatFailed"): "Reconnecting",
            ("Connected", "disconnect"): "Disconnected",
            ("Processing", "commandProcessed"): "Connected",
            ("Processing", "commandFailed"): "Connected",
            ("Processing", "commandTimeout"): "Connected",
            ("Reconnecting", "reconnected"): "Connected",
            ("Reconnecting", "reconnectFailed"): "Disconnected"
        }
        
        return transitions.get((current_state, event), current_state)
    
    async def _create_sql_instance(self, instance: FSMInstance):
        """Create SQL database record for FSM instance"""
        # This would connect to the SQL database and create the instance
        # For now, we'll just log it
        self.logger.info(f"Would create SQL instance for {instance.instance_id}")
    
    async def _log_transition(self, instance: FSMInstance, old_state: str, 
                             new_state: str, event: str, event_data: Dict[str, Any]):
        """Log state transition"""
        self.logger.info(f"FSM {instance.instance_id}: {old_state} -> {new_state} (event: {event})")

# Example usage
async def main():
    bridge = MCPSMCBridge("/path/to/fsm")
    
    # Create Android Partition Bot instance
    await bridge.create_fsm_instance("AndroidPartitionBot", "bot-001")
    
    # Send events
    await bridge.send_event("bot-001", "startPartition", {"device": "SM-G965U1"})
    await bridge.send_event("bot-001", "partitionCreated")
    await bridge.send_event("bot-001", "overlayMounted")
    await bridge.send_event("bot-001", "prootConfigured")
    
    # Check state
    state = await bridge.get_instance_state("bot-001")
    print(f"Current state: {state}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(main())
EOF

    chmod +x "$FSM_DIR/workflows/mcp_smc_bridge.py"
    log_success "MCP-to-SMC bridge created"
}

# Create workflow compilation script
create_compile_workflow() {
    log_info "Creating SMC compilation workflow..."
    
    cat > "$WORKFLOWS_DIR/compile_smc.sh" << 'EOF'
#!/bin/bash
# SMC Compilation Workflow
# Compiles all state machines to target languages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FSM_DIR="$PROJECT_ROOT/fsm-generated"
SMC_DIR="$PROJECT_ROOT/smc"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[COMPILE]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Compile all FSMs to all supported languages
compile_all_fsms() {
    local languages=("kotlin" "java" "cpp")
    
    log_info "Compiling all FSMs to supported languages..."
    
    # Find all .sm files
    while IFS= read -r -d '' sm_file; do
        local fsm_name=$(basename "$sm_file" .sm)
        log_info "Processing $fsm_name..."
        
        # Compile to each language
        for lang in "${languages[@]}"; do
            local output_dir="$FSM_DIR/generated/$lang"
            mkdir -p "$output_dir"
            
            log_info "  Compiling to $lang..."
            if "$SMC_DIR/smc" -"$lang" -d "$output_dir" "$sm_file"; then
                log_success "  $lang compilation successful"
            else
                log_error "  $lang compilation failed"
            fi
        done
        
        # Generate SQL backend
        log_info "  Generating SQL backend..."
        "$PROJECT_ROOT/smc_pipeline.sh" generate-sql "$sm_file" "$FSM_DIR/generated/sql"
        
    done < <(find "$FSM_DIR/state-machines" -name "*.sm" -print0)
}

# Generate documentation
generate_docs() {
    log_info "Generating FSM documentation..."
    
    local doc_dir="$FSM_DIR/docs"
    mkdir -p "$doc_dir"
    
    # Generate GraphViz diagrams
    while IFS= read -r -d '' sm_file; do
        local fsm_name=$(basename "$sm_file" .sm)
        local dot_file="$doc_dir/${fsm_name}.dot"
        local png_file="$doc_dir/${fsm_name}.png"
        
        log_info "Generating diagram for $fsm_name..."
        
        if "$SMC_DIR/smc" -graph -d "$doc_dir" "$sm_file"; then
            # Convert to PNG if graphviz is available
            if command -v dot >/dev/null 2>&1; then
                dot -Tpng "$dot_file" -o "$png_file"
                log_success "Generated diagram: $png_file"
            fi
        fi
        
    done < <(find "$FSM_DIR/state-machines" -name "*.sm" -print0)
}

# Main execution
main() {
    case "${1:-all}" in
        compile)
            compile_all_fsms
            ;;
        docs)
            generate_docs
            ;;
        all)
            compile_all_fsms
            generate_docs
            ;;
        *)
            echo "Usage: $0 {compile|docs|all}"
            exit 1
            ;;
    esac
}

main "$@"
EOF

    chmod +x "$WORKFLOWS_DIR/compile_smc.sh"
    log_success "SMC compilation workflow created"
}

# Integration with existing workflow system
integrate_with_mermaid() {
    log_info "Integrating SMC with Mermaid workflow system..."
    
    # Add SMC compilation step to workflow generator
    cat >> "$SCRIPT_DIR/workflow_prompt_generator.sh" << 'EOF'

# Generate SMC FSM workflow prompts
generate_smc_prompts() {
    local fsm_type="${1:-workorder}"
    local language="${2:-kotlin}"
    local complexity="${3:-medium}"
    
    log_info "Generating SMC FSM workflow prompts..."
    
    cat > "$PROMPTS_DIR/smc_fsm_${fsm_type}_${language}.md" << PROMPT_EOF
# SMC FSM Workflow Prompts: $fsm_type in $language

## FSM Design Prompt
\`\`\`
Design a finite state machine for $fsm_type processing:

FSM Type: $fsm_type
Target Language: $language
Complexity: $complexity

Create state machine specification covering:
1. State definitions and initial state
2. Event-driven transitions
3. Guard conditions and actions
4. Error handling and recovery
5. Integration with MCP bridge

Include specific SMC .sm file syntax and compilation steps.
\`\`\`

## Multi-Language Integration Prompt
\`\`\`
Integrate SMC-generated FSM with multi-language system:

Primary Language: $language
FSM Type: $fsm_type
Complexity: $complexity

Design integration for:
1. Kotlin Native and Multiplatform
2. React Native bridge (via Kotlin)
3. SQL persistent backend
4. MCP communication layer

Provide code examples and integration patterns.
\`\`\`

## Workflow Orchestration Prompt
\`\`\`
Create workflow orchestration using SMC FSMs:

FSM Type: $fsm_type
Language: $language
Scale: $complexity

Design orchestration covering:
1. FSM instance lifecycle management
2. Event routing and handling
3. State persistence and recovery
4. Inter-FSM communication
5. Performance monitoring

Include deployment and scaling strategies.
\`\`\`

Generated: $(date)
FSM Type: $fsm_type
Language: $language
Complexity: $complexity
PROMPT_EOF

    log_success "SMC FSM prompts generated: $PROMPTS_DIR/smc_fsm_${fsm_type}_${language}.md"
}
EOF

    log_success "SMC integration with Mermaid workflow system completed"
}

# Main function
main() {
    case "${1:-help}" in
        install)
            check_requirements
            install_smc
            setup_fsm_structure
            create_fsm_templates
            create_mcp_bridge
            create_compile_workflow
            integrate_with_mermaid
            log_success "SMC pipeline installation completed!"
            ;;
        compile)
            shift
            local fsm_file="${1:-$FSM_DIR/state-machines/AndroidPartitionBot.sm}"
            local language="${2:-kotlin}"
            local output_dir="${3:-$FSM_DIR/generated/$language}"
            compile_fsm "$fsm_file" "$language" "$output_dir"
            ;;
        generate-sql)
            shift
            local fsm_file="${1:-$FSM_DIR/state-machines/AndroidPartitionBot.sm}"
            local output_dir="${2:-$FSM_DIR/generated/sql}"
            mkdir -p "$output_dir"
            generate_sql_fsm "$fsm_file" "$output_dir"
            ;;
        test)
            log_info "Testing SMC installation..."
            if [ -f "$SMC_DIR/smc.jar" ]; then
                java -jar "$SMC_DIR/smc.jar" -version
                log_success "SMC is working correctly"
            else
                log_error "SMC not installed. Run: $0 install"
                exit 1
            fi
            ;;
        status)
            log_info "SMC Pipeline Status:"
            echo "SMC Installation: $([ -f "$SMC_DIR/smc.jar" ] && echo "✅ Installed" || echo "❌ Not installed")"
            echo "FSM Templates: $([ -d "$FSM_DIR/state-machines" ] && echo "✅ Available" || echo "❌ Missing")"
            echo "Generated Code: $([ -d "$FSM_DIR/generated" ] && echo "✅ Directory exists" || echo "❌ Missing")"
            echo "MCP Bridge: $([ -f "$FSM_DIR/workflows/mcp_smc_bridge.py" ] && echo "✅ Available" || echo "❌ Missing")"
            ;;
        help|*)
            echo "SMC (State Machine Compiler) Integration Pipeline"
            echo
            echo "Integrates SMC with the Mermaid workflow system for FSM-based"
            echo "workorder jobs across multiple languages (Kotlin, React Native, SQL)."
            echo
            echo "Usage: $0 {command} [parameters]"
            echo
            echo "Commands:"
            echo "  install                  - Install SMC and setup FSM project structure"
            echo "  compile [fsm] [lang] [out] - Compile specific FSM to target language"
            echo "  generate-sql [fsm] [out] - Generate SQL backend for FSM"
            echo "  test                     - Test SMC installation"
            echo "  status                   - Show SMC pipeline status"
            echo
            echo "Examples:"
            echo "  $0 install"
            echo "  $0 compile AndroidPartitionBot.sm kotlin ./generated/kotlin"
            echo "  $0 generate-sql WorkorderJob.sm ./generated/sql"
            echo
            echo "Integration with Mermaid workflows:"
            echo "  - SMC FSMs are generated after Mermaid workflow creation"
            echo "  - MCP bridge enables command routing to FSM instances"
            echo "  - Multi-language support for edge computing bot orchestration"
            ;;
    esac
}

# Run main function
main "$@"