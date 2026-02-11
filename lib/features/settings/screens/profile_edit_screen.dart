import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String _nickname = '치맛이';
  String _bio = '오마이 오마이 갓';
  List<String> _keywords = ['영화', '사주/타로', '식물'];

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
        maxLength: 10,
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _nickname = result.trim());
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
        maxLength: 30,
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _bio = result.trim());
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
    }
  }

  // -------------------------------------------------------------------
  // Keyword remove
  // -------------------------------------------------------------------
  void _removeKeyword(int index) {
    setState(() {
      _keywords = List.from(_keywords)..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '프로필 설정'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          color: AppColors.primary.withValues(alpha: 0.4),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.6),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
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
