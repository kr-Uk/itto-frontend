import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class SignupPhotoStep extends StatefulWidget {
  final VoidCallback onNext;

  const SignupPhotoStep({super.key, required this.onNext});

  @override
  State<SignupPhotoStep> createState() => _SignupPhotoStepState();
}

class _SignupPhotoStepState extends State<SignupPhotoStep> {
  final List<XFile> _photos = [];
  int _representativeIndex = -1;
  final ImagePicker _picker = ImagePicker();

  bool get _isValid => _photos.isNotEmpty && _representativeIndex >= 0;
  bool get _hasPhotos => _photos.isNotEmpty;

  Future<void> _addPhoto() async {
    if (_photos.length >= 3) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(image);
        if (_photos.length == 1) {
          _representativeIndex = 0;
        }
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      if (_representativeIndex == index) {
        _representativeIndex = _photos.isNotEmpty ? 0 : -1;
      } else if (_representativeIndex > index) {
        _representativeIndex--;
      }
    });
  }

  void _selectRepresentative(int index) {
    setState(() => _representativeIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            _hasPhotos ? '대표 사진을\n선택해 주세요.' : '프로필 사진을\n등록해 주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _hasPhotos
                ? '사진은 언제든 변경할 수 있어요.'
                : '사진은 최대 3장까지 등록이 가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          if (!_hasPhotos)
            Center(
              child: GestureDetector(
                onTap: _addPhoto,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(_photos.length, (index) {
                  final isRepresentative = _representativeIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _photos.length - 1 ||
                              _photos.length < 3
                          ? 12
                          : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => _selectRepresentative(index),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_photos[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isRepresentative)
                            Positioned(
                              top: -6,
                              left: -6,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.background,
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (_photos.length < 3)
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 28,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _hasPhotos
                      ? '다른 사람의 사진을 사용하면 처벌받을 수 있어요.'
                      : '본인이 잘 드러나는 사진을 사용해 보세요!',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: _isValid,
            onPressed: widget.onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
