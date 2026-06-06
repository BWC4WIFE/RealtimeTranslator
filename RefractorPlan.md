{
  "project": "RealtimeTranslator Refactor",
  "target_architecture": "Acoustic One-Shot Translation via whisper.cpp + CoreML (Headless CI/CD Deployment)",
  "phases": [
    {
      "phase": 1,
      "name": "Headless Dependency and Build Pipeline Configuration",
      "steps": [
        {
          "step_id": "1.1",
          "description": "Configure GitHub Actions workflow to dynamically download `whisper.cpp` core source files (whisper.h, whisper.cpp, ggml.h, ggml.c) via `wget` into `Sources/RealtimeTranslator/whisper`.",
          "files_affected": [
            ".github/workflows/build.yml"
          ]
        },
        {
          "step_id": "1.2",
          "description": "Configure GitHub Actions workflow to dynamically download pre-quantized Whisper Small CoreML assets (ggml-small.bin, ggml-small-encoder.mlmodelc.zip) into `Resources/Models` and extract them.",
          "files_affected": [
            ".github/workflows/build.yml"
          ]
        },
        {
          "step_id": "1.3",
          "description": "Add Objective-C Bridging Header (`RealtimeTranslator-Bridging-Header.h`) to expose the dynamically fetched whisper.cpp C-API to Swift.",
          "files_affected": [
            "project.yml",
            "Sources/RealtimeTranslator/RealtimeTranslator-Bridging-Header.h"
          ]
        },
        {
          "step_id": "1.4",
          "description": "Update `project.yml` to bundle the downloaded `Resources/Models` directory and apply required compiler flags (-O3, -DNDEBUG) to the fetched whisper sources.",
          "files_affected": [
            "project.yml"
          ]
        }
      ]
    },
    {
      "phase": 2,
      "name": "Audio Pipeline and VAD Adaptation",
      "steps": [
        {
          "step_id": "2.1",
          "description": "Retain existing AVAudioEngine setup but enforce strict 16,000Hz mono PCM sample rate configuration required by Whisper.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        },
        {
          "step_id": "2.2",
          "description": "Strip out SFSpeechRecognizer, SFSpeechAudioBufferRecognitionRequest, and local Apple translation capability components.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift",
            "Sources/RealtimeTranslator/AppleTranslator.swift"
          ]
        },
        {
          "step_id": "2.3",
          "description": "Refactor the continuous audio tap to append PCM Float32 arrays into a circular sliding window buffer when VAD thresholds trigger active speech.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        }
      ]
    },
    {
      "phase": 3,
      "name": "Whisper Context and CoreML Loading Lifecycle",
      "steps": [
        {
          "step_id": "3.1",
          "description": "Implement a Swift wrapper class (`WhisperContext`) managing `whisper_init_from_file_with_params` and pointer mechanics.",
          "files_affected": [
            "Sources/RealtimeTranslator/WhisperContext.swift"
          ]
        },
        {
          "step_id": "3.2",
          "description": "Ensure the initialization logic points directly to the dynamically bundled `ggml-small.bin` within the application resources so it automatically pairs with the ANE encoder.",
          "files_affected": [
            "Sources/RealtimeTranslator/WhisperContext.swift"
          ]
        },
        {
          "step_id": "3.3",
          "description": "Configure execution parameters mapping target computation explicitly to Apple Neural Engine via `whisper_context_params` (e.g., setting `use_gpu = false` to default to CoreML if available).",
          "files_affected": [
            "Sources/RealtimeTranslator/WhisperContext.swift"
          ]
        }
      ]
    },
    {
      "phase": 4,
      "name": "One-Shot Translation Loop Execution",
      "steps": [
        {
          "step_id": "4.1",
          "description": "Instantiate standard inference parameter block via `whisper_full_default_params(WHISPER_SAMPLING_GREEDY)`.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        },
        {
          "step_id": "4.2",
          "description": "Explicitly set `params.translate = true` and target language configuration tokens to execute acoustic cross-lingual translation directly.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        },
        {
          "step_id": "4.3",
          "description": "Execute `whisper_full` over the active audio buffer chunk on a dedicated background concurrent serial dispatch queue.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        },
        {
          "step_id": "4.4",
          "description": "Extract text segment outputs using `whisper_full_get_segment_text` and map back to the primary main thread.",
          "files_affected": [
            "Sources/RealtimeTranslator/TranslatorEngine.swift"
          ]
        }
      ]
    },
    {
      "phase": 5,
      "name": "State Management and UI Component Binding",
      "steps": [
        {
          "step_id": "5.1",
          "description": "Bind text callbacks from the Whisper engine directly into the current session append operations.",
          "files_affected": [
            "Sources/RealtimeTranslator/ConversationStore.swift"
          ]
        },
        {
          "step_id": "5.2",
          "description": "Update UI layout strings to display real-time status indicating active local Neural Engine execution context.",
          "files_affected": [
            "Sources/RealtimeTranslator/ContentView.swift"
          ]
        }
      ]
    }
  ]
}