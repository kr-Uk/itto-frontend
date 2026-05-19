import 'dart:io';

import 'package:dio/dio.dart';
import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/chat/models/chat_message_model.dart';
import 'package:itto/data/chat/models/chat_room_model.dart';

/// 백엔드 REST API 호출 datasource.
///
/// 모든 응답은 `ApiResponse<T>` 래퍼이므로 `data` 필드에서 실제 페이로드를 꺼낸다.
class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /chat/rooms — 내 활성 채팅방 목록 (lastMessageAt DESC)
  Future<List<ChatRoomModel>> listRooms() async {
    final response = await _apiClient.get('/chat/rooms');
    final data = response['data'] as Map<String, dynamic>;
    final rooms = data['rooms'] as List<dynamic>;
    return rooms
        .map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /chat/rooms/{chatRoomId}/messages?page=&size=
  /// 페이지 0 = 최신 메시지. 응답은 page/size/totalElements 등을 포함.
  Future<List<ChatMessageModel>> getMessages(
    int chatRoomId, {
    int page = 0,
    int size = 30,
  }) async {
    final response = await _apiClient.get(
      '/chat/rooms/$chatRoomId/messages',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response['data'] as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return content
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /chat/rooms/{chatRoomId}/read — 상대 메시지를 모두 읽음 처리
  Future<int> markAsRead(int chatRoomId) async {
    final response = await _apiClient.post('/chat/rooms/$chatRoomId/read');
    final data = response['data'] as Map<String, dynamic>;
    return (data['updatedCount'] as num?)?.toInt() ?? 0;
  }

  /// POST /chat/rooms/{chatRoomId}/images — 이미지 업로드 후 URL 반환
  Future<String> uploadImage({
    required int chatRoomId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split(Platform.pathSeparator).last),
    });
    final response = await _apiClient.postMultipart(
      '/chat/rooms/$chatRoomId/images',
      formData: formData,
    );
    final data = response['data'] as Map<String, dynamic>;
    return data['imageUrl'] as String;
  }
}
