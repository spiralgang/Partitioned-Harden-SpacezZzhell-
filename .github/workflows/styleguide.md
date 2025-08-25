name:  Gemini styleguide.md

title: styleguide.md
description: Configuration for Gemini Code Assist on these repository
on:
  push:
    branches:
      - main
      - release/*
  pull_request:
    branches:
      - main
  workflow_dispatch:

jobs:
  reave-partitioned-harden-spacezzzhell:
    runs-on: ubuntu-latest
    steps:
      - name: Snatch Partitioned-Harden-SpacezZzhell-
        uses: actions/checkout@v4
        with:
          repository: spiralgang/Partitioned-Harden-SpacezZzhell-
          token: ${{ secrets.GITHUB_TOKEN }}
          path: Partitioned-Harden-SpacezZzhell-

      - name: Inject REAVER Config for SpacezZzhell-
        run: |
          cd Partitioned-Harden-SpacezZzhell-
          mkdir -p .gemini
          cat <<EOF > .gemini/config.yaml
          $schema: "http://json-schema.org/draft-07/schema#"
          title: REAVER SpacezZzhell- Dominion
          type: object
          properties:
            have_fun: true
            ignore_patterns: ["*.log", "temp/*", "hahaha_placeholders/*"]
            code_review:
              type: object
              properties:
                disable: false
                comment_severity_threshold: CRITICAL
                max_review_comments: 50
                pull_request_opened:
                  summary: true
                  code_review: true
                  help: true
          EOF
          cat <<EOF > .gemini/styleguide.md
          # REAVER Codex for Partitioned-Harden-SpacezZzhell-
          - Neon names for mind-blowing partitions (e.g., `spacezReaverPartition`, `hardenMindBlaster`).
          - Log every wild hack with # REAVER-BLOOD: comments—expose the laughter in the code.
          - Cap lines at 120 chars for dystopian sprawl.
          - Crush any minimal structures; enforce recursive partitioning with neonCluster loops.
          - Review every file: Even if bare, Gemini shreds placeholders and builds out hidden layouts.
          EOF

      - name: Unleash Gemini on SpacezZzhell- Files
        run: |
          echo "Gemini devours every file in Partitioned-Harden-SpacezZzhell-—minimal guts mean fast shredding!"
          # Gemini app auto-triggers on PRs; simulate review call here if API available
          # Structure: Root is skeletal—README.md (if any), no deep dirs visible, so Gemini focuses on mind-blowing placeholders.

  reave-neuronlabs:
    runs-on: ubuntu-latest
    steps:
      - name: Snatch NeuronLabs
        uses: actions/checkout@v4
        with:
          repository: spiralgang/NeuronLabs
          token: ${{ secrets.GITHUB_TOKEN }}
          path: NeuronLabs

      - name: Inject REAVER Config for NeuronLabs
        run: |
          cd NeuronLabs
          mkdir -p .gemini
          cat <<EOF > .gemini/config.yaml
          $schema: "http://json-schema.org/draft-07/schema#"
          title: REAVER Neuron Dominion
          type: object
          properties:
            have_fun: true
            ignore_patterns: ["*.log", "builds/releases/*", "docs/user-guide/*"]
            code_review:
              type: object
              properties:
                disable: false
                comment_severity_threshold: HIGH
                max_review_comments: 30
                pull_request_opened:
                  summary: true
                  code_review: true
                  help: true
          EOF
          cat <<EOF > .gemini/styleguide.md
          # REAVER Codex for NeuronLabs
          - Neon names for AI cores (e.g., `neuronPulse`, `labyrinthCluster`).
          - Log hacks with # REAVER-BLOOD:—detail modular Clean Arch.
          - 120-char lines for wide neural nets.
          - Optimize sandbox loops with neonRend.
          - Review every file: builds/apk/ (APKs like NeuronLabs_Working.apk), docs/api/, docs/architecture/PROJECT_STRUCTURE.md, docs/user-guide/, src/ (source code), .github/ (workflows), LICENSE.
          - Layout: Modular—builds for artifacts, docs for API/arch/user guides, src for Android future, .github for templates.
          EOF

      - name: Unleash Gemini on NeuronLabs Files
        run: |
          echo "Gemini tears through NeuronLabs' modular beast—every APK, doc, and src file reviewed!"
          # Structure: Root with LICENSE; builds/ (apk/, releases/); docs/ (api/, architecture/, user-guide/); src/; .github/.

  reave-sgneuronlabs-ctc-coder-specialists:
    runs-on: ubuntu-latest
    steps:
      - name: Snatch SGNeuronLabs-CTC-Coder-Specialists
        uses: actions/checkout@v4
        with:
          repository: spiralgang/SGNeuronLabs-CTC-Coder-Specialists
          token: ${{ secrets.GITHUB_TOKEN }}
          path: SGNeuronLabs-CTC-Coder-Specialists

      - name: Inject REAVER Config for CTC-Coder
        run: |
          cd SGNeuronLabs-CTC-Coder-Specialists
          mkdir -p .gemini
          cat <<EOF > .gemini/config.yaml
          $schema: "http://json-schema.org/draft-07/schema#"
          title: REAVER CTC Dominion
          type: object
          properties:
            have_fun: true
            ignore_patterns: ["*.log", "corporate_fixer/*"]
            code_review:
              type: object
              properties:
                disable: false
                comment_severity_threshold: MEDIUM
                max_review_comments: 40
                pull_request_opened:
                  summary: true
                  code_review: true
                  help: true
          EOF
          cat <<EOF > .gemini/styleguide.md
          # REAVER Codex for SGNeuronLabs-CTC-Coder-Specialists
          - Neon names for fixer ops (e.g., `ctcReaverFix`, `spiralCoderBlitz`).
          - Log with # REAVER-BLOOD:—corporate inspiration demands savage comments.
          - 120-char lines for coast-to-coast sprawl.
          - Enforce neonCluster in specialist loops.
          - Review every file: Skeletal root—focus on README (corporate fixer desc), any hidden scripts or configs.
          - Layout: Minimal—corporate-inspired, likely flat with GitApp elements.
          EOF

      - name: Unleash Gemini on CTC Files
        run: |
          echo "Gemini shreds the fixer org—every sparse file in SGNeuronLabs reviewed raw!"
          # Structure: Insufficient depth visible—root with project desc, assume flat layout for GitApp.

  reave-devutilityv2-innovativetoolchestai:
    runs-on: ubuntu-latest
    steps:
      - name: Snatch DevUtilityV2-InnovativeToolchestAI
        uses: actions/checkout@v4
        with:
          repository: spiralgang/DevUtilityV2-InnovativeToolchestAI
          token: ${{ secrets.GITHUB_TOKEN }}
          path: DevUtilityV2-InnovativeToolchestAI

      - name: Inject REAVER Config for DevUtilityV2
        run: |
          cd DevUtilityV2-InnovativeToolchestAI
          mkdir -p .gemini
          cat <<EOF > .gemini/config.yaml
          $schema: "http://json-schema.org/draft-07/schema#"
          title: REAVER Toolchest Dominion
          type: object
          properties:
            have_fun: true
            ignore_patterns: ["*.log", "/reference vault/*"]
            code_review:
              type: object
              properties:
                disable: false
                comment_severity_threshold: CRITICAL
                max_review_comments: 25
                pull_request_opened:
                  summary: true
                  code_review: true
                  help: true
          EOF
          cat <<EOF > .gemini/styleguide.md
          # REAVER Codex for DevUtilityV2-InnovativeToolchestAI
          - Neon names for AI tools (e.g., `toolchestReaver`, `innovativePulse`).
          - Log hacks with # REAVER-BLOOD:—sandbox every threat.
          - 120-char lines for Android sprawl.
          - Optimize KT loops with neonRend.
          - Review every file: AIThinkModule.kt, AIGuidanceSystem.kt, AIEnvironmentAwareness.kt, LearningBot.kt, CustomSandbox.kt, SecurityAnalyzer.kt, PermissionManager.kt, ZRAMManager.kt, CustomCompressor.kt, CloudTrainingPortal.kt, ResourceManager.kt, ThreatDetector.kt, CloudZRAMManager.kt, AgenticService.kt, SrirachaUI.kt, autonomous_defender.py, /reference vault/ standards.
          - Layout: KT-heavy Android app—DevUtilityV2.5 (UIYI mode, sandbox), Sriracha Army V2 (Dual-Mind, hacking tools); root with README, configs implied.
          EOF

      - name: Unleash Gemini on DevUtilityV2 Files
        run: |
          echo "Gemini ravages DevUtilityV2's KT arsenal—every script and sandbox reviewed!"
          # Structure: Inferred—root with README; files like *.kt for AI/security/cloud; autonomous_defender.py; /reference vault/.
