import 'dart:convert';

class TagGraphData {
  final Map<String, int> tagList;
  final List<List<String>> tagGraph;

  TagGraphData({
    required this.tagList,
    required this.tagGraph,
  });

  factory TagGraphData.fromJson(Map<String, dynamic> json) {
    
    final content = json['content'] as Map<String, dynamic>;
    
    
    Map<String, int> tagList;
    final tagListRaw = content['_tagList'];
    if (tagListRaw is String) {
      
      tagList = Map<String, int>.from(
        jsonDecode(tagListRaw) as Map<String, dynamic>
      );
    } else {
      
      tagList = Map<String, int>.from(tagListRaw as Map<String, dynamic>);
    }

    
    List<List<String>> tagGraph;
    final tagGraphRaw = content['_tagGraph'];
    if (tagGraphRaw is String) {
      
      final decoded = jsonDecode(tagGraphRaw) as List<dynamic>;
      tagGraph = decoded
          .map((pair) => (pair as List<dynamic>).map((e) => e as String).toList())
          .toList();
    } else {
      
      tagGraph = (tagGraphRaw as List<dynamic>)
          .map((pair) => (pair as List<dynamic>).map((e) => e as String).toList())
          .toList();
    }

    return TagGraphData(
      tagList: tagList,
      tagGraph: tagGraph,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': false,
      'result': 'graphBoardData',
      'content': {
        '_tagList': jsonEncode(tagList),
        '_tagGraph': jsonEncode(tagGraph),
      }
    };
  }

  
  int getTagFrequency(String tag) {
    return tagList[tag] ?? 0;
  }

  
  List<String> getConnectedTags(String tag) {
    List<String> connected = [];
    for (var pair in tagGraph) {
      if (pair[0] == tag) {
        connected.add(pair[1]);
      } else if (pair[1] == tag) {
        connected.add(pair[0]);
      }
    }
    return connected;
  }
}