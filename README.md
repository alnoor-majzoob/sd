# Training Scheduler CLI

Dart CLI application that models the Excel workbook sheets except `Instructions`, parses the Excel file, and performs professional workbook validation.

## Modeled sheets
- `Courses`
- `Trainers`
- `Venues`
- `Calendar`
- `Generated Schedule`
- `Lookups`
- `assigned course`

## Features
- Strongly typed Dart models for workbook sheets
- XLSX parser using the `excel` package
- Cross-sheet and field-level validation
- CLI summary and validation report output

## Project structure
- `lib/src/models`: workbook entity models
- `lib/src/parser`: Excel parser
- `lib/src/validation`: validation engine and issue model
- `bin/`: CLI entry point

## Install
```bash
dart pub get
```

## Run
```bash
dart run bin/training_scheduler_cli.dart ../training_input_updated.xlsx
```

## Validation examples
- required fields
- duplicate IDs
- invalid date windows
- missing references across sheets
- trainer specialty mismatch in `assigned course`
- unsupported lookup values
- invalid schedule date range

## Notes
This environment did not have Dart SDK installed, so the project was generated but not executed here.
# pl
# sd
