import 'dart:async';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/common/ai_controller.dart';
import 'package:get/get.dart';

class AIInputField extends StatelessWidget {
  final AIController controller;
  final List<String> suggestions;
  final double bottomPadding;
  final String? initialQuestion;

  const AIInputField({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.bottomPadding,
    this.initialQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: ColorConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.aiSuggestionBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorConstants.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GetBuilder<AIController>(
                    init: controller,
                    builder: (aiController) => HumanTypingTextField(
                      controller: aiController.messageController,
                      suggestions: suggestions,
                      aiController: aiController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          aiController.processAIQuery(value);
                        }
                      },
                      initialQuestion: initialQuestion,
                    ),
                  ),
                ),
                GetBuilder<AIController>(
                  init: controller,
                  builder: (aiController) => IconButton(
                    icon: Icon(
                      Icons.send,
                      color: aiController.messageController.text.isEmpty
                          ? ColorConstants.black
                          : ColorConstants.skyBlue,
                    ),
                    onPressed: () {
                      final query = aiController.messageController.text;
                      if (query.isNotEmpty) {
                        aiController.processAIQuery(query);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

class HumanTypingTextField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final Function(String) onSubmitted;
  final AIController aiController;
  final String? initialQuestion;

  const HumanTypingTextField({
    Key? key,
    required this.controller,
    required this.suggestions,
    required this.onSubmitted,
    required this.aiController,
    this.initialQuestion,
  }) : super(key: key);

  @override
  State<HumanTypingTextField> createState() => _HumanTypingTextFieldState();
}

class _HumanTypingTextFieldState extends State<HumanTypingTextField> {
  late Timer _suggestionTimer;
  late Timer? _typingTimer;
  int _currentSuggestionIndex = 0;
  String _currentTypedText = '';
  int _currentCharIndex = 0;
  bool _isTyping = false;
  bool _isErasing = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasAskedQuestion = false;

  // Random delays to simulate human typing
  final List<int> _typingDelays = [
    80,
    100,
    120,
    90,
    110,
    150,
    130,
    95,
    140,
    160
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion != null) {
      widget.controller.text = widget.initialQuestion!;
    }

    // Check if user has already asked a question by checking chat history
    _hasAskedQuestion = widget.aiController.chatHistory.isNotEmpty;

    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChange);

    if (!_hasAskedQuestion && widget.suggestions.isNotEmpty) {
      _startTyping();

      _suggestionTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (_isFocused || _hasAskedQuestion) return;

        if (_isTyping && _typingTimer != null) {
          _typingTimer!.cancel();
        }
        _startErasing();
      });
    } else {
      // Initialize empty timer that will never fire if user has asked a question
      _suggestionTimer = Timer(const Duration(days: 365), () {});
    }
  }

  void _onFocusChange() {
    if (!mounted) return;

    setState(() {
      _isFocused = _focusNode.hasFocus;

      if (_isFocused) {
        if (_typingTimer != null) {
          _typingTimer!.cancel();
          _typingTimer = null;
        }
        _currentTypedText = '';
      } else {
        if (widget.controller.text.isEmpty && !_hasAskedQuestion) {
          _startTyping();
        }
      }
    });
  }

  void _onControllerChange() {
    if (!mounted) return;

    // If controller text is empty and we're not focused, restart typing suggestions
    if (widget.controller.text.isEmpty &&
        !_isFocused &&
        !_isTyping &&
        !_isErasing &&
        !_hasAskedQuestion) {
      _startTyping();
    }
  }

  void _startTyping() {
    if (_isFocused || _hasAskedQuestion) return;

    _isTyping = true;
    _isErasing = false;

    _typingTimer = Timer.periodic(
        Duration(milliseconds: _getRandomTypingDelay()), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (widget.suggestions.isNotEmpty &&
          _currentCharIndex <
              widget.suggestions[_currentSuggestionIndex].length) {
        setState(() {
          _currentTypedText = widget.suggestions[_currentSuggestionIndex]
              .substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });
      } else {
        _typingTimer?.cancel();
        _typingTimer = null;
        _isTyping = false;
      }
    });
  }

  void _startErasing() {
    if (_isFocused || _hasAskedQuestion) return;

    _isErasing = true;

    _typingTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentCharIndex > 0) {
        setState(() {
          _currentCharIndex--;
          _currentTypedText = widget.suggestions[_currentSuggestionIndex]
              .substring(0, _currentCharIndex);
        });
      } else {
        _typingTimer?.cancel();
        _typingTimer = null;
        _isErasing = false;

        if (!mounted) return;

        setState(() {
          _currentSuggestionIndex =
              (_currentSuggestionIndex + 1) % widget.suggestions.length;
          _currentCharIndex = 0;
          _currentTypedText = '';
        });

        Future.delayed(Duration(milliseconds: 300), () {
          if (!mounted) return;

          if (!_isFocused && !_hasAskedQuestion) {
            _startTyping();
          }
        });
      }
    });
  }

  int _getRandomTypingDelay() {
    return _typingDelays[(_currentCharIndex) % _typingDelays.length];
  }

  @override
  void dispose() {
    if (_typingTimer != null) {
      _typingTimer!.cancel();
      _typingTimer = null;
    }
    _suggestionTimer.cancel();

    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onControllerChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIController>(
      init: widget.aiController,
      builder: (controller) {
        _hasAskedQuestion = controller.chatHistory.isNotEmpty;

        return TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: _isFocused
                ? ''
                : _hasAskedQuestion
                    ? 'Type your query here'
                    : _currentTypedText,
            hintStyle: context.headlineMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.tertiaryBlack,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              widget.onSubmitted(value);
              setState(() {
                _hasAskedQuestion = true;
              });
            }
          },
        );
      },
    );
  }
}
