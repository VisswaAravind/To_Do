import 'package:flutter/material.dart';

class FilterSortBottomSheet extends StatelessWidget {
  final String selectedFilter;
  final String selectedSort;
  final void Function(String filter, String sort) onApply;

  const FilterSortBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    String tempFilter = selectedFilter;
    String tempSort = selectedSort;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter By', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            children: ['All', 'Completed', 'Pending']
                .map((filter) => ChoiceChip(
                      label: Text(filter),
                      selected: tempFilter == filter,
                      onSelected: (_) {
                        tempFilter = filter;
                        onApply(tempFilter, tempSort);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          SizedBox(height: 20),
          Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            children: ['Creation Date', 'Due Date', 'Priority']
                .map((sort) => ChoiceChip(
                      label: Text(sort),
                      selected: tempSort == sort,
                      onSelected: (_) {
                        tempSort = sort;
                        onApply(tempFilter, tempSort);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
