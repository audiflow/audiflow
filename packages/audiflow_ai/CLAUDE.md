---
refs:
  id: pkg:audiflow_ai
  kind: package
  title: "audiflow_ai"
  modules:
    - packages/audiflow_ai/
---

# audiflow_ai

On-device AI capabilities for the audiflow podcast player, packaged as a Flutter plugin with iOS and Android platform code. Provides natural-language understanding for voice commands and episode summarization, abstracting platform-specific AI implementations behind a common Dart interface.

## Ecosystem context

Depends only on audiflow_core. A utility-level package at the same dependency depth as audiflow_podcast and audiflow_search. Consumed by audiflow_domain (voice command and AI-backed features); transitively reachable from audiflow_app, which lists it as a direct dependency.

## Responsibilities

- On-device AI capability detection and configuration
- Natural-language understanding for voice commands (`VoiceCommandParser`, regex + LLM hybrid)
- Generic and episode-specific summarization
- Platform abstraction over native iOS and Android AI implementations
- Typed AI exceptions and capability/config models

## Non-responsibilities

- App UI and screens (owned by audiflow_app)
- Business logic and command execution (owned by audiflow_domain)
- Data access and persistence (owned by audiflow_domain)
- Podcast search (owned by audiflow_search) and RSS parsing (owned by audiflow_podcast)
