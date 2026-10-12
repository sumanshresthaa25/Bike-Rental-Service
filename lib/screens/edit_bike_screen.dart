import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../model/bike_model.dart';
import '../provider/bike_provider.dart';
import '../utils/form_validators.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/bike_image.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/vehicle_category_selector.dart';

class EditBikeScreen extends StatefulWidget {
  final BikeModel bike;

  const EditBikeScreen({super.key, required this.bike});

  @override
  State<EditBikeScreen> createState() => _EditBikeScreenState();
}

class _EditBikeScreenState extends State<EditBikeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _modelController;
  late final TextEditingController _priceController;
  late final TextEditingController _bookingController;
  late final TextEditingController _imageController;

  late String _category;
  bool _isSaving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bike.name);
    _modelController = TextEditingController(text: widget.bike.model);
    _priceController = TextEditingController(
      text: widget.bike.pricePerDay.toStringAsFixed(0),
    );
    _bookingController = TextEditingController(
      text: widget.bike.bookingCharge.toStringAsFixed(0),
    );
    _imageController = TextEditingController(text: widget.bike.image);
    _category = widget.bike.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _bookingController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _pickGalleryImage() async {
    setState(() => _isPickingImage = true);

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 78,
        maxWidth: 1200,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final mimeType = image.mimeType ?? "image/jpeg";
      _imageController.text = "data:$mimeType;base64,${base64Encode(bytes)}";
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, "Couldn't pick that image.");
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedBike = widget.bike.copyWith(
      name: _nameController.text.trim(),
      model: _modelController.text.trim(),
      category: _category,
      pricePerDay: double.parse(_priceController.text.trim()),
      bookingCharge: double.parse(_bookingController.text.trim()),
      image: _imageController.text.trim(),
    );

    final success = await context.read<BikeProvider>().updateBike(updatedBike);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, updatedBike);
    } else {
      showAppSnackBar(context, "Failed to update bike. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Bike")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BikeImage(image: _imageController.text.trim()),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isPickingImage ? null : _pickGalleryImage,
              icon: _isPickingImage
                  ? const AppLoading()
                  : const Icon(Icons.photo_library_outlined),
              label: const Text("Change Image"),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: _nameController,
              label: "Name",
              validator: FormValidators.required,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _modelController,
              label: "Model",
              validator: FormValidators.required,
            ),
            const SizedBox(height: 12),
            VehicleCategorySelector(
              selected: _category,
              onChanged: (category) => setState(() => _category = category),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _priceController,
              label: "Price per day (Rs.)",
              keyboardType: TextInputType.number,
              validator: FormValidators.requiredNumber,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _bookingController,
              label: "Booking charge (Rs.)",
              keyboardType: TextInputType.number,
              validator: FormValidators.requiredNumber,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _imageController,
              label: "Image URL or gallery image data",
              minLines: 1,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              validator: FormValidators.required,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const AppLoading()
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
