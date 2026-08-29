import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/common_widgets.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
  });

  Future<void> _openApiDocs(
    BuildContext context,
  ) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}/docs',
    );

    try {
      final launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open API documentation.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open API documentation: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final mobile = Responsive.isMobile(context);

    final docsUrl = '${AppConstants.apiBaseUrl}/docs';

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        mobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppPageHeader(
            title: 'Support',
            subtitle: 'GymFlow Pro API support.',
          ),
          const SizedBox(
            height: 24,
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Use the API documentation to inspect available endpoints and schemas.',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SelectableText(
                    docsUrl,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _openApiDocs(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.open_in_new_outlined,
                    ),
                    label: const Text(
                      'Open API Docs',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
