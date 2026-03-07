// Re-export domain PageResponse so existing data-layer imports keep working.
export 'package:itto/domain/common/entities/page_response.dart';

import 'package:itto/domain/common/entities/page_response.dart';

/// Helper to parse a paginated JSON response into a domain [PageResponse].
PageResponse<T> parsePageResponse<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) fromItem,
) {
  return PageResponse(
    content:
        (json['content'] as List<dynamic>?)
            ?.map((e) => fromItem(e as Map<String, dynamic>))
            .toList() ??
        [],
    page: json['page'] as int? ?? 0,
    size: json['size'] as int? ?? 20,
    totalElements: json['totalElements'] as int? ?? 0,
    totalPages: json['totalPages'] as int? ?? 0,
  );
}
