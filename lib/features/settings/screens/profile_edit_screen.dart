import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../profile/providers/profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String _nickname = '';
  String _bio = '';
  List<String> _keywords = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadMyProfile();
    });
  }

  void _initFromProfile() {
    if (_initialized) return;
    final profile = context.read<ProfileProvider>().myProfile;
    if (profile != null) {
      _nickname = profile.nickname;
      _bio = profile.introduction ?? '';
      _keywords = profile.hobbies.map((h) => h.name).toList();
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
  // Keyword add
  // -------------------------------------------------------------------
  void _addKeyword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _TextEditDialog(
        title: '키워드 추가',
        controller: controller,
        hint: '새 키워드 입력',
        maxLength: 10,
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _keywords = [..._keywords, result.trim()]);
      _syncKeywordsToServer();
    }
  }

  // -------------------------------------------------------------------
  // Keyword remove
  // -------------------------------------------------------------------
  void _removeKeyword(int index) {
    setState(() {
      _keywords = List.from(_keywords)..removeAt(index);
    });
    _syncKeywordsToServer();
  }

  // -------------------------------------------------------------------
  // Sync keywords to server by mapping names to hobby IDs
  // -------------------------------------------------------------------
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

  void _syncKeywordsToServer() {
    final profile = context.read<ProfileProvider>().myProfile;
    if (profile == null) return;

    final hobbyIds = <int>[];
    for (final keyword in _keywords) {
      final match = profile.hobbies.where((h) => h.name == keyword);
      if (match.isNotEmpty) {
        hobbyIds.add(match.first.id);
      }
    }
    context.read<ProfileProvider>().updateProfile(hobbyIds: hobbyIds);
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
                          child: const Icon(
                            Icons.person,
                            color: AppColors.textTertiary,
                            size: 56,
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
                const _SectionHeader(title: '관심사 키워드'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _keywords.length; i++)
                      _KeywordChip(
                        label: _keywords[i],
                        onDelete: () => _removeKeyword(i),
                      ),
                    // Add button
                    GestureDetector(
                      onTap: _addKeyword,
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
                              Icons.add,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '추가',
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
// Keyword chip
// ---------------------------------------------------------------------------

class _KeywordChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const _KeywordChip({required this.label, this.onDelete});

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.close,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ),
          ],
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
