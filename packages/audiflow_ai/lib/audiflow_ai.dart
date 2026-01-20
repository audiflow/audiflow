// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// On-device AI capabilities for Audiflow podcast application.
library;

// Channel (for advanced usage and testing)
export 'src/channel/audiflow_ai_channel.dart';

// Exceptions
export 'src/exceptions/audiflow_ai_exception.dart';

// Models
export 'src/models/ai_capability.dart';
export 'src/models/ai_response.dart';
export 'src/models/episode_summary.dart';
export 'src/models/generation_config.dart';
export 'src/models/summarization_config.dart';
export 'src/models/voice_command.dart';

// Utilities
export 'src/utils/prompt_templates.dart';
export 'src/utils/text_chunker.dart';
export 'src/utils/text_utils.dart';

// Services
export 'src/services/summarization_service.dart';
export 'src/services/text_generation_service.dart';
export 'src/services/voice_command_service.dart';

// Main API
export 'src/audiflow_ai.dart';
