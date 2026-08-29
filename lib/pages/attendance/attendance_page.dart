import 'package:flutter/material.dart';

import '../../api/attendance_api.dart';
import '../../api/members_api.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({
    super.key,
  });

  @override
  State<AttendancePage> createState() =>
      _AttendancePageState();
}

class _AttendancePageState
    extends State<AttendancePage> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _members = [];

  String _selectedMemberId = '';

  bool _loading = true;
  String? _error;

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
      final result =
      await Future.wait([
        AttendanceApi.getAttendance(),
        MembersApi.getMembers(),
      ]);

      if (!mounted) return;

      final attendance =
      result[0]
      as List<Map<String, dynamic>>;

      final members =
      result[1]
      as List<Map<String, dynamic>>;

      setState(() {
        _rows = attendance;
        _members = members;

        if (_selectedMemberId.isEmpty &&
            members.isNotEmpty) {
          _selectedMemberId =
              members.first['id']
                  .toString();
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  bool get _selectedMemberActive {
    if (_selectedMemberId.isEmpty) {
      return false;
    }

    return _rows.any(
          (attendance) =>
      attendance['member_id']
          ?.toString() ==
          _selectedMemberId &&
          attendance[
          'check_out_time'] ==
              null,
    );
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
            title: 'Attendance',
            subtitle:
            'Check members in and out.',
            actions: [
              ElevatedButton.icon(
                onPressed:
                _selectedMemberId
                    .isEmpty ||
                    _selectedMemberActive
                    ? null
                    : _checkIn,
                icon: const Icon(
                  Icons.login_outlined,
                ),
                label: Text(
                  _selectedMemberActive
                      ? 'Checked In'
                      : 'Check In',
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
                'Loading attendance...',
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
              _buildMemberSelector(),
              const SizedBox(height: 16),
              _buildTable(),
            ],
        ],
      ),
    );
  }

  Widget _buildMemberSelector() {
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
            _selectedMemberId
                .isEmpty
                ? null
                : _selectedMemberId,
            decoration:
            const InputDecoration(
              labelText:
              'Member to check in',
            ),
            items: _members
                .map(
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
                (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedMemberId =
                    value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (_rows.isEmpty) {
      return Card(
        child: SizedBox(
          height: 280,
          child: AppEmptyState(
            icon:
            Icons.fact_check_outlined,
            title:
            'No attendance records',
            message:
            'Check a member in to create the first attendance record.',
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
              Text('Member'),
            ),
            DataColumn(
              label:
              Text('Check in'),
            ),
            DataColumn(
              label:
              Text('Check out'),
            ),
            DataColumn(
              label:
              Text('Status'),
            ),
            DataColumn(
              label:
              Text('Action'),
            ),
          ],
          rows: _rows.map(
                (attendance) {
              final active =
                  attendance[
                  'check_out_time'] ==
                      null;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      _shortId(
                        attendance[
                        'member_id']
                            ?.toString() ??
                            '',
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      _formatDateTime(
                        attendance[
                        'check_in_time'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      _formatDateTime(
                        attendance[
                        'check_out_time'],
                      ),
                    ),
                  ),

                  DataCell(
                    _StatusBadge(
                      value: active
                          ? 'active'
                          : 'completed',
                    ),
                  ),

                  DataCell(
                    active
                        ? TextButton(
                      onPressed:
                          () {
                        _checkOut(
                          attendance[
                          'id']
                              .toString(),
                        );
                      },
                      child:
                      const Text(
                        'Check out',
                      ),
                    )
                        : const Text(
                      'Completed',
                      style:
                      TextStyle(
                        color:
                        AppTheme
                            .textSecondary,
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

  Future<void> _checkIn() async {
    if (_selectedMemberId
        .isEmpty) {
      return;
    }

    try {
      await AttendanceApi
          .checkIn(
        _selectedMemberId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Member checked in',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      _showError(e);
    }
  }

  Future<void> _checkOut(
      String attendanceId,
      ) async {
    try {
      await AttendanceApi
          .checkOut(
        attendanceId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Member checked out',
          ),
        ),
      );

      await _load();
    } catch (e) {
      if (!mounted) return;

      _showError(e);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          error
              .toString()
              .replaceFirst(
            'Exception: ',
            '',
          ),
        ),
      ),
    );
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }

    return '${value.substring(0, 8)}…';
  }

  String _formatDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return '—';
    }

    final text =
    value.toString();

    if (text.length >= 16) {
      return text
          .substring(0, 16)
          .replaceFirst(
        'T',
        ' ',
      );
    }

    return text;
  }
}

class _StatusBadge
    extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        value == 'active';

    final color = active
        ? AppTheme.success
        : AppTheme.textSecondary;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}