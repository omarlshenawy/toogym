import 'package:flutter/material.dart';

import '../../api/saas_plans_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class SaasPlansPage extends StatefulWidget {
  const SaasPlansPage({
    super.key,
  });

  @override
  State<SaasPlansPage> createState() =>
      _SaasPlansPageState();
}

class _SaasPlansPageState
    extends State<SaasPlansPage> {
  List<Map<String, dynamic>> _plans = [];

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _openPlan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plans =
      await SaasPlansApi.getPlans();

      if (!mounted) return;

      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanError(
          e.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile =
    Responsive.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        mobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'SaaS Plans',
            subtitle:
            'Manage plans sold to gyms.',
            actions: [
              ElevatedButton.icon(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => SaasPlanDialog(
                      plan: null,
                    ),
                  );

                  if (saved == true) {
                    await _load();
                  }
                },
                icon:
                const Icon(Icons.add),
                label:
                const Text(
                  'New SaaS Plan',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (_loading)
            const SizedBox(
              height: 300,
              child: AppLoading(
                message:
                'Loading SaaS plans...',
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 300,
              child: AppErrorState(
                message: _error!,
                onRetry: _load,
              ),
            )
          else
            _buildTable(),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_plans.isEmpty) {
      return Card(
        child: SizedBox(
          height: 280,
          child: AppEmptyState(
            icon:
            Icons.layers_outlined,
            title:
            'No SaaS plans',
            message:
            'Create a plan to sell to gyms.',
            onAction: () async {
              final saved = await showDialog<bool>(
                context: context,
                builder: (_) => SaasPlanDialog(
                  plan: null,
                ),
              );

              if (saved == true) {
                await _load();
              }
            },
            actionLabel:
            'New SaaS Plan',
          ),
        ),
      );
    }

    return Card(
      clipBehavior:
      Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,
        child: DataTable(
          columnSpacing: 36,
          columns: const [
            DataColumn(
              label: Text('Plan'),
            ),
            DataColumn(
              label: Text('Price'),
            ),
            DataColumn(
              label:
              Text('Max members'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: _plans.map(
                (plan) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 240,
                      child:
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            plan['name']
                                ?.toString() ??
                                '—',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                          Text(
                            plan['description']
                                ?.toString()
                                .isNotEmpty ==
                                true
                                ? plan[
                            'description']
                                .toString()
                                : '—',
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontSize:
                              12,
                              color:
                              AppTheme
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      _money(
                        plan['price'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      plan[
                      'max_members_per_gym'] ==
                          null
                          ? 'Unlimited'
                          : plan[
                      'max_members_per_gym']
                          .toString(),
                    ),
                  ),

                  DataCell(
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _openPlan =
                              plan;
                        });
                      },
                      child:
                      const Text(
                        'Edit',
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  String _money(dynamic value) {
    final number =
        double.tryParse(
          value?.toString() ??
              '',
        ) ??
            0;

    return '\$${number.toStringAsFixed(2)}';
  }

  String _cleanError(String value) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}


class SaasPlanDialog extends StatefulWidget {
  final Map<String, dynamic>? plan;

  const SaasPlanDialog({
    super.key,
    this.plan,
  });

  @override
  State<SaasPlanDialog> createState() =>
      _SaasPlanDialogState();
}

class _SaasPlanDialogState
    extends State<SaasPlanDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _name;

  late final TextEditingController
  _description;

  late final TextEditingController
  _price;

  late final TextEditingController
  _maxMembers;

  bool _saving = false;

  bool get editing =>
      widget.plan != null;

  @override
  void initState() {
    super.initState();

    final plan =
        widget.plan;

    _name =
        TextEditingController(
          text:
          plan?['name']
              ?.toString() ??
              '',
        );

    _description =
        TextEditingController(
          text:
          plan?['description']
              ?.toString() ??
              '',
        );

    _price =
        TextEditingController(
          text:
          plan?['price']
              ?.toString() ??
              '',
        );

    _maxMembers =
        TextEditingController(
          text:
          plan?['max_members_per_gym']
              ?.toString() ??
              '',
        );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _maxMembers.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editing
            ? 'Edit SaaS Plan'
            : 'New SaaS Plan',
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              _field(
                _name,
                'Name',
                required: true,
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _description,
                'Description',
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _price,
                'Price',
                required: true,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _field(
                _maxMembers,
                'Max members per gym',
                keyboardType:
                TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
            Navigator.pop(
              context,
              false,
            );
          },
          child:
          const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
          _saving ? null : _save,
          child: _saving
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
              color:
              Colors.white,
            ),
          )
              : const Text(
            'Save plan',
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool required = false,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller:
      controller,
      keyboardType:
      keyboardType,
      decoration:
      InputDecoration(
        labelText: label,
      ),
      validator:
      required
          ? (value) {
        if (value ==
            null ||
            value
                .trim()
                .isEmpty) {
          return '$label is required';
        }

        return null;
      }
          : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final price =
    double.tryParse(
      _price.text.trim(),
    );

    if (price == null) {
      _showError(
        'Enter a valid price.',
      );
      return;
    }

    final maxMembers =
    _maxMembers.text
        .trim()
        .isEmpty
        ? null
        : int.tryParse(
      _maxMembers.text
          .trim(),
    );

    if (_maxMembers.text
        .trim()
        .isNotEmpty &&
        maxMembers == null) {
      _showError(
        'Max members must be a number.',
      );
      return;
    }

    final body =
    <String, dynamic>{
      'name':
      _name.text.trim(),
      'description':
      _description.text
          .trim()
          .isEmpty
          ? null
          : _description.text.trim(),
      'price':
      price,
      'max_members_per_gym':
      maxMembers,
    };

    setState(() {
      _saving = true;
    });

    try {
      if (editing) {
        await SaasPlansApi
            .updatePlan(
          widget.plan!['id']
              .toString(),
          body,
        );
      } else {
        await SaasPlansApi
            .createPlan(
          body,
        );
      }

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}