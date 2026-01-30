import 'package:flutter/material.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/ai_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/commons/ai/widgets/ai_initial_content.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/widgets/markdown/markdown_renderer.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'dart:async';
import 'package:app/src/screens/commons/ai/widgets/media_gallery.dart';
import 'package:app/src/screens/commons/ai/widgets/suggested_questions.dart';

class FAQAIWidget extends StatelessWidget {
  final AIController controller;
  final WealthyAIScreenParameters parameters;
  static const List<String> loadingMessages = [
    "Working on it...",
    "Thinking...",
    "Connecting the dots...",
    "Still thinking ...",
    "Almost there...",
    "Polishing it up...",
  ];

  // Add ValueNotifier for loading message index
  static final ValueNotifier<int> _loadingMessageIndex = ValueNotifier<int>(0);
  static Timer? _messageTimer;
  static Timer? _scrollDebounceTimer;
  // Add ScrollController
  static final ScrollController _scrollController = ScrollController();

  const FAQAIWidget({
    Key? key,
    required this.controller,
    required this.parameters,
  }) : super(key: key);

  // Add method to scroll to bottom
  void _scrollToBottom() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.aiResponse.state == NetworkState.loading) {
      return _buildLoadingIndicator();
    } else if (controller.aiResponse.state == NetworkState.loaded) {
      _messageTimer?.cancel();
      _messageTimer = null;
      return _buildAIResponse(controller);
    } else {
      _messageTimer?.cancel();
      _messageTimer = null;
      return AIInitialContent(
        controller: controller,
        quickActions: parameters.quickActions,
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Builder(builder: (BuildContext context) {
      return GetBuilder<AIController>(
        init: controller,
        builder: (aiController) {
          // Start cycling messages if timer is not active
          if (_messageTimer == null || !_messageTimer!.isActive) {
            _startCyclingMessages();
          }

          return SingleChildScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChatHistory(context, aiController),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _loadingMessageIndex,
                        builder: (context, index, child) {
                          // Scroll to bottom when message changes
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _scrollToBottom());
                          return _buildAIMessageBubble(
                            context,
                            loadingMessages[index],
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Lottie.asset(
                      AllImages().wealthyAiLoadingAnimation,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _startCyclingMessages() {
    _messageTimer?.cancel();
    _loadingMessageIndex.value = 0;

    void cycleMessage() {
      if (controller.aiResponse.state != NetworkState.loading) {
        _messageTimer?.cancel();
        _messageTimer = null;
        return;
      }

      int nextIndex = (_loadingMessageIndex.value + 1) % loadingMessages.length;
      _loadingMessageIndex.value = nextIndex;

      // Generate random duration between 3 and 5 seconds
      int randomDuration = 3000 + (Random().nextInt(2001)); // 3000-5000ms
      _messageTimer =
          Timer(Duration(milliseconds: randomDuration), cycleMessage);
    }

    // Start the cycle with initial 3-5 second delay
    int initialDelay = 3000 + (Random().nextInt(2001)); // 3000-5000ms
    _messageTimer = Timer(Duration(milliseconds: initialDelay), cycleMessage);
  }

  Widget _buildAIResponse(AIController aiController) {
    return Builder(builder: (BuildContext context) {
      // Scroll to bottom after build
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      return SingleChildScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChatHistory(context, aiController),
              if (aiController.chatHistory.isNotEmpty &&
                  aiController.chatHistory.last.type == ChatMessageType.ai &&
                  aiController.chatHistory.last.text ==
                      aiController.rawResponse)
                SizedBox.shrink()
              else ...[
                if (aiController.rawResponse == null ||
                    aiController.rawResponse!.isEmpty)
                  Center(
                    child: EmptyScreen(
                      imagePath: AllImages().clientSearchEmptyIcon,
                      imageSize: 92,
                      message: 'No answer available',
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildAIMessageBubble(
                        context,
                        aiController.rawResponse ?? 'No answer available.',
                      ),
                    ],
                  ),
                if (aiController.rawResponse != null &&
                    aiController.rawResponse!.isNotEmpty &&
                    !(aiController.chatHistory.isNotEmpty &&
                        aiController.chatHistory.last.type ==
                            ChatMessageType.ai &&
                        aiController.chatHistory.last.text ==
                            aiController.rawResponse))
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildFeedbackButton(
                          context: context,
                          icon: Icons.thumb_up_outlined,
                          onTap: () => _handleFeedback(context, true),
                        ),
                        SizedBox(width: 8),
                        _buildFeedbackButton(
                          context: context,
                          icon: Icons.thumb_down_outlined,
                          onTap: () => _handleFeedback(context, false),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                  ),
              ],
              if (aiController.messageMetadata?.isNotEmpty == true)
                _buildMediaGallery(context, aiController),
              if (aiController.messageMetadata?.isNotEmpty == true)
                _buildSuggestedQuestions(context, aiController),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAIMessageBubble(BuildContext context, String message) {
    return Container(
      constraints: BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MarkdownRenderer(
          data: message,
          selectable: true,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildChatHistory(BuildContext context, AIController aiController) {
    if (aiController.chatHistory.isEmpty) {
      return SizedBox.shrink();
    }
    int endIndex = aiController.aiResponse.state == NetworkState.loading
        ? aiController.chatHistory.length
        : aiController.chatHistory.length;

    if (endIndex <= 0) {
      return SizedBox.shrink();
    }

    List<Widget> chatWidgets = [];
    int lastAiMessageIndex = -1;
    for (int i = endIndex - 1; i >= 0; i--) {
      if (aiController.chatHistory[i].type == ChatMessageType.ai) {
        lastAiMessageIndex = i;
        break;
      }
    }

    for (int i = 0; i < endIndex; i++) {
      final message = aiController.chatHistory[i];
      if (message.type == ChatMessageType.user) {
        chatWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorConstants.borderColor),
                ),
                constraints: BoxConstraints(maxWidth: 280),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: ColorConstants.black,
                  ),
                ),
              ),
            ],
          ),
        );
        chatWidgets.add(SizedBox(height: 16));
      } else {
        chatWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAIMessageBubble(context, message.text),
            ],
          ),
        );

        if (i == lastAiMessageIndex &&
            aiController.aiResponse.state == NetworkState.loaded) {
          chatWidgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFeedbackButton(
                    context: context,
                    icon: Icons.thumb_up_outlined,
                    onTap: () => _handleFeedback(context, true),
                  ),
                  SizedBox(width: 8),
                  _buildFeedbackButton(
                    context: context,
                    icon: Icons.thumb_down_outlined,
                    onTap: () => _handleFeedback(context, false),
                  ),
                ],
              ),
            ),
          );
        } else {
          chatWidgets.add(SizedBox(height: 16));
        }
      }
    }

    return Column(
      children: chatWidgets,
    );
  }

  Widget _buildFeedbackButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: ColorConstants.tertiaryBlack,
      ),
      padding: EdgeInsets.only(left: 10),
      constraints: BoxConstraints(),
    );
  }

  void _handleFeedback(BuildContext context, bool isPositive) {
    showToast(
      context: context,
      text: "Thank you for your feedback",
    );
  }

  Widget _buildSuggestedQuestions(
      BuildContext context, AIController aiController) {
    List<String> allSuggestedQuestions = [];
    List<String> firstQuestions = [];

    if (aiController.messageMetadata?.isNotEmpty == true) {
      try {
        final List<MessageMetadata> metadata = aiController.messageMetadata!;
        for (var item in metadata) {
          if (item.suggestedQuestions != null &&
              item.suggestedQuestions!.isNotEmpty) {
            final questions = item.suggestedQuestions;
            if (questions != null && questions.isNotEmpty) {
              if (questions[0].isNotEmpty) {
                firstQuestions.add(questions[0]);
              }

              if (questions.length > 1) {
                for (int i = 1; i < questions.length; i++) {
                  if (questions[i].isNotEmpty) {
                    allSuggestedQuestions.add(questions[i]);
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error parsing suggested questions: $e');
      }
    }

    final Set<String> uniqueQuestions = {
      ...firstQuestions,
      ...allSuggestedQuestions
    };
    final displayQuestions = uniqueQuestions.take(4).toList();

    return SuggestedQuestions(
      questions: displayQuestions,
      onQuestionTap: (question) {
        aiController.messageController.text = question;
        aiController.processAIQuery(question);
      },
    );
  }

  Widget _buildMediaGallery(BuildContext context, AIController aiController) {
    List<Map<String, dynamic>> imagesList = [];

    if (aiController.messageMetadata?.isNotEmpty == true) {
      try {
        final List<MessageMetadata> metadata = aiController.messageMetadata!;
        for (var item in metadata) {
          if (item.media != null &&
              item.media!.isNotEmpty &&
              item.score != null &&
              item.score! > 0.70) {
            final media = item.media;
            if (media != null && media.isNotEmpty) {
              for (var mediaItem in media) {
                if (mediaItem is Map &&
                    mediaItem.containsKey('tag') &&
                    mediaItem.containsKey('content') &&
                    mediaItem['tag'] == 'img') {
                  imagesList.add({
                    'tag': mediaItem['tag'],
                    'content': mediaItem['content'],
                  });
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error parsing media content: $e');
      }
    }

    return MediaGallery(imagesList: imagesList);
  }
}
