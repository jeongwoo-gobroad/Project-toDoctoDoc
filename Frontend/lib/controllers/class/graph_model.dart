// Tag information model
import 'dart:convert';
class TagInfo {
  final double tagCount;
  final double viewCount;

  TagInfo({
    required this.tagCount,
    required this.viewCount,
  });

  factory TagInfo.fromJson(Map<String, dynamic> json) {
    return TagInfo(
      tagCount: (json['tagCount'] as num).toDouble(),
      viewCount: (json['viewCount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tagCount': tagCount,
    'viewCount': viewCount,
  };
}

class Content {
  final Map<String, TagInfo> bubbleList;

  Content({
    required this.bubbleList,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    var bubbleData = json['_bubbleList'];
    if (bubbleData is String) {
      bubbleData = jsonDecode(bubbleData);
    }
    
    final Map<String, TagInfo> bubbleList = {};
    
    if (bubbleData is Map<String, dynamic>) {
      bubbleData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          bubbleList[key] = TagInfo.fromJson(value);
        }
      });
    }

    return Content(bubbleList: bubbleList);
  }

  Map<String, dynamic> toJson() => {
    '_bubbleList': bubbleList.map((key, value) => MapEntry(key, value.toJson())),
  };
}
class GraphBoardData {
  final bool error;
  final String result;
  final Content content;

  GraphBoardData({
    required this.error,
    required this.result,
    required this.content,
  });

  factory GraphBoardData.fromJson(Map<String, dynamic> json) {
    var contentData = json['content'];
    if (contentData is String) {
      contentData = jsonDecode(contentData);
    }

    return GraphBoardData(
      error: json['error'] as bool,
      result: json['result'] as String,
      content: Content.fromJson(contentData as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'error': error,
    'result': result,
    'content': content.toJson(),
  };
}