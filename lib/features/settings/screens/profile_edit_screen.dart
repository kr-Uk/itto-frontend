import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../profile/models/profile_models.dart';
import '../../profile/providers/profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String _nickname = '';
  String _bio = '';
  Set<int> _selectedHobbyIds = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.loadMyProfile();
      provider.fetchAllHobbies();
    });
  }

  void _initFromProfile() {
    if (_initialized) return;
    final profile = context.read<ProfileProvider>().myProfile;
    if (profile != null) {
      _nickname = profile.nickname;
      _bio = profile.introduction ?? '';
      _selectedHobbyIds = profile.hobbies.map((h) => h.id).toSet();
      _initialized = true;
    }
  }

  // -------------------------------------------------------------------
  // Nickname edit
  // -------------------------------------------------------------------
  void _editNickname() async {
    final controller = TextEditingController(text: _nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _TextEditDialog(
        title: '닉네임 수정',
        controller: controller,
        maxLength: 8,
      ),
    );
    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      final trimmed = result.trim();
      final success = await context
          .read<ProfileProvider>()
          .updateProfile(nickname: trimmed);
      if (success && mounted) {
        setState(() => _nickname = trimmed);
      }
    }
  }

  // -------------------------------------------------------------------
  // Bio edit
  // -------------------------------------------------------------------
  void _editBio() async {
    final controller = TextEditingController(text: _bio);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _TextEditDialog(
        title: '한줄소개 수정',
        controller: controller,
        maxLength: 15,
      ),
    );
    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      final trimmed = result.trim();
      final success = await context
          .read<ProfileProvider>()
          .updateProfile(introduction: trimmed);
      if (success && mounted) {
        setState(() => _bio = trimmed);
      }
    }
  }

  // -------------------------------------------------------------------
  // Edit hobbies via Bottom Sheet
  // -------------------------------------------------------------------
  void _editHobbies() async {
    final provider = context.read<ProfileProvider>();
    if (provider.allHobbies.isEmpty) {
      await provider.fetchAllHobbies();
    }
    if (!mounted) return;

    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _HobbySelectionSheet(
        allHobbies: provider.allHobbies,
        selectedIds: Set<int>.from(_selectedHobbyIds),
      ),
    );

    if (!mounted || result == null) return;

    final success = await context
        .read<ProfileProvider>()
        .updateProfile(hobbyIds: result.toList());
    if (success && mounted) {
      setState(() => _selectedHobbyIds = result);
    }
  }

  // -------------------------------------------------------------------
  // Reverify selfie
  // -------------------------------------------------------------------
  void _reverify() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '재인증 요청',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('촬영한 셀카로 재인증을 요청하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('요청', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success =
        await context.read<ProfileProvider>().reverify(image.path);
    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(context, '재인증 요청이 접수되었습니다');
    } else {
      SnackBarUtils.showError(
        context,
        context.read<ProfileProvider>().error ?? '재인증 요청에 실패했습니다',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        _initFromProfile();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const IttoAppBar(title: '프로필 설정'),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // -- Profile photo --
                Center(
                  child: GestureDetector(
                    onTap: () => context.push('/profile/photo'),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceLight,
                            border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.4),
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: Builder(
                              builder: (context) {
                                final profile = profileProvider.myProfile;
                                final representativePhotos = profile?.photos
                                    .where((p) => p.isRepresentative)
                                    .toList();
                                final photoUrl = (representativePhotos != null &&
                                        representativePhotos.isNotEmpty)
                                    ? representativePhotos.first.url
                                    : (profile?.photos.isNotEmpty == true
                                        ? profile!.photos.first.url
                                        : null);

                                if (photoUrl != null && photoUrl.isNotEmpty) {
                                  return CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (_, _) => const Icon(
                                      Icons.person,
                                      color: AppColors.textTertiary,
                                      size: 56,
                                    ),
                                    errorWidget: (_, _, _) => const Icon(
                                      Icons.person,
                                      color: AppColors.textTertiary,
                                      size: 56,
                                    ),
                                  );
                                }
                                return const Icon(
                                  Icons.person,
                                  color: AppColors.textTertiary,
                                  size: 56,
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                color: AppColors.background,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // -- Nickname --
                Center(
                  child: GestureDetector(
                    onTap: _editNickname,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _nickname,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // -- Bio section --
                _SectionHeader(
                  title: '한줄소개',
                  onEdit: _editBio,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _bio,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // -- Keywords section --
                _SectionHeader(
                  title: '관심사 키워드',
                  onEdit: _editHobbies,
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final allHobbies = profileProvider.allHobbies;
                    final hobbyNames = _selectedHobbyIds.map((id) {
                      final match = allHobbies.where((h) => h.id == id);
                      if (match.isNotEmpty) return match.first.name;
                      final profileMatch = profileProvider.myProfile?.hobbies
                          .where((h) => h.id == id);
                      if (profileMatch != null && profileMatch.isNotEmpty) {
                        return profileMatch.first.name;
                      }
                      return null;
                    }).whereType<String>().toList();

                    if (hobbyNames.isEmpty) {
                      return GestureDetector(
                        onTap: _editHobbies,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '취미를 선택해 주세요',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final name in hobbyNames)
                          _KeywordChip(label: name),
                        GestureDetector(
                          onTap: _editHobbies,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '변경',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),

                // -- Reverify section --
                const _SectionHeader(title: '본인 인증'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _reverify,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '셀카로 재인증 요청',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section header with optional edit icon
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;

  const _SectionHeader({required this.title, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Keyword chip (read-only display)
// ---------------------------------------------------------------------------

class _KeywordChip extends StatelessWidget {
  final String label;

  const _KeywordChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hobby selection bottom sheet
// ---------------------------------------------------------------------------

class _HobbySelectionSheet extends StatefulWidget {
  final List<HobbyItem> allHobbies;
  final Set<int> selectedIds;

  const _HobbySelectionSheet({
    required this.allHobbies,
    required this.selectedIds,
  });

  @override
  State<_HobbySelectionSheet> createState() => _HobbySelectionSheetState();
}

class _HobbySelectionSheetState extends State<_HobbySelectionSheet> {
  late Set<int> _selected;

  static const int _maxSelection = 3;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.selectedIds);
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < _maxSelection) {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  '관심사 키워드 선택',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selected.length} / $_maxSelection',
                  style: TextStyle(
                    color: _selected.length >= _maxSelection
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '최대 $_maxSelection개까지 선택할 수 있어요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.allHobbies.map((hobby) {
                  final isSelected = _selected.contains(hobby.id);
                  return GestureDetector(
                    onTap: () => _toggle(hobby.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        hobby.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _selected.isNotEmpty
                      ? AppColors.buttonGradient
                      : null,
                  color: _selected.isEmpty ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: _selected.isNotEmpty
                      ? () => Navigator.of(context).pop(_selected)
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable text-edit dialog
// ---------------------------------------------------------------------------

class _TextEditDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? hint;
  final int? maxLength;

  const _TextEditDialog({
    required this.title,
    required this.controller,
    this.hint,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLength: maxLength,
              autofocus: true,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('확인'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
