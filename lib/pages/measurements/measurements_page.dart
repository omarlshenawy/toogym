import 'package:flutter/material.dart';

import '../../api/members_api.dart';
import '../../api/measurements_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({
    super.key,
  });

  @override
  State<MeasurementsPage> createState() =>
      _MeasurementsPageState();
}

class _MeasurementsPageState
    extends State<MeasurementsPage> {
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _measurements = [];

  String _memberId = '';

  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _openMeasurement;

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
      final members =
      await MembersApi.getMembers();

      if (!mounted) return;

      final selected =
      _memberId.isNotEmpty
          ? _memberId
          : members.isNotEmpty
          ? members.first['id'].toString()
          : '';

      List<Map<String, dynamic>> measurements = [];

      if (selected.isNotEmpty) {
        measurements =
        await MeasurementsApi
            .getMeasurements(
          selected,
        );
      }

      if (!mounted) return;

      setState(() {
        _members = members;
        _memberId = selected;
        _measurements = measurements;
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

  Future<void> _loadMeasurements() async {
    if (_memberId.isEmpty) {
      setState(() {
        _measurements = [];
      });
      return;
    }

    try {
      final measurements =
      await MeasurementsApi
          .getMeasurements(
        _memberId,
      );

      if (!mounted) return;

      setState(() {
        _measurements = measurements;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
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
            title: 'Measurements',
            subtitle:
            'Track member body measurements over time.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _memberId.isEmpty
                    ? null
                    : _openCreate,
                icon:
                const Icon(
                  Icons.add,
                ),
                label:
                const Text(
                  'Record',
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
                'Loading measurements...',
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
          else ...[
              _buildFilter(),
              const SizedBox(height: 16),
              _buildTable(),
            ],
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: SizedBox(
          width: 420,
          child:
          DropdownButtonFormField<
              String>(
            initialValue:
            _memberId.isEmpty
                ? null
                : _memberId,
            decoration:
            const InputDecoration(
              labelText: 'Member',
            ),
            disabledHint:
            const Text(
              'No members available',
            ),
            items: _members.map(
                  (member) {
                final id =
                    member['id']
                        ?.toString() ??
                        '';

                return DropdownMenuItem(
                  value: id,
                  child: Text(
                    '${member['first_name'] ?? ''} ${member['last_name'] ?? ''}',
                  ),
                );
              },
            ).toList(),
            onChanged:
            _members.isEmpty
                ? null
                : (value) async {
              if (value == null) {
                return;
              }

              setState(() {
                _memberId = value;
                _loading = true;
              });

              await _loadMeasurements();

              if (!mounted) return;

              setState(() {
                _loading = false;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_measurements.isEmpty) {
      return Card(
        child: SizedBox(
          height: 280,
          child: AppEmptyState(
            icon:
            Icons.monitor_weight_outlined,
            title:
            'No measurements',
            message:
            'Record the member\'s first body measurement.',
            onAction:
            _memberId.isEmpty
                ? null
                : _openCreate,
            actionLabel:
            'Record',
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
          columnSpacing: 32,
          columns: const [
            DataColumn(
              label:
              Text('Measured'),
            ),
            DataColumn(
              label:
              Text('Weight'),
            ),
            DataColumn(
              label:
              Text('Body Fat'),
            ),
            DataColumn(
              label:
              Text('BMI'),
            ),
            DataColumn(
              label:
              Text('Notes'),
            ),
            DataColumn(
              label:
              Text('Actions'),
            ),
          ],
          rows: _measurements.map(
                (measurement) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      _formatDate(
                        measurement[
                        'measured_at'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      measurement[
                      'weight'] !=
                          null
                          ? '${measurement['weight']} kg'
                          : '—',
                    ),
                  ),

                  DataCell(
                    Text(
                      measurement[
                      'body_fat_percentage'] !=
                          null
                          ? '${measurement['body_fat_percentage']}%'
                          : '—',
                    ),
                  ),

                  DataCell(
                    Text(
                      measurement[
                      'bmi'] !=
                          null
                          ? measurement[
                      'bmi']
                          .toString()
                          : '—',
                    ),
                  ),

                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        measurement[
                        'notes']
                            ?.toString()
                            .isNotEmpty ==
                            true
                            ? measurement[
                        'notes']
                            .toString()
                            : '—',
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ),
                  ),

                  DataCell(
                    TextButton(
                      onPressed: () {
                        _openEdit(
                          measurement,
                        );
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

  Future<void> _openCreate() async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _MeasurementDialog(
          memberId: _memberId,
        );
      },
    );

    if (saved == true) {
      await _loadMeasurements();
    }
  }

  Future<void> _openEdit(
      Map<String, dynamic> measurement,
      ) async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _MeasurementDialog(
          memberId: _memberId,
          measurement: measurement,
        );
      },
    );

    if (saved == true) {
      await _loadMeasurements();
    }
  }

  String _formatDate(
      dynamic value,
      ) {
    if (value == null) {
      return '—';
    }

    final text =
    value.toString();

    return text.length >= 10
        ? text.substring(0, 10)
        : text;
  }

  String _cleanError(
      String value,
      ) {
    return value.replaceFirst(
      'Exception: ',
      '',
    );
  }
}

// =================================================================
// Measurement Dialog
// =================================================================

class _MeasurementDialog
    extends StatefulWidget {
  final String memberId;
  final Map<String, dynamic>? measurement;

  const _MeasurementDialog({
    required this.memberId,
    this.measurement,
  });

  @override
  State<_MeasurementDialog> createState() =>
      _MeasurementDialogState();
}

class _MeasurementDialogState
    extends State<_MeasurementDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _weight;

  late final TextEditingController
  _bodyFat;

  late final TextEditingController
  _bmi;

  late final TextEditingController
  _notes;

  bool _saving = false;

  bool get editing =>
      widget.measurement != null;

  @override
  void initState() {
    super.initState();

    final measurement =
        widget.measurement;

    _weight =
        TextEditingController(
          text:
          measurement?['weight']
              ?.toString() ??
              '',
        );

    _bodyFat =
        TextEditingController(
          text:
          measurement?[
          'body_fat_percentage']
              ?.toString() ??
              '',
        );

    _bmi =
        TextEditingController(
          text:
          measurement?['bmi']
              ?.toString() ??
              '',
        );

    _notes =
        TextEditingController(
          text:
          measurement?['notes']
              ?.toString() ??
              '',
        );
  }

  @override
  void dispose() {
    _weight.dispose();
    _bodyFat.dispose();
    _bmi.dispose();
    _notes.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editing
            ? 'Edit Measurement'
            : 'Record Measurement',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              _numberField(
                controller: _weight,
                label: 'Weight',
              ),

              const SizedBox(
                height: 14,
              ),

              _numberField(
                controller: _bodyFat,
                label:
                'Body fat percentage',
                max: 100,
              ),

              const SizedBox(
                height: 14,
              ),

              _numberField(
                controller: _bmi,
                label: 'BMI',
              ),

              const SizedBox(
                height: 14,
              ),

              TextFormField(
                controller: _notes,
                decoration:
                const InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
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
              : Text(
            editing
                ? 'Save changes'
                : 'Save measurement',
          ),
        ),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController
    controller,
    required String label,
    double? max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      const TextInputType
          .numberWithOptions(
        decimal: true,
      ),
      decoration:
      InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return null;
        }

        final number =
        double.tryParse(
          value.trim(),
        );

        if (number == null) {
          return 'Enter a valid number';
        }

        if (number < 0) {
          return 'Cannot be negative';
        }

        if (max != null &&
            number > max) {
          return 'Maximum is $max';
        }

        return null;
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final body =
    <String, dynamic>{
      'weight':
      _nullableDouble(
        _weight.text,
      ),
      'body_fat_percentage':
      _nullableDouble(
        _bodyFat.text,
      ),
      'bmi':
      _nullableDouble(
        _bmi.text,
      ),
      'notes':
      _notes.text.trim().isEmpty
          ? null
          : _notes.text.trim(),
    };

    setState(() {
      _saving = true;
    });

    try {
      if (editing) {
        await MeasurementsApi
            .updateMeasurement(
          widget.memberId,
          widget.measurement![
          'id']
              .toString(),
          body,
        );
      } else {
        await MeasurementsApi
            .createMeasurement(
          widget.memberId,
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
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

  double? _nullableDouble(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(
      value.trim(),
    );
  }
}