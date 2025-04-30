class AIModel {
  final String name;
  final String displayName;
  final String description;
  final int inputTokenLimit;
  final int outputTokenLimit;

  const AIModel({
    required this.name,
    this.displayName = '',
    this.description = '',
    this.inputTokenLimit = 0,
    this.outputTokenLimit = 0,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      inputTokenLimit: json['inputTokenLimit'] ?? 0,
      outputTokenLimit: json['outputTokenLimit'] ?? 0,
    );
  }
}
