# Workorder Processing Pipeline - Mermaid Design

## High-Level Workorder Flow

```mermaid
graph TB
    A[📋 Workorder Created] --> B{Validate Request}
    B --> |✅ Valid| C[🎯 Assign to Bot]
    B --> |❌ Invalid| D[❌ Reject Request]
    
    C --> E[🤖 Bot Accepts Job]
    E --> F[🚀 Start Execution]
    F --> G[📊 Monitor Progress]
    G --> H{Job Status}
    
    H --> |In Progress| G
    H --> |Completed| I[✅ Mark Complete]
    H --> |Failed| J[❌ Handle Failure]
    
    I --> K[📁 Archive Results]
    J --> L{Retry?}
    L --> |Yes| C
    L --> |No| M[❌ Mark Failed]
    
    K --> N[🏁 End Success]
    M --> O[🏁 End Failed]
    D --> P[🏁 End Rejected]
    
    style A fill:#e1f5fe
    style N fill:#c8e6c9
    style O fill:#ffcdd2
    style P fill:#ffcdd2
```

## Bot Partition Management Flow

```mermaid
stateDiagram-v2
    [*] --> Idle : Initialize Bot
    
    Idle --> CreatePartition : startPartition(device)
    CreatePartition --> MountOverlay : partitionCreated()
    CreatePartition --> Error : partitionFailed(error)
    
    MountOverlay --> ConfigurePRoot : overlayMounted()
    MountOverlay --> Error : mountFailed(error)
    
    ConfigurePRoot --> Ready : prootConfigured()
    ConfigurePRoot --> Error : configurationFailed(error)
    
    Ready --> Deploying : deployApplication(app)
    Ready --> Scaling : scalePartition(factor)
    Ready --> Cleanup : stop()
    
    Deploying --> Running : deploymentComplete()
    Deploying --> Error : deploymentFailed(error)
    
    Running --> Updating : updateApplication(app)
    Running --> Stopping : stop()
    Running --> Error : applicationCrashed(error)
    
    Updating --> Running : updateComplete()
    Updating --> Running : updateFailed(error)
    
    Scaling --> Ready : scalingComplete()
    Scaling --> Ready : scalingFailed(error)
    
    Stopping --> Cleanup : stopped()
    Cleanup --> Idle : cleanupComplete()
    Cleanup --> Error : cleanupFailed(error)
    
    Error --> Idle : retry()
    Error --> [*] : abort()
    
    note right of Ready
        Bot is ready to accept
        workorder assignments
    end note
    
    note right of Running
        Executing assigned
        workorder tasks
    end note
```

## Integration Architecture

```mermaid
graph LR
    A[Mermaid Design] --> B[SMC State Machines]
    B --> C[Multi-Language Generation]
    C --> D[MCP Bridge]
    D --> E[Bot Orchestration]
    
    subgraph "SMC Pipeline"
        F[.sm Files] --> G[SMC Compiler]
        G --> H[Kotlin Code]
        G --> I[React Native Bridge]
        G --> J[SQL Backend]
    end
    
    B -.-> F
    
    subgraph "Deployment Targets"
        K[Android Devices]
        L[Mobile Apps]
        M[Enterprise Servers]
        N[Edge Computing]
    end
    
    H --> K
    I --> L
    J --> M
    H --> N
    
    style A fill:#e1f5fe
    style E fill:#c8e6c9
```

This Mermaid design will be converted to SMC state machines for implementation.
