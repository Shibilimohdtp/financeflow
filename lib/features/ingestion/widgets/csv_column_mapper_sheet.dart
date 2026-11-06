import 'package:flutter/material.dart';

import '../../../services/ingestion/parsers/csv_column_mapper.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_select.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../theme/ff.dart';

/// Pattern E sheet for configuring CSV column mappings into transaction fields.
class CsvColumnMapperSheet extends StatefulWidget {
  const CsvColumnMapperSheet({
    super.key,
    required this.headers,
    required this.initialMapping,
    required this.onApply,
  });

  final List<String> headers;
  final CsvColumnMapping initialMapping;
  final ValueChanged<CsvColumnMapping> onApply;

  @override
  State<CsvColumnMapperSheet> createState() => _CsvColumnMapperSheetState();
}

class _CsvColumnMapperSheetState extends State<CsvColumnMapperSheet> {
  late CsvColumnMapping _mapping;

  @override
  void initState() {
    super.initState();
    _mapping = widget.initialMapping;
  }

  List<DropdownMenuItem<int?>> _buildDropdownItems() {
    return [
      const DropdownMenuItem<int?>(value: null, child: Text('None / Skip')),
      ...widget.headers.asMap().entries.map((e) {
        final label =
            e.value.length > 24 ? '${e.value.substring(0, 22)}...' : e.value;
        return DropdownMenuItem<int?>(value: e.key, child: Text(label));
      }),
    ];
  }

  int? _sanitize(int? index) {
    if (index != null && index >= 0 && index < widget.headers.length) {
      return index;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildDropdownItems();

    return FfSheet(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FfSheetHeader(
          title: 'Map CSV Columns',
          subtitle:
              'Select which column in your CSV matches each transaction field.',
        ),
        const FfDivider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.pageMargin,
              vertical: FfSpace.md,
            ),
            children: [
              FfSelect<int?>(
                label: 'Date Column *',
                value: _sanitize(_mapping.dateIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      dateIndex: idx,
                      clearDate: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Merchant / Narration *',
                value: _sanitize(_mapping.merchantIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      merchantIndex: idx,
                      clearMerchant: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Debit Column',
                value: _sanitize(_mapping.debitIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      debitIndex: idx,
                      clearDebit: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Credit Column',
                value: _sanitize(_mapping.creditIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      creditIndex: idx,
                      clearCredit: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Amount (Single Column)',
                value: _sanitize(_mapping.amountIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      amountIndex: idx,
                      clearAmount: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Reference / UTR',
                value: _sanitize(_mapping.referenceIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      referenceIndex: idx,
                      clearReference: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.md),
              FfSelect<int?>(
                label: 'Category',
                value: _sanitize(_mapping.categoryIndex),
                items: items,
                onChanged: (idx) {
                  setState(() {
                    _mapping = _mapping.copyWith(
                      categoryIndex: idx,
                      clearCategory: idx == null,
                    );
                  });
                },
              ),
              const SizedBox(height: FfSpace.xl),
              FfButton(
                label: 'Apply Column Mapping',
                variant: FfButtonVariant.primary,
                onPressed: () {
                  widget.onApply(_mapping);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: FfSpace.lg),
            ],
          ),
        ),
      ],
    );
  }
}
