import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({super.key, required this.password});

  double get strength {
    if (password.isEmpty) return 0;
    double score = 0;
    if (password.length >= 6) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.25;
    return score;
  }

  Color _getColor(double score) {
    if (score <= 0.25) return Colors.redAccent;
    if (score <= 0.5) return Colors.orangeAccent;
    if (score <= 0.75) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final score = strength;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (index) {
              final isActive = score > (index * 0.25);
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _getColor(score)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: password.isEmpty ? 0 : 1,
            child: Text(
              _getStrengthText(score),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getColor(score).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(double score) {
    if (score <= 0.25) return "Weak";
    if (score <= 0.5) return "Fair";
    if (score <= 0.75) return "Good";
    return "Strong";
  }
}
