import 'toast.dart';

void showGlassSnackbar({required String message, required bool success}) {
  showToast(message, success: success);
}
