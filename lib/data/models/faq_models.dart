class FAQ {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isActive;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'other',
    this.order = 0,
    this.isActive = true,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      category: json['category'] ?? 'other',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'is_active': isActive,
    };
  }
}
