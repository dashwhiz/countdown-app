import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_error_listeners.dart';
import '../app/app_logger.dart';
import '../app/app_progress_listeners.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../repositories/events_repo.dart';
import '../utils/operation_scope.dart';
import '../widgets/color_picker_grid.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/emoji_picker_grid.dart';

class CreateEditEventController extends GetxController {
  final EventsRepo _repo = EventsRepo();
  final CountdownEvent? eventToEdit;

  CreateEditEventController({this.eventToEdit});

  late ProgressListener _progressListener;
  late ErrorListener _errorListener;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final titleFocusNode = FocusNode();

  late DateTime selectedDate;
  late Color selectedColor;
  late String selectedEmoji;
  bool isPinned = false;

  bool get isEditMode => eventToEdit != null;
  String get screenTitle =>
      isEditMode ? AppStrings.editTitle : AppStrings.createTitle;

  @override
  void onInit() {
    super.onInit();
    final context = Get.context;
    if (context != null) {
      _progressListener = DefaultProgressListener(context);
      _errorListener = DialogErrorListener(context);
    } else {
      AppLogger.error('Context is null during CreateEditController initialization');
    }

    if (isEditMode) {
      titleController.text = eventToEdit!.title;
      selectedDate = eventToEdit!.targetDate;
      selectedColor = eventToEdit!.color;
      selectedEmoji = eventToEdit!.emoji;
      isPinned = eventToEdit!.isPinned;
    } else {
      selectedDate = DateTime.now().add(const Duration(days: 1));
      selectedColor = AppColors.defaultEventColors.first;
      selectedEmoji = AppConstants.defaultEmoji;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    titleFocusNode.dispose();
    super.onClose();
  }

  bool get isFormValid {
    return titleController.text.trim().isNotEmpty;
  }

  bool get hasChanges {
    if (!isEditMode) return isFormValid;

    return titleController.text != eventToEdit!.title ||
        selectedDate != eventToEdit!.targetDate ||
        selectedColor.toARGB32() != eventToEdit!.colorValue ||
        selectedEmoji != eventToEdit!.emoji ||
        isPinned != eventToEdit!.isPinned;
  }

  bool get canSave => isFormValid && (!isEditMode || hasChanges);

  void updateColor(Color color) {
    titleFocusNode.unfocus();
    selectedColor = color;
    update();
  }

  void updateEmoji(String emoji) {
    titleFocusNode.unfocus();
    selectedEmoji = emoji;
    update();
  }

  void updatePinned(bool value) {
    titleFocusNode.unfocus();
    isPinned = value;
    update();
  }

  void onTitleChanged(String value) {
    update();
  }

  Future<void> pickDateTime(BuildContext context) async {
    titleFocusNode.unfocus();

    final now = DateTime.now();
    final minimumDate = now.add(const Duration(hours: 24));

    final DateTime? picked = await DateTimePicker.show(
      context: context,
      initialDateTime: selectedDate,
      minimumDateTime: minimumDate,
      maximumDateTime: now.add(const Duration(days: 3650)),
    );

    if (picked != null) {
      selectedDate = picked;
      update();
    }
  }

  Future<void> saveEvent() async {
    if (!formKey.currentState!.validate()) return;
    if (!canSave) return;

    final timezone = tz.local.name;

    final event = CountdownEvent(
      id: isEditMode ? eventToEdit!.id : const Uuid().v4(),
      title: titleController.text.trim(),
      targetDate: selectedDate,
      timezone: timezone,
      colorValue: selectedColor.toARGB32(),
      emoji: selectedEmoji,
      isPinned: isPinned,
      createdAt: isEditMode ? eventToEdit!.createdAt : null,
    );

    final result = await scope(
      scope: () async => await _repo.saveEvent(event),
      progressListener: _progressListener,
      errorListener: _errorListener,
    );

    if (result.success && result.result == true) {
      Get.back(result: true);
    }
  }
}

class CreateEditEventScreen extends StatelessWidget {
  const CreateEditEventScreen({super.key, this.eventToEdit});

  final CountdownEvent? eventToEdit;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateEditEventController>(
      init: CreateEditEventController(eventToEdit: eventToEdit),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            title: Text(
              ctrl.screenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingLarge,
                horizontal: AppConstants.paddingMedium,
              ),
              child: Form(
                key: ctrl.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(context, AppStrings.eventTitleLabel),
                    const SizedBox(height: AppConstants.paddingSmall),
                    TextFormField(
                      controller: ctrl.titleController,
                      focusNode: ctrl.titleFocusNode,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: AppStrings.eventTitleHint,
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade600,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.eventTitleRequired;
                        }
                        return null;
                      },
                      onChanged: ctrl.onTitleChanged,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildSectionLabel(context, AppStrings.dateTimeLabel),
                    const SizedBox(height: AppConstants.paddingSmall),
                    GestureDetector(
                      onTap: () => ctrl.pickDateTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade600,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy • HH:mm',
                              ).format(ctrl.selectedDate),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildSectionLabel(context, AppStrings.colorLabel),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ColorPickerGrid(
                      selectedColor: ctrl.selectedColor,
                      onColorSelected: ctrl.updateColor,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    _buildSectionLabel(context, AppStrings.emojiLabel),
                    const SizedBox(height: AppConstants.paddingSmall),
                    EmojiPickerGrid(
                      selectedEmoji: ctrl.selectedEmoji,
                      onEmojiSelected: ctrl.updateEmoji,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.pinEvent,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        CupertinoSwitch(
                          value: ctrl.isPinned,
                          onChanged: ctrl.updatePinned,
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingSmall,
                        vertical: AppConstants.paddingLarge,
                      ),
                      child: Container(
                        height: 1,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ctrl.canSave ? () => ctrl.saveEvent() : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppStrings.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
