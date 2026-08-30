import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';

/// A tappable field that opens a bottom sheet with a searchable list.
/// The user can pick an existing option or type a custom one.
class SearchableDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData prefixIcon;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? Function(String?)? validator;
  final String? addCustomLabel;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.prefixIcon,
    required this.options,
    required this.onSelected,
    this.validator,
    this.addCustomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: value,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _openSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: field.hasError
                        ? Colors.red
                        : (value != null ? AppColors.primary : Colors.grey.shade400),
                    width: value != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(prefixIcon,
                        color: value != null ? AppColors.primary : AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        value ?? hint,
                        style: TextStyle(
                          fontSize: 16,
                          color: value != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 14),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchableSheet(
        label: label,
        options: options,
        addCustomLabel: addCustomLabel ?? S.of(context).addNewOption,
        currentValue: value,
      ),
    );
    if (result != null) onSelected(result);
  }
}

class _SearchableSheet extends StatefulWidget {
  final String label;
  final List<String> options;
  final String addCustomLabel;
  final String? currentValue;

  const _SearchableSheet({
    required this.label,
    required this.options,
    required this.addCustomLabel,
    this.currentValue,
  });

  @override
  State<_SearchableSheet> createState() => _SearchableSheetState();
}

class _SearchableSheetState extends State<_SearchableSheet> {
  final _searchController = TextEditingController();
  final _customController = TextEditingController();
  late List<String> _filtered;
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.options);
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.options
          .where((o) => o.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: S.of(context).searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length + 1, // +1 for "add custom" button
                itemBuilder: (_, i) {
                  if (i == _filtered.length) {
                    // "Add custom" entry
                    return _showCustomInput
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _customController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).typeHere,
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    final txt = _customController.text.trim();
                                    if (txt.isNotEmpty) {
                                      Navigator.pop(context, txt);
                                    }
                                  },
                                  child: Text(S.of(context).add,
                                      style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.add, color: AppColors.primary),
                            ),
                            title: Text(
                              widget.addCustomLabel,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                            onTap: () => setState(() => _showCustomInput = true),
                          );
                  }
                  final option = _filtered[i];
                  final isSelected = option == widget.currentValue;
                  return ListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : const Icon(Icons.directions_car_outlined,
                            color: Colors.grey),
                    title: Text(option),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.07),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onTap: () => Navigator.pop(context, option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
