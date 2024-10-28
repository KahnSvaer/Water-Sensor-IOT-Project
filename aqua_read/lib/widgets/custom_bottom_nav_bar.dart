import 'package:flutter/material.dart';
import '../state_management/app_state.dart';
import '../constants/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ValueListenableBuilder<int>(
      valueListenable: appState.backgroundPageIndex,
      builder: (context, currentIndex, child) {
        return BottomAppBar(
          color: AppColors.primaryColor,
          height: 64,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              _buildIconButton(
                context: context,
                icon: Icons.camera,
                label: 'Scan',
                index: 0,
                currentIndex: currentIndex,
              ),
              _buildIconButton(
                context: context,
                icon: Icons.home,
                label: 'Home',
                index: 1,
                currentIndex: currentIndex,
              ),
              _buildIconButton(
                context: context,
                icon: Icons.history,
                label: 'History',
                index: 2,
                currentIndex: currentIndex,
              ),
              _buildIconButton(
                context: context,
                icon: Icons.settings,
                label: 'Settings',
                index: 3,
                currentIndex: currentIndex,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final appState = AppState();

    return Expanded(
      child: ValueListenableBuilder<bool>(
        valueListenable: appState.buttonHighlight,
        builder: (context, isHighlighted, child) {
          return TextButton(
            onPressed: () {
              appState.setHighlightTrue();
              appState.updateIndex(index);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: (currentIndex == index && isHighlighted) ? 28.0 : 24.0,
                    color: (currentIndex == index && isHighlighted)
                        ? Colors.white
                        : Colors.white70,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: (currentIndex == index && isHighlighted)
                          ? Colors.white
                          : Colors.white70,
                      fontSize: (currentIndex == index && isHighlighted) ? 16.0 : 12.0,
                    ),
                  ),
                ],
              ),
          );
        },
      ),
    );
  }
}
