import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider for the current user ID
// In a real app, this would likely come from an authentication system
final currentUserIdProvider = Provider<int>((ref) {
  // For now, we'll use a default user ID of 1
  // In a real implementation, this would be dynamically determined
  return 1;
});