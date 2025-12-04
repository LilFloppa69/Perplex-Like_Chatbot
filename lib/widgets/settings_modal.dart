import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perplexity_clone/theme/colors.dart';

class SettingsModal extends StatefulWidget {
  @override
  _SettingsModalState createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  TextEditingController instructionCtrl = TextEditingController();
  String behavior = "Default";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    instructionCtrl.text = prefs.getString("custom_instruction") ?? "";
    behavior = prefs.getString("behavior_mode") ?? "Default";
    setState(() {});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("custom_instruction", instructionCtrl.text);
    await prefs.setString("behavior_mode", behavior);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Settings saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sideNav,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.sideNav,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.searchBarBorder, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              "AI Personality Settings",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // CUSTOM INSTRUCTIONS
            Text(
              "Custom Instructions",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppColors.searchBar,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.searchBarBorder),
              ),
              child: TextField(
                controller: instructionCtrl,
                maxLines: 4,
                style: TextStyle(color: AppColors.whiteColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: "Example: Always answer using humor...",
                  hintStyle: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BEHAVIOR DROPDOWN
            Text(
              "Behavior Mode",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.searchBar,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.searchBarBorder),
              ),
              child: DropdownButton<String>(
                value: behavior,
                dropdownColor: AppColors.searchBar,
                isExpanded: true,
                underline: SizedBox(),
                style: TextStyle(color: AppColors.whiteColor),
                items: ["Default", "Friendly", "Professional", "Humorous"]
                    .map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child:
                        Text(e, style: TextStyle(color: AppColors.whiteColor)),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => behavior = v!);
                },
              ),
            ),

            const SizedBox(height: 24),

            // SAVE BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.submitButton,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: AppColors.background,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
