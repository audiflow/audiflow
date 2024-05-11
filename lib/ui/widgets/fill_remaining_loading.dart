import 'package:audiflow/ui/widgets/platform_progress_indicator.dart';
import 'package:flutter/material.dart';

class FillRemainingLoading extends StatelessWidget {
  const FillRemainingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PlatformProgressIndicator(),
        ],
      ),
    );
  }
}
