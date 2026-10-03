import '../../domain/entities/ai_coach_response.dart';

class AICoachResponseModel extends AICoachResponse {
  const AICoachResponseModel({
    required super.response,
  });

  factory AICoachResponseModel.fromJson(Map<String, dynamic> json) {
    return AICoachResponseModel(
      response: json['response']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
    };
  }
}