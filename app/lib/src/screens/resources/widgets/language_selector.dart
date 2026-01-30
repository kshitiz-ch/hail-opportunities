import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatefulWidget {
  final TagModel? selectedLanguage;
  final List<TagModel> availableLanguages;
  final Function(TagModel)? onLanguageChanged;

  const LanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.availableLanguages,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  void _showLanguageDropdown(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<TagModel>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      items: widget.availableLanguages.map((language) {
        final isSelected = language.tag == widget.selectedLanguage?.tag;
        return PopupMenuItem<TagModel>(
          value: language,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  language.text ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Checkmark for selected language
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Colors.blue,
                  size: 20,
                ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedLanguage) {
      if (selectedLanguage != null &&
          selectedLanguage.tag != widget.selectedLanguage?.tag) {
        widget.onLanguageChanged?.call(selectedLanguage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLanguageDropdown(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedLanguage?.text ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            // Dropdown Arrow
            Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
