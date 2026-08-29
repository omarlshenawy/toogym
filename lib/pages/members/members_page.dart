import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/members_api.dart';
import '../../core/auth.dart';
import '../../core/common_widgets.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({
    super.key,
  });

  @override
  ConsumerState<MembersPage> createState() =>
      _MembersPageState();
}

class _MembersPageState
    extends ConsumerState<MembersPage> {
  final TextEditingController _searchController =
  TextEditingController();

  List<Map<String, dynamic>> _members = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final members = await MembersApi.getMembers();

      if (!mounted) return;

      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _cleanError(e.toString());
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMembers {
    final query =
    _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _members;
    }

    return _members.where((member) {
      final firstName =
          member['first_name']?.toString() ?? '';

      final lastName =
          member['last_name']?.toString() ?? '';

      final email =
          member['email']?.toString() ?? '';

      final phone =
          member['phone']?.toString() ?? '';

      final searchable = [
        firstName,
        lastName,
        '$firstName $lastName',
        email,
        phone,
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        Responsive.isMobile(context)
            ? 16
            : 24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: 'Members',
            subtitle:
            'Manage member profiles and activity.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  _openMemberForm();
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Member'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSearch(),

          const SizedBox(height: 16),

          if (_loading)
            const SizedBox(
              height: 300,
              child: AppLoading(
                message: 'Loading members...',
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 300,
              child: AppErrorState(
                message: _error!,
                onRetry: _loadMembers,
              ),
            )
          else
            _buildMembersTable(
              canDelete:
              user?.isGymAdmin == true,
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText:
            'Search by name, email or phone...',
            prefixIcon: const Icon(
              Icons.search,
            ),
            suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(
                Icons.clear,
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMembersTable({
    required bool canDelete,
  }) {
    final members = _filteredMembers;

    if (members.isEmpty) {
      return Card(
        child: SizedBox(
          height: 300,
          child: AppEmptyState(
            icon: Icons.people_outline,
            title: _members.isEmpty
                ? 'No members yet'
                : 'No members found',
            message: _members.isEmpty
                ? 'Add your first gym member.'
                : 'Try a different search.',
            onAction: _members.isEmpty
                ? _openMemberForm
                : null,
            actionLabel:
            _members.isEmpty
                ? 'Add Member'
                : null,
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 28,
          columns: const [
            DataColumn(
              label: Text('Member'),
            ),
            DataColumn(
              label: Text('Contact'),
            ),
            DataColumn(
              label: Text('Status'),
            ),
            DataColumn(
              label: Text('Joined'),
            ),
            DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: members.map((member) {
            return DataRow(
              cells: [
                DataCell(
                  _memberCell(member),
                ),
                DataCell(
                  _contactCell(member),
                ),
                DataCell(
                  _StatusBadge(
                    value:
                    member['status']
                        ?.toString() ??
                        '',
                  ),
                ),
                DataCell(
                  Text(
                    _formatDate(
                      member['joined_at'],
                    ),
                  ),
                ),
                DataCell(
                  _actions(
                    member,
                    canDelete,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _memberCell(
      Map<String, dynamic> member,
      ) {
    final first =
        member['first_name']?.toString() ?? '';

    final last =
        member['last_name']?.toString() ?? '';

    final id =
        member['id']?.toString() ?? '';

    return SizedBox(
      width: 180,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            '$first $last',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${_shortId(id)}…',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCell(
      Map<String, dynamic> member,
      ) {
    final email =
    member['email']?.toString();

    final phone =
        member['phone']?.toString() ?? '';

    return SizedBox(
      width: 220,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            email == null || email.isEmpty
                ? '—'
                : email,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            phone,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(
      Map<String, dynamic> member,
      bool canDelete,
      ) {
    final id =
        member['id']?.toString() ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            context.go('/members/$id');
          },
          child: const Text('View'),
        ),

        TextButton(
          onPressed: () {
            _openMemberForm(
              member: member,
            );
          },
          child: const Text('Edit'),
        ),

        if (canDelete)
          TextButton(
            onPressed: () {
              _confirmDelete(member);
            },
            style: TextButton.styleFrom(
              foregroundColor:
              AppTheme.danger,
            ),
            child: const Text('Delete'),
          ),
      ],
    );
  }

  Future<void> _openMemberForm({
    Map<String, dynamic>? member,
  }) async {
    final saved =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return _MemberFormDialog(
          member: member,
        );
      },
    );

    if (saved == true) {
      await _loadMembers();
    }
  }

  Future<void> _confirmDelete(
      Map<String, dynamic> member,
      ) async {
    final first =
        member['first_name']?.toString() ?? '';

    final last =
        member['last_name']?.toString() ?? '';

    final id =
        member['id']?.toString() ?? '';

    final confirmed =
    await AppConfirmDialog.show(
      context: context,
      title: 'Delete member?',
      message:
      'Are you sure you want to delete $first $last?',
      confirmLabel: 'Delete',
    );

    if (!confirmed) {
      return;
    }

    try {
      await MembersApi.deleteMember(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Member deleted successfully.',
          ),
        ),
      );

      await _loadMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(e.toString()),
          ),
        ),
      );
    }
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }

    return id.substring(0, 8);
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '—';
    }

    final text = value.toString();

    if (text.length >= 10) {
      return text.substring(0, 10);
    }

    return text;
  }

  String _cleanError(String value) {
    if (value.startsWith('Exception: ')) {
      return value.substring(11);
    }

    return value;
  }
}

// =================================================================
// Member Form
// =================================================================

class _MemberFormDialog extends StatefulWidget {
  final Map<String, dynamic>? member;

  const _MemberFormDialog({
    this.member,
  });

  @override
  State<_MemberFormDialog> createState() =>
      _MemberFormDialogState();
}

class _MemberFormDialogState
    extends State<_MemberFormDialog> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _firstName;

  late final TextEditingController
  _lastName;

  late final TextEditingController
  _email;

  late final TextEditingController
  _phone;

  late final TextEditingController
  _dateOfBirth;

  late final TextEditingController
  _gender;

  late final TextEditingController
  _height;

  late final TextEditingController
  _weight;

  bool _saving = false;

  bool get isEditing =>
      widget.member != null;

  @override
  void initState() {
    super.initState();

    final member = widget.member;

    _firstName = TextEditingController(
      text:
      member?['first_name']
          ?.toString() ??
          '',
    );

    _lastName = TextEditingController(
      text:
      member?['last_name']
          ?.toString() ??
          '',
    );

    _email = TextEditingController(
      text:
      member?['email']
          ?.toString() ??
          '',
    );

    _phone = TextEditingController(
      text:
      member?['phone']
          ?.toString() ??
          '',
    );

    _dateOfBirth =
        TextEditingController(
          text:
          member?['date_of_birth']
              ?.toString() ??
              '',
        );

    _gender = TextEditingController(
      text:
      member?['gender']
          ?.toString() ??
          '',
    );

    _height = TextEditingController(
      text:
      member?['height']
          ?.toString() ??
          '',
    );

    _weight = TextEditingController(
      text:
      member?['weight']
          ?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _dateOfBirth.dispose();
    _gender.dispose();
    _height.dispose();
    _weight.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEditing
            ? 'Edit Member'
            : 'Add New Member',
      ),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _field(
                  _firstName,
                  'First name',
                  required: true,
                ),
                _field(
                  _lastName,
                  'Last name',
                  required: true,
                ),
                _field(
                  _email,
                  'Email',
                  keyboardType:
                  TextInputType.emailAddress,
                ),
                _field(
                  _phone,
                  'Phone',
                  required: true,
                  keyboardType:
                  TextInputType.phone,
                ),
                _field(
                  _dateOfBirth,
                  'Date of birth',
                  hint: 'YYYY-MM-DD',
                ),
                _field(
                  _gender,
                  'Gender',
                ),
                _field(
                  _height,
                  'Height (cm)',
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _field(
                  _weight,
                  'Weight (kg)',
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
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
          child: const Text('Cancel'),
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
              color: Colors.white,
            ),
          )
              : Text(
            isEditing
                ? 'Save member'
                : 'Create member',
          ),
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        bool required = false,
        String? hint,
        TextInputType? keyboardType,
      }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: required
            ? (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        }
            : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final height =
    double.tryParse(
      _height.text.trim(),
    );

    final weight =
    double.tryParse(
      _weight.text.trim(),
    );

    final body = {
      'first_name':
      _firstName.text.trim(),
      'last_name':
      _lastName.text.trim(),
      'email': _email.text.trim().isEmpty
          ? null
          : _email.text.trim(),
      'phone':
      _phone.text.trim(),
      'date_of_birth':
      _dateOfBirth.text.trim().isEmpty
          ? null
          : _dateOfBirth.text.trim(),
      'gender':
      _gender.text.trim().isEmpty
          ? null
          : _gender.text.trim(),
      'height': height,
      'weight': weight,
    };

    setState(() {
      _saving = true;
    });

    try {
      if (isEditing) {
        final id =
        widget.member!['id']
            .toString();

        await MembersApi.updateMember(
          id,
          body,
        );
      } else {
        await MembersApi.createMember(
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
            e.toString()
                .replaceFirst(
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
}

// =================================================================
// Status Badge
// =================================================================

class _StatusBadge extends StatelessWidget {
  final String value;

  const _StatusBadge({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final normalized =
    value.toLowerCase();

    final color =
    normalized == 'active'
        ? AppTheme.success
        : normalized == 'expired'
        ? AppTheme.warning
        : AppTheme.textSecondary;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
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
