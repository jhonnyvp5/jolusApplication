import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  const FilterChipWidget({super.key, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00236F) : Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
