import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  StreamController<VoiceCommandEvent>? _eventController;

  Stream<VoiceCommandEvent> get onCommandEvent {
    _eventController ??= StreamController<VoiceCommandEvent>();
    return _eventController!.stream;
  }

  bool get isListening => _isListening;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      return await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Start listening for voice commands
  Future<void> startListening() async {
    if (!_speech.isAvailable) {
      print('Speech recognition not available');
      return;
    }

    if (_isListening) return;

    _isListening = true;
    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      _isListening = false;
    }
  }

  /// Stop listening for voice commands
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    try {
      await _speech.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    final command = result.recognizedWords.toLowerCase().trim();
    
    if (result.finalResult) {
      print('Final voice command: $command');
      _processVoiceCommand(command);
    } else {
      print('Partial voice command: $command');
      // Could show partial results in UI
    }
  }

  /// Process recognized voice commands
  void _processVoiceCommand(String command) {
    VoiceCommandEvent? event;

    // Navigation commands
    if (command.contains('home') || command.contains('dashboard')) {
      event = const VoiceCommandEvent.navigateTo(NavigationTarget.home);
    } else if (command.contains('account') || command.contains('accounts')) {
      event = const VoiceCommandEvent.navigateTo(NavigationTarget.accounts);
    } else if (command.contains('transaction') || command.contains('transactions')) {
      event = const VoiceCommandEvent.navigateTo(NavigationTarget.transactions);
    } else if (command.contains('analytics') || command.contains('reports')) {
      event = const VoiceCommandEvent.navigateTo(NavigationTarget.analytics);
    } else if (command.contains('settings')) {
      event = const VoiceCommandEvent.navigateTo(NavigationTarget.settings);
    }
    // Transaction commands
    else if (command.contains('add') && (command.contains('income') || command.contains('earn'))) {
      event = const VoiceCommandEvent.addTransaction(TransactionType.income);
    } else if (command.contains('add') && (command.contains('expense') || command.contains('spend'))) {
      event = const VoiceCommandEvent.addTransaction(TransactionType.expense);
    }
    // Search commands
    else if (command.contains('search') || command.contains('find')) {
      final query = _extractSearchQuery(command);
      if (query.isNotEmpty) {
        event = VoiceCommandEvent.search(query);
      }
    }

    // Send event if matched
    if (event != null) {
      _eventController?.sink.add(event);
    } else {
      // No match found
      _eventController?.sink.add(const VoiceCommandEvent.unknown());
    }
  }

  /// Extract search query from command
  String _extractSearchQuery(String command) {
    // Remove common prefixes
    final prefixes = ['search for', 'find', 'search', 'look for'];
    var query = command;
    
    for (final prefix in prefixes) {
      if (query.startsWith(prefix)) {
        query = query.substring(prefix.length).trim();
        break;
      }
    }
    
    return query;
  }

  /// Handle speech recognition errors
  void _onSpeechError(SpeechRecognitionError error) {
    print('Speech recognition error: ${error.errorMsg}');
    _isListening = false;
    _eventController?.sink.add(const VoiceCommandEvent.error());
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    print('Speech recognition status: $status');
  }

  /// Dispose resources
  void dispose() {
    _eventController?.close();
    _speech.cancel();
  }
}

/// Events emitted by the voice command service
abstract class VoiceCommandEvent {
  const VoiceCommandEvent();

  factory VoiceCommandEvent.navigateTo(NavigationTarget target) = NavigateToEvent;
  factory VoiceCommandEvent.addTransaction(TransactionType type) = AddTransactionEvent;
  factory VoiceCommandEvent.search(String query) = SearchEvent;
  factory VoiceCommandEvent.unknown() = UnknownCommandEvent;
  factory VoiceCommandEvent.error() = ErrorCommandEvent;
}

class NavigateToEvent extends VoiceCommandEvent {
  final NavigationTarget target;

  const NavigateToEvent(this.target);
}

class AddTransactionEvent extends VoiceCommandEvent {
  final TransactionType type;

  const AddTransactionEvent(this.type);
}

class SearchEvent extends VoiceCommandEvent {
  final String query;

  const SearchEvent(this.query);
}

class UnknownCommandEvent extends VoiceCommandEvent {
  const UnknownCommandEvent();
}

class ErrorCommandEvent extends VoiceCommandEvent {
  const ErrorCommandEvent();
}

/// Navigation targets
enum NavigationTarget {
  home,
  accounts,
  transactions,
  analytics,
  settings,
}

/// Transaction types
enum TransactionType {
  income,
  expense,
}

/// Voice command UI widget
class VoiceCommandWidget extends StatefulWidget {
  final Function(VoiceCommandEvent) onCommandReceived;

  const VoiceCommandWidget({
    Key? key,
    required this.onCommandReceived,
  }) : super(key: key);

  @override
  _VoiceCommandWidgetState createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  final VoiceCommandService _voiceService = VoiceCommandService();
  bool _isInitialized = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    final initialized = await _voiceService.initialize();
    if (initialized) {
      setState(() {
        _isInitialized = true;
      });
      
      // Listen for voice commands
      _voiceService.onCommandEvent.listen(widget.onCommandReceived);
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) return;

    if (_isListening) {
      await _voiceService.stopListening();
    } else {
      await _voiceService.startListening();
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isInitialized)
          const Text('Voice commands not available')
        else
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_none : Icons.mic,
              color: _isListening ? Colors.red : Theme.of(context).iconTheme.color,
            ),
            onPressed: _toggleListening,
            tooltip: _isListening ? 'Stop listening' : 'Start voice commands',
          ),
        if (_isListening)
          const Text(
            'Listening...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}