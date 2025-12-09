
import '../../../models/child_report_model.dart';

class ChildReportState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<ChildReportModel> reports; // Added reports list

  ChildReportState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.reports = const [], // Default empty
  });

  ChildReportState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<ChildReportModel>? reports,
  }) {
    return ChildReportState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      reports: reports ?? this.reports,
    );
  }
}

