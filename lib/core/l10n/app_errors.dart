import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

/// Błędy widoczne dla użytkownika trzymane jako kody, nie jako tekst.
///
/// Warstwa usług (`BackupService`, `CsvService`, `DeviceServices`) nie ma
/// kontekstu ani języka, więc rzuca [L10nException], a interfejs wybiera
/// tłumaczenie w momencie pokazania komunikatu.
enum AppError {
  databaseOpen,
  automaticBackupFailed,
  operationFailed,
  pdfAndroidOnly,
  csvUnreadable,
  csvImportFailed,
  restoreFailed,

  /// Walidacja pliku wymiennego lub kopii. Treść komunikatu nie jest
  /// budowana w usłudze, tylko dobierana w interfejsie z tego kodu.
  backupTooLarge,
  archiveBroken,
  unpackedTooLarge,
  archiveVersion,
  archiveIncomplete,
  archiveCorrupted,
  archiveDataset,
  archiveColumns,
  archiveRelations,
  missingBackupFile,
  missingDraftFile,
  attachmentMissing,
  csvUnclosedQuote,
  csvNoHeader,
  csvKind,
  csvTitle,
  csvDate,
  csvAmount,
  csvMileage,
  csvMileageRequired,
  csvQuantity,
  csvFuel,
  csvBoolean;

  String label(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      AppError.databaseOpen => l.backupErrorDatabaseOpen,
      AppError.automaticBackupFailed => l.backupErrorAutomaticFailed,
      AppError.operationFailed => l.errorOperationFailed,
      AppError.pdfAndroidOnly => l.errorPdfAndroidOnly,
      AppError.csvUnreadable => l.errorCsvUnreadable,
      AppError.csvImportFailed => l.errorCsvImportFailed,
      AppError.restoreFailed => l.errorRestoreFailed,
      AppError.backupTooLarge => l.errorBackupTooLarge,
      AppError.archiveBroken => l.errorArchiveBroken,
      AppError.unpackedTooLarge => l.errorUnpackedTooLarge,
      AppError.archiveVersion => l.errorArchiveVersion,
      AppError.archiveIncomplete => l.errorArchiveIncomplete,
      AppError.archiveCorrupted => l.errorArchiveCorrupted,
      AppError.archiveDataset => l.errorArchiveDataset,
      AppError.archiveColumns => l.errorArchiveColumns,
      AppError.archiveRelations => l.errorArchiveRelations,
      AppError.missingBackupFile => l.errorMissingBackupFile,
      AppError.missingDraftFile => l.errorMissingDraftFile,
      AppError.attachmentMissing => l.errorAttachmentMissing,
      AppError.csvUnclosedQuote => l.errorCsvUnclosedQuote,
      AppError.csvNoHeader => l.errorCsvNoHeader,
      AppError.csvKind => l.csvErrorKind,
      AppError.csvTitle => l.csvErrorTitle,
      AppError.csvDate => l.csvErrorDate,
      AppError.csvAmount => l.csvErrorAmount,
      AppError.csvMileage => l.csvErrorMileage,
      AppError.csvMileageRequired => l.csvErrorMileageRequired,
      AppError.csvQuantity => l.csvErrorQuantity,
      AppError.csvFuel => l.csvErrorFuel,
      AppError.csvBoolean => l.csvErrorBoolean,
    };
  }
}

/// Wyjątek niosący kod błędu zamiast zdania w jednym języku.
class L10nException implements Exception {
  const L10nException(this.error, [this.details]);

  final AppError error;

  /// Szczegóły techniczne dla logów; nie są tłumaczone.
  final String? details;

  @override
  String toString() => details == null ? error.name : '${error.name}: $details';
}

/// Wyświetla kod błędu jako tekst w bieżącym języku.
String describeError(BuildContext context, Object error) => error
    is L10nException
        ? error.error.label(context)
        : error is FormatException
            ? error.message
            : AppError.operationFailed.label(context);
