import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class UserSearchWidget extends StatelessWidget {
  const UserSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {



    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFE0F2FE), // Light blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B5CF6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '✨ 查詢使用者消費記錄',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B46C1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: '快速選擇',
                  labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                  ),
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
        );
      },
    );
  }
}
