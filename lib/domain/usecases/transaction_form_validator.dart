class TransactionFormValidator {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'El monto es requerido';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Ingrese un monto válido';
    }
    
    if (amount <= 0) {
      return 'El monto debe ser mayor que cero';
    }
    
    return null;
  }
  
  static String? validateCategory(int? categoryId) {
    if (categoryId == null) {
      return 'Seleccione una categoría';
    }
    return null;
  }
  
  static String? validateAccount(int? accountId) {
    if (accountId == null) {
      return 'Seleccione una cuenta';
    }
    return null;
  }
  
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Seleccione una fecha';
    }
    return null;
  }
  
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es requerida';
    }
    
    if (value.trim().length < 3) {
      return 'La descripción debe tener al menos 3 caracteres';
    }
    
    return null;
  }
}