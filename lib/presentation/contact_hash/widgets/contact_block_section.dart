import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';

class ContactBlockSection extends ConsumerStatefulWidget {
  const ContactBlockSection({super.key});

  @override
  ConsumerState<ContactBlockSection> createState() => _ContactBlockSectionState();
}

class _ContactBlockSectionState extends ConsumerState<ContactBlockSection> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) { final provider = ref.watch(contactHashChangeNotifierProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '연락처 차단',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (provider.contactPermissionDenied)
              const Text('연락처 권한이 필요합니다')
            else
              ElevatedButton(
                onPressed: provider.isLoading ? null : () {},
                child: const Text('연락처 동기화'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(hintText: '전화번호 직접 입력'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          if (_phoneController.text.isNotEmpty) {
                            provider.addManualBlock(_phoneController.text);
                            _phoneController.clear();
                          }
                        },
                  child: const Text('차단'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (provider.hashes.isNotEmpty)
              ...provider.hashes.map(
                (hash) => ListTile(
                  title: Text('${hash.phoneHash.substring(0, 8)}...'),
                  trailing: TextButton(
                    onPressed: () => provider.removeHash(hash.id),
                    child: const Text('해제'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
