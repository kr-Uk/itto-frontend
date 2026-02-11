import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';

class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  // Mock photo data: null means empty slot, non-null is a placeholder label
  final List<String?> _photos = ['사진 1', '사진 2', null];

  void _deletePhoto(int index) {
    setState(() {
      _photos[index] = null;
    });
  }

  void _uploadPhoto() {
    // Find the first empty slot and fill it with a mock photo
    final emptyIndex = _photos.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _photos[emptyIndex] = '사진 ${emptyIndex + 1}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEmptySlot = _photos.contains(null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '프로필 사진'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Subtitle --
            const Text(
              '프로필 사진을 수정해 보세요.\n최대 3개까지 올릴 수 있어요.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // -- Photo thumbnails --
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  _PhotoThumbnail(
                    label: _photos[i],
                    isPrimary: i == 0 && _photos[i] != null,
                    onDelete: _photos[i] != null
                        ? () => _deletePhoto(i)
                        : null,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),

            // -- Upload button --
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: hasEmptySlot ? _uploadPhoto : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: hasEmptySlot
                        ? AppColors.textTertiary
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledForegroundColor:
                      AppColors.textTertiary.withValues(alpha: 0.4),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, size: 20),
                    SizedBox(width: 8),
                    Text('사진 업로드'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo thumbnail
// ---------------------------------------------------------------------------

class _PhotoThumbnail extends StatelessWidget {
  final String? label;
  final bool isPrimary;
  final VoidCallback? onDelete;

  const _PhotoThumbnail({
    required this.label,
    this.isPrimary = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = label != null;

    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Photo container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: hasPhoto ? AppColors.surfaceLight : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto
                    ? AppColors.divider
                    : AppColors.textTertiary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: hasPhoto
                ? Center(
                    child: Icon(
                      Icons.image,
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                      size: 36,
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.textTertiary.withValues(alpha: 0.4),
                      size: 32,
                    ),
                  ),
          ),

          // Star badge for primary photo
          if (isPrimary)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),

          // Delete button
          if (onDelete != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
