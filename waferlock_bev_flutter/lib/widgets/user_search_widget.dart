import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class UserSearchWidget extends StatelessWidget {
  const UserSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      '查詢使用者消費記錄',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '快速選擇',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  hint: const Text('選擇使用者'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'ALL',
                      child: Text('ALL (全部)'),
                    ),
                    ...dataProvider.allUsers
                        .map((user) => DropdownMenuItem<String>(
                              value: user.userName,
                              child: Text(user.userName),
                            ))
                        .toList(),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      if (value == 'ALL') {
                        dataProvider.setSearchQuery('');
                      } else {
                        dataProvider.setSearchQuery(value);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
