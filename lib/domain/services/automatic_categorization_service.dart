import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';

class AutomaticCategorizationService {
  final List<Category> categories;

  AutomaticCategorizationService(this.categories);

  /// Categorizes a transaction based on its description using rule-based approach
  int? categorizeTransaction(Transaction transaction) {
    final description = transaction.description?.toLowerCase() ?? '';
    
    // Define keyword mappings to category IDs
    // In a real implementation, these would come from a database or configuration
    final keywordMappings = {
      1: ['salary', 'paycheck', 'wage', 'income'], // Salary category
      2: ['grocery', 'food', 'supermarket', 'groceries'], // Food category
      3: ['gas', 'fuel', 'petrol', 'diesel'], // Gas category
      4: ['rent', 'mortgage', 'housing'], // Housing category
      5: ['electricity', 'water', 'utilities', 'internet', 'phone'], // Utilities category
      6: ['entertainment', 'movie', 'concert', 'show'], // Entertainment category
      7: ['shopping', 'clothing', 'retail'], // Shopping category
      8: ['health', 'medical', 'doctor', 'hospital'], // Health category
      9: ['transport', 'bus', 'train', 'taxi', 'uber'], // Transportation category
      10: ['restaurant', 'dining', 'meal', 'lunch', 'dinner'], // Dining category
    };

    // Check each category for matching keywords
    for (final entry in keywordMappings.entries) {
      final categoryId = entry.key;
      final keywords = entry.value;
      
      for (final keyword in keywords) {
        if (description.contains(keyword)) {
          return categoryId;
        }
      }
    }

    // Return default category if no match found (e.g., "Uncategorized")
    return null;
  }

  /// Learns from user corrections to improve future categorizations
  void learnFromCorrection(String description, int categoryId) {
    // In a more advanced implementation, this would update the keyword mappings
    // or train a machine learning model based on user corrections
    // For now, this is a placeholder for future enhancement
  }
}