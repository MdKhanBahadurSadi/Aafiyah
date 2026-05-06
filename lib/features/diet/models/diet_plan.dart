class DietPlan {
  final String title;
  final String description;
  final List<Meal> meals;
  final List<String> generalAdvice;
  final List<String> restrictions;

  DietPlan({
    required this.title,
    required this.description,
    required this.meals,
    required this.generalAdvice,
    required this.restrictions,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      title: json['title'] as String,
      description: json['description'] as String,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
      generalAdvice: List<String>.from(json['generalAdvice'] as List),
      restrictions: List<String>.from(json['restrictions'] as List),
    );
  }
}

class Meal {
  final String time; // e.g., "Breakfast", "Lunch", "Dinner", "Snack"
  final String suggestion;
  final String recipeLink; // Optional or simplified recipe
  final String calories;

  Meal({
    required this.time,
    required this.suggestion,
    required this.recipeLink,
    required this.calories,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      time: json['time'] as String,
      suggestion: json['suggestion'] as String,
      recipeLink: json['recipeLink'] as String? ?? "",
      calories: json['calories'] as String? ?? "N/A",
    );
  }
}
