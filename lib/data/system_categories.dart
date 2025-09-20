import 'package:flutter/material.dart';
import '../../domain/entities/category.dart' as entity;
import '../data/models/category.dart';

class SystemCategoryInitializer {
  static List<entity.Category> getSystemCategories() {
    final now = DateTime.now();
    
    return [
      // Income categories
      Category(
        userId: 0, // Will be set when initialized for user
        name: 'Salario',
        type: 'income',
        color: '#4CAF50',
        icon: 'salary',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Freelance',
        type: 'income',
        color: '#2196F3',
        icon: 'business',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Inversiones',
        type: 'income',
        color: '#FF9800',
        icon: 'business',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Regalos',
        type: 'income',
        color: '#E91E63',
        icon: 'gift',
        createdAt: now,
        isSystemCategory: true,
      ),
      
      // Expense categories
      Category(
        userId: 0,
        name: 'Comida',
        type: 'expense',
        color: '#F44336',
        icon: 'food',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Transporte',
        type: 'expense',
        color: '#FF5722',
        icon: 'transport',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Compras',
        type: 'expense',
        color: '#9C27B0',
        icon: 'shopping',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Entretenimiento',
        type: 'expense',
        color: '#3F51B5',
        icon: 'entertainment',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Salud',
        type: 'expense',
        color: '#009688',
        icon: 'health',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Vivienda',
        type: 'expense',
        color: '#795548',
        icon: 'home',
        createdAt: now,
        isSystemCategory: true,
      ),
      Category(
        userId: 0,
        name: 'Educación',
        type: 'expense',
        color: '#607D8B',
        icon: 'education',
        createdAt: now,
        isSystemCategory: true,
      ),
    ];
  }
}