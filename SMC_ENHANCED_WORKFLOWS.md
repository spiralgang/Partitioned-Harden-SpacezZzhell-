# SMC-Enhanced Mermaid Workflow Integration

## Overview

This document extends the Mermaid Workflow Pipeline to include SMC (State Machine Compiler) integration for generating FSM-based workorder jobs. This creates a complete workflow from Mermaid visualization to executable FSM code across multiple languages.

## Enhanced Workflow: Mermaid → SMC → Multi-Language FSM

```mermaid
graph TB
    A[Mermaid Workflow Creation] --> B[SMC State Machine Definition]
    B --> C[SMC Compilation Pipeline]
    C --> D{Target Language}
    
    D --> |Kotlin| E[Kotlin Native FSM]
    D --> |React Native| F[React Native Bridge]
    D --> |SQL| G[SQL Persistent Backend]
    D --> |C++| H[C++ High-Performance FSM]
    D --> |Java| I[Java Enterprise FSM]
    
    E --> J[MCP Bridge Integration]
    F --> J
    G --> J
    H --> J
    I --> J
    
    J --> K[Workorder Job Orchestration]
    K --> L[Edge Computing Bot Army]
    
    subgraph "SMC FSM Generation"
        M[.sm Files] --> N[SMC Compiler]
        N --> O[Generated Code]
        N --> P[State Diagrams]
        N --> Q[Documentation]
    end
    
    B -.-> M
    C -.-> N
    
    subgraph "Multi-Language Integration"
        R[Kotlin Multiplatform] --> S[React Native Bridge]
        S --> T[JavaScript Interface]
        R --> U[SQL Backend]
        U --> V[Persistent State]
    end
    
    E -.-> R
    F -.-> S
    G -.-> U
    
    style A fill:#e1f5fe
    style L fill:#c8e6c9
    style M fill:#fff3e0
    style O fill:#fff3e0
```

## SMC-Enhanced Implementation Pipeline

```mermaid
flowchart TD
    Start([🚀 Begin Enhanced Implementation]) --> MermaidDesign[📊 Create Mermaid Workflows]
    
    MermaidDesign --> FSMDesign[🎯 Design State Machines]
    FSMDesign --> SMCInstall{SMC Installed?}
    
    SMCInstall --> |❌ No| InstallSMC[📥 Install SMC Pipeline]
    SMCInstall --> |✅ Yes| CreateSM[📝 Create .sm Files]
    InstallSMC --> CreateSM
    
    CreateSM --> ValidateSM{Validate SM Files}
    ValidateSM --> |❌ Invalid| FixSM[🔧 Fix State Machine]
    ValidateSM --> |✅ Valid| CompileSMC[⚙️ Compile with SMC]
    FixSM --> ValidateSM
    
    CompileSMC --> MultiLangGen[🔄 Multi-Language Generation]
    
    subgraph MultiLangGen[Multi-Language Code Generation]
        ML1[Generate Kotlin Code] --> ML2[Generate React Native Bridge]
        ML2 --> ML3[Generate SQL Backend]
        ML3 --> ML4[Generate C++ Performance Code]
        ML4 --> ML5[Generate Java Enterprise Code]
    end
    
    ML5 --> MCPIntegration[🌉 MCP Bridge Setup]
    
    subgraph MCPIntegration[MCP Bridge Integration]
        MCP1[Initialize MCP Bridge] --> MCP2[Configure FSM Routing]
        MCP2 --> MCP3[Setup Event Handlers]
        MCP3 --> MCP4[Test Communication]
    end
    
    MCP4 --> WorkorderSetup[📋 Workorder Job Setup]
    
    subgraph WorkorderSetup[Workorder Job Configuration]
        WO1[Define Job Templates] --> WO2[Configure Orchestration]
        WO2 --> WO3[Setup State Persistence]
        WO3 --> WO4[Configure Error Handling]
    end
    
    WO4 --> TestIntegration{🧪 Test Integration}
    TestIntegration --> |❌ Failed| Debug[🐛 Debug Issues]
    TestIntegration --> |✅ Success| DeployBots[🤖 Deploy Bot Army]
    Debug --> MCPIntegration
    
    DeployBots --> Monitor[📊 Monitor & Orchestrate]
    
    subgraph Monitor[Monitoring & Orchestration]
        MON1[FSM State Monitoring] --> MON2[Performance Metrics]
        MON2 --> MON3[Error Tracking]
        MON3 --> MON4[Auto-scaling]
    end
    
    MON4 --> Production[🏭 Production Bot Army]
    
    style Start fill:#4caf50,color:#fff
    style Production fill:#2196f3,color:#fff
    style SMCInstall fill:#ff9800,color:#fff
    style TestIntegration fill:#ff9800,color:#fff
```

## FSM Workorder Job Pipeline

```mermaid
stateDiagram-v2
    [*] --> Pending : Create Workorder
    
    Pending --> Assigned : assign(worker)
    Pending --> Cancelled : cancel()
    Pending --> Expired : expire()
    
    Assigned --> InProgress : start()
    Assigned --> Assigned : reassign(worker)
    Assigned --> Cancelled : cancel()
    
    InProgress --> InProgress : reportProgress(%)
    InProgress --> Paused : pause()
    InProgress --> Completed : complete()
    InProgress --> Failed : fail(error)
    InProgress --> Failed : timeout()
    
    Paused --> InProgress : resume()
    Paused --> Cancelled : cancel()
    
    Completed --> Archived : archive()
    Failed --> Pending : retry()
    Failed --> Archived : archive()
    Cancelled --> Archived : archive()
    Expired --> Archived : archive()
    
    Archived --> [*]
    
    note right of InProgress
        This state integrates with
        Android Partition Bot FSM
        for actual work execution
    end note
    
    note right of Completed
        Triggers cleanup and
        resource deallocation
        via MCP bridge
    end note
```

## MCP-to-SMC Integration Architecture

```mermaid
graph LR
    A[Gemini CLI] --> B[MCP Server]
    B --> C[MCP Bridge FSM]
    C --> D[Event Router]
    
    D --> E[Android Partition Bot FSM]
    D --> F[Workorder Job FSM]
    D --> G[Resource Manager FSM]
    
    E --> H[Kotlin Native Implementation]
    F --> I[React Native Bridge]
    G --> J[SQL Persistent Backend]
    
    H --> K[Android Device]
    I --> L[Mobile App]
    J --> M[Database]
    
    subgraph "FSM State Persistence"
        N[PostgreSQL] --> O[State Tables]
        O --> P[Transition Logs]
        P --> Q[Instance Management]
    end
    
    J -.-> N
    
    subgraph "Event Flow"
        R[Command] --> S[Parse]
        S --> T[Route to FSM]
        T --> U[Execute Transition]
        U --> V[Update State]
        V --> W[Persist]
        W --> X[Respond]
    end
    
    B -.-> R
    X -.-> B
    
    style A fill:#4caf50,color:#fff
    style K fill:#2196f3,color:#fff
    style L fill:#2196f3,color:#fff
    style M fill:#2196f3,color:#fff
```

## Multi-Language FSM Integration

```mermaid
graph TB
    SMC[SMC Compiler] --> KotlinGen[Kotlin Code Generation]
    SMC --> JavaGen[Java Code Generation]
    SMC --> CppGen[C++ Code Generation]
    SMC --> SQLGen[SQL Backend Generation]
    
    KotlinGen --> KMP[Kotlin Multiplatform]
    KMP --> Android[Android Implementation]
    KMP --> RNBridge[React Native Bridge]
    
    JavaGen --> Enterprise[Enterprise Integration]
    CppGen --> Performance[High-Performance Modules]
    SQLGen --> Persistence[State Persistence]
    
    RNBridge --> JS[JavaScript Interface]
    JS --> ReactNative[React Native App]
    
    Android --> Device1[Edge Device 1]
    ReactNative --> Device2[Edge Device 2]
    Enterprise --> Server[Enterprise Server]
    Performance --> HPC[HPC Cluster]
    Persistence --> DB[(Database)]
    
    subgraph "Shared FSM Logic"
        FSMCore[FSM Core Logic]
        States[State Definitions]
        Transitions[Transition Rules]
        Events[Event Handling]
    end
    
    SMC -.-> FSMCore
    KotlinGen -.-> States
    JavaGen -.-> Transitions
    CppGen -.-> Events
    
    style SMC fill:#4caf50,color:#fff
    style Device1 fill:#2196f3,color:#fff
    style Device2 fill:#2196f3,color:#fff
    style Server fill:#2196f3,color:#fff
    style HPC fill:#2196f3,color:#fff
    style DB fill:#2196f3,color:#fff
```

## Workflow Generation Commands

### Enhanced Workflow Prompt Generator

The existing `workflow_prompt_generator.sh` is extended with SMC capabilities:

```bash
# Generate SMC FSM workflows
./workflow_prompt_generator.sh smc workorder kotlin medium
./workflow_prompt_generator.sh smc android-partition react-native high
./workflow_prompt_generator.sh smc mcp-bridge sql enterprise

# Generate complete Mermaid + SMC workflows
./workflow_prompt_generator.sh enhanced-all workorder-orchestration
```

### SMC Pipeline Commands

```bash
# Install SMC and setup FSM structure
./smc_pipeline.sh install

# Compile specific FSMs
./smc_pipeline.sh compile AndroidPartitionBot.sm kotlin
./smc_pipeline.sh compile WorkorderJob.sm react-native
./smc_pipeline.sh generate-sql MCPBridge.sm

# Test installation
./smc_pipeline.sh test
./smc_pipeline.sh status
```

### Workflow Compilation Commands

```bash
# Compile all FSMs to all languages
./workflows/compile_smc.sh all

# Generate documentation and diagrams
./workflows/compile_smc.sh docs

# Compile only FSM code
./workflows/compile_smc.sh compile
```

## Integration Benefits

### 1. **Language-Agnostic State Management**
- Single `.sm` file generates code for all target languages
- Consistent FSM behavior across platforms
- Centralized state logic maintenance

### 2. **MCP Bridge Integration**
- Seamless command routing from Gemini CLI
- Event-driven FSM transitions
- Persistent state management

### 3. **Multi-Platform Deployment**
- Kotlin Native for Android devices
- React Native for cross-platform mobile
- SQL backend for enterprise persistence
- C++ modules for high-performance computing

### 4. **Workorder Job Orchestration**
- FSM-driven job lifecycle management
- Automatic state transitions and error handling
- Resource allocation and cleanup

### 5. **Edge Computing Bot Army**
- Distributed FSM instances across devices
- Coordinated state management
- Fault-tolerant operation

## Example Usage Scenario

1. **Design Phase**: Create Mermaid workflows for partition management
2. **FSM Definition**: Define `.sm` files for workorder processing
3. **Code Generation**: Compile FSMs to Kotlin, React Native, and SQL
4. **MCP Integration**: Deploy MCP bridge for command handling
5. **Bot Deployment**: Deploy FSM instances to edge devices
6. **Orchestration**: Coordinate workorder jobs across bot army
7. **Monitoring**: Track FSM states and performance metrics

This enhanced workflow system provides a complete pipeline from visual design through executable, distributed FSM implementations for robust edge computing orchestration.