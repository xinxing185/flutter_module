import 'package:flutter/material.dart';
import '../../core/app_navigator.dart';

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => AppNavigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Unknown Route'),
      ),
      body: Center(child: Text('No page for route: $routeName')),
    );
  }
}
