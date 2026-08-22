import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ingestion/parsed_transaction.dart';
import '../../models/transaction.dart';
import '../../services/ingestion/ingestion_service.dart';
import '../../services/ingestion/parsers/csv_column_mapper.dart';
import '../../services/ingestion/parsers/csv_parser.dart';

class CsvImportState {
  final String? rawCsvContent;
  final String? fileName;
  final List<String> headers;
  final List<List<String>> sampleRows;
  final CsvColumnMapping columnMapping;
  final ImportReviewSession? session;
  final bool isLoading;
  final String? progressStep;
  final List<String> lastCommittedIds;
  final String? errorMessage;

  const CsvImportState({
    this.rawCsvContent,
    this.fileName,
    this.headers = const [],
    this.sampleRows = const [],
    this.columnMapping = const CsvColumnMapping(),
    this.session,
    this.isLoading = false,
    this.progressStep,
    this.lastCommittedIds = const [],
    this.errorMessage,
  });

  bool get hasFile => rawCsvContent != null && rawCsvContent!.isNotEmpty;
  bool get hasSession => session != null && session!.items.isNotEmpty;

  CsvImportState copyWith({
    String? rawCsvContent,
    String? fileName,
    List<String>? headers,
    List<List<String>>? sampleRows,
    CsvColumnMapping? columnMapping,
    ImportReviewSession? session,
    bool? isLoading,
    String? progressStep,
    List<String>? lastCommittedIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CsvImportState(
      rawCsvContent: rawCsvContent ?? this.rawCsvContent,
      fileName: fileName ?? this.fileName,
      headers: headers ?? this.headers,
      sampleRows: sampleRows ?? this.sampleRows,
      columnMapping: columnMapping ?? this.columnMapping,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      progressStep: progressStep ?? this.progressStep,
      lastCommittedIds: lastCommittedIds ?? this.lastCommittedIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CsvImportController extends StateNotifier<CsvImportState> {
  final Ref _ref;

  CsvImportController(this._ref) : super(const CsvImportState());

  /// Load and parse CSV text
  Future<void> loadCsvContent(
    String content, {
    String? fileName,
    String defaultAccountId = 'acc_primary_cash',
  }) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Selected file is empty.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      progressStep: 'Reading file & detecting columns...',
      rawCsvContent: content,
      fileName: fileName ?? 'statement.csv',
      clearError: true,
    );

    try {
      final table = CsvParser.parseCsvToTable(content);
      if (table.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No readable CSV data found.',
        );
        return;
      }

      final headerIdx = CsvParser.findHeaderRowIndex(table);
      final headers = table[headerIdx];
      final sampleRows = table.sublist(headerIdx + 1).take(5).toList();
      final mapping = CsvColumnMapper.autoDetect(
        headers,
        sampleRows: sampleRows,
      );

      state = state.copyWith(
        progressStep: 'Checking duplicates on-device...',
        headers: headers,
        sampleRows: sampleRows,
        columnMapping: mapping,
      );

      final ingestionService = _ref.read(ingestionServiceProvider);
      final session = await ingestionService.processCsv(
        csvContent: content,
        sourceFileName: fileName,
        customMapping: mapping,
        defaultAccountId: defaultAccountId,
      );

      state = state.copyWith(
        session: session,
        isLoading: false,
        progressStep: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        errorMessage: 'Failed to process CSV: $e',
      );
    }
  }

  /// Re-parse with updated column mappings
  Future<void> updateMapping(
    CsvColumnMapping newMapping, {
    String defaultAccountId = 'acc_primary_cash',
  }) async {
    if (state.rawCsvContent == null) return;

    state = state.copyWith(
      isLoading: true,
      progressStep: 'Re-parsing with new mapping...',
      columnMapping: newMapping,
      clearError: true,
    );

    try {
      final ingestionService = _ref.read(ingestionServiceProvider);
      final session = await ingestionService.processCsv(
        csvContent: state.rawCsvContent!,
        sourceFileName: state.fileName,
        customMapping: newMapping,
        defaultAccountId: defaultAccountId,
      );

      state = state.copyWith(
        session: session,
        isLoading: false,
        progressStep: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        errorMessage: 'Failed to update mapping: $e',
      );
    }
  }

  /// Toggle row inclusion
  void toggleRowInclusion(String tempId, bool isIncluded) {
    if (state.session == null) return;

    final updatedItems =
        state.session!.items.map((item) {
          if (item.tempId == tempId) {
            return item.copyWith(isIncluded: isIncluded);
          }
          return item;
        }).toList();

    state = state.copyWith(
      session: state.session!.copyWith(items: updatedItems),
    );
  }

  /// Edit row fields
  void updateRowField(
    String tempId, {
    double? amount,
    String? rawMerchant,
    String? normalizedMerchant,
    TransactionType? type,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? accountId,
    DateTime? date,
    DuplicateResolution? duplicateResolution,
  }) {
    if (state.session == null) return;

    final updatedItems =
        state.session!.items.map((item) {
          if (item.tempId == tempId) {
            return item.copyWith(
              amount: amount ?? item.amount,
              rawMerchant: rawMerchant ?? item.rawMerchant,
              normalizedMerchant: normalizedMerchant ?? item.normalizedMerchant,
              type: type ?? item.type,
              categoryId: categoryId ?? item.categoryId,
              categoryName: categoryName ?? item.categoryName,
              categoryIcon: categoryIcon ?? item.categoryIcon,
              categoryColor: categoryColor ?? item.categoryColor,
              accountId: accountId ?? item.accountId,
              date: date ?? item.date,
              duplicateResolution:
                  duplicateResolution ?? item.duplicateResolution,
            );
          }
          return item;
        }).toList();

    state = state.copyWith(
      session: state.session!.copyWith(items: updatedItems),
    );
  }

  /// Commit the import
  Future<List<String>> commitImport() async {
    if (state.session == null) return [];

    state = state.copyWith(
      isLoading: true,
      progressStep: 'Saving transactions locally...',
      clearError: true,
    );

    try {
      final ingestionService = _ref.read(ingestionServiceProvider);
      final committedIds = await ingestionService.commitSession(state.session!);

      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        lastCommittedIds: committedIds,
      );

      return committedIds;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        errorMessage: 'Failed to commit import: $e',
      );
      rethrow;
    }
  }

  /// Undo the last import
  Future<void> undoLastImport() async {
    if (state.lastCommittedIds.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      progressStep: 'Reverting import...',
      clearError: true,
    );

    try {
      final ingestionService = _ref.read(ingestionServiceProvider);
      await ingestionService.undoImport(state.lastCommittedIds);

      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        lastCommittedIds: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        progressStep: null,
        errorMessage: 'Failed to undo import: $e',
      );
    }
  }

  /// Reset state
  void reset() {
    state = const CsvImportState();
  }
}

final csvImportControllerProvider =
    StateNotifierProvider<CsvImportController, CsvImportState>((ref) {
      return CsvImportController(ref);
    });
