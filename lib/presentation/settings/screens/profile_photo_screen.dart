import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';
import 'package:itto/domain/common/entities/photo.dart';

class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileChangeNotifierProvider).loadMyProfile();
    });
  }

  Future<void> _deletePhoto(int photoId) async {
    await ref.read(profileChangeNotifierProvider).deletePhoto(photoId);
  }

  Future<void> _uploadPhoto() async {
    final profileProvider = ref.read(profileChangeNotifierProvider);
    final photos = profileProvider.myProfile?.photos ?? [];

    if (photos.length >= 3) return;

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;
    if (!mounted) return;

    // Determine representative index (keep existing representative, or 0 if first photo)
    final existingPhotoIds = photos.map((p) => p.id).toList();
    final representativeIndex = photos.isNotEmpty
        ? photos
              .indexWhere((p) => p.isRepresentative)
              .clamp(0, photos.length - 1)
        : 0;

    await profileProvider.updatePhotos(
      newPhotoPaths: [pickedFile.path],
      existingPhotoIds: existingPhotoIds,
      representativeIndex: representativeIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '프로필 사진'),
      body: Consumer(builder: (context, ref, _) { final profileProvider = ref.watch(profileChangeNotifierProvider);
          final photos = profileProvider.myProfile?.photos ?? [];
          final hasEmptySlot = photos.length < 3;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                            photo: i < photos.length ? photos[i] : null,
                            isPrimary:
                                i < photos.length && photos[i].isRepresentative,
                            onDelete: i < photos.length
                                ? () => _deletePhoto(photos[i].id)
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
                          disabledForegroundColor: AppColors.textTertiary
                              .withValues(alpha: 0.4),
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

              // Loading overlay
              if (profileProvider.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo thumbnail
// ---------------------------------------------------------------------------

class _PhotoThumbnail extends StatelessWidget {
  final Photo? photo;
  final bool isPrimary;
  final VoidCallback? onDelete;

  const _PhotoThumbnail({
    required this.photo,
    this.isPrimary = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = photo != null;

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
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: CachedNetworkImage(
                      imageUrl: photo!.url,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => Center(
                        child: Icon(
                          Icons.image,
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
                          size: 36,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
                          size: 36,
                        ),
                      ),
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
                child: const Icon(Icons.star, color: Colors.white, size: 14),
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
