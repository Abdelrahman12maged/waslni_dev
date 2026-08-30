import 'dart:async';

import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:car_app/features/map/presentation/cubit/map_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A reusable search field that drives autocomplete via [MapCubit].
///
/// Usage:
/// ```dart
/// LocationSearchField(
///   hint: 'نقطة الانطلاق',
///   controller: _startController,
///   onLocationSelected: (result) => cubit.setStartLocation(result, icon),
/// )
/// ```
class LocationSearchField extends StatefulWidget {
  const LocationSearchField({
    super.key,
    required this.hint,
    required this.controller,
    required this.onLocationSelected,
    this.prefixIcon,
    this.prefixColor,
  });

  final String hint;
  final TextEditingController controller;
  final void Function(PlaceSuggestion suggestion) onLocationSelected;
  final IconData? prefixIcon;
  final Color? prefixColor;

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showSuggestions = _focusNode.hasFocus);
      if (!_focusNode.hasFocus) {
        context.read<MapCubit>().clearSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search Field ─────────────────────────────────────────────────
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              widget.prefixIcon ?? Icons.location_on,
              color: widget.prefixColor ?? Colors.green,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      widget.controller.clear();
                      context.read<MapCubit>().clearSuggestions();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (q) {
            context.read<MapCubit>().onSearchChanged(q);
            setState(() {}); // update clear icon
          },
        ),

        // ── Suggestions Dropdown ──────────────────────────────────────────
        if (_showSuggestions)
          BlocBuilder<MapCubit, MapState>(
            buildWhen: (prev, curr) =>
                curr is MapSuggestionsLoaded ||
                curr is MapSuggestionsCleared ||
                curr is MapLoading,
            builder: (context, state) {
              if (state is MapSuggestionsLoaded && state.suggestions.isNotEmpty) {
                return _SuggestionsDropdown(
                  suggestions: state.suggestions,
                  onTap: (suggestion) {
                    widget.controller.text = suggestion.mainText;
                    _focusNode.unfocus();
                    widget.onLocationSelected(suggestion);
                    setState(() {}); // update clear icon
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private dropdown widget
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionsDropdown extends StatelessWidget {
  const _SuggestionsDropdown({
    required this.suggestions,
    required this.onTap,
  });

  final List<PlaceSuggestion> suggestions;
  final void Function(PlaceSuggestion) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
        itemBuilder: (context, i) {
          final s = suggestions[i];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.place, color: Colors.grey, size: 20),
            title: Text(
              s.mainText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textDirection: TextDirection.rtl,
            ),
            subtitle: s.secondaryText.isNotEmpty
                ? Text(
                    s.secondaryText,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textDirection: TextDirection.rtl,
                  )
                : null,
            onTap: () => onTap(s),
          );
        },
      ),
    );
  }
}
