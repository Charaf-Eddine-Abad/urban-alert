import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/features/feed/domain/entities/problem_type.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_providers.dart';
import 'package:urban_alert/features/my_alerts/presentation/widgets/location_picker_sheet.dart';
import 'package:urban_alert/shared/providers/categories_provider.dart';
import 'package:urban_alert/shared/widgets/app_button.dart';
import 'package:urban_alert/shared/widgets/app_text_field.dart';

/// Opens a full-screen create (or edit) alert page.
/// Returns `true` if the operation completed successfully.
Future<bool?> showCreateAlertPage(
  BuildContext context, {
  Alert? alertToEdit,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (ctx) => CreateAlertPage(alertToEdit: alertToEdit),
    ),
  );
}

class CreateAlertPage extends ConsumerStatefulWidget {
  const CreateAlertPage({super.key, this.alertToEdit});
  final Alert? alertToEdit;

  @override
  ConsumerState<CreateAlertPage> createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends ConsumerState<CreateAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtr = TextEditingController();
  final _descriptionCtr = TextEditingController();
  final _addressCtr = TextEditingController();

  ProblemType? _category;
  AlertPriority _priority = AlertPriority.medium;
  bool _isAnonymous = false;
  double _latitude = 33.5731; // Casablanca default
  double _longitude = -7.5898;
  bool _locationSet = false;

  final List<XFile> _newImages = [];
  bool _isLoading = false;
  String? _error;

  bool get _isEdit => widget.alertToEdit != null;

  @override
  void initState() {
    super.initState();
    final a = widget.alertToEdit;
    if (a != null) {
      _titleCtr.text = a.title;
      _descriptionCtr.text = a.description;
      _addressCtr.text = a.address ?? '';
      _priority = a.priority;
      _isAnonymous = a.isAnonymous;
      _latitude = a.latitude;
      _longitude = a.longitude;
      _locationSet = true;
    } else {
      // Auto-acquire GPS on create
      _acquireGps(silent: true);
    }
  }

  @override
  void dispose() {
    _titleCtr.dispose();
    _descriptionCtr.dispose();
    _addressCtr.dispose();
    super.dispose();
  }

  Future<void> _acquireGps({bool silent = false}) async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autorisation de localisation refusée dans les paramètres.'),
            ),
          );
        }
        return;
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        if (mounted) {
          setState(() {
            _latitude = pos.latitude;
            _longitude = pos.longitude;
            _locationSet = true;
          });
        }
      }
    } catch (_) {
      // Non-critical; user can set manually via map
    }
  }

  Future<void> _openMapPicker() async {
    final result = await showLocationPickerSheet(
      context,
      initialLat: _latitude,
      initialLng: _longitude,
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result.$1;
        _longitude = result.$2;
        _locationSet = true;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty && mounted) {
      setState(() => _newImages.addAll(picked));
    }
  }

  void _removeNewImage(int index) => setState(() => _newImages.removeAt(index));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null && !_isEdit) return; // validator handles this
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifier = ref.read(myAlertsNotifierProvider.notifier);
      if (_isEdit) {
        await notifier.updateAlert(
          widget.alertToEdit!.id,
          title: _titleCtr.text.trim(),
          description: _descriptionCtr.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          address: _addressCtr.text.trim().isEmpty ? null : _addressCtr.text.trim(),
          categoryId: _category?.id,
          priority: _priority.name.toUpperCase(),
          isAnonymous: _isAnonymous,
          newImages: _newImages,
        );
      } else {
        await notifier.createAlert(
          title: _titleCtr.text.trim(),
          description: _descriptionCtr.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          address: _addressCtr.text.trim().isEmpty ? null : _addressCtr.text.trim(),
          categoryId: _category!.id,
          priority: _priority.name.toUpperCase(),
          isAnonymous: _isAnonymous,
          images: _newImages,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on AppException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Modifier le signalement' : 'Nouveau signalement'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            // ── Error banner ──────────────────────────────────────────────
            if (_error != null) ...[
              _ErrorBanner(message: _error!),
              const SizedBox(height: 16),
            ],

            // ── Title ─────────────────────────────────────────────────────
            AppTextField(
              controller: _titleCtr,
              label: 'Titre',
              hint: 'Décrivez brièvement le problème',
              prefixIcon: const Icon(Icons.title_rounded),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().length < 3) {
                  return 'Minimum 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Description ───────────────────────────────────────────────
            AppTextField(
              controller: _descriptionCtr,
              label: 'Description',
              hint: 'Donnez plus de détails…',
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Minimum 10 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Category ──────────────────────────────────────────────────
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Impossible de charger les catégories',
                style: TextStyle(color: scheme.error),
              ),
              data: (categories) => DropdownButtonFormField<ProblemType>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (c) => setState(() => _category = c),
                validator: (v) => v == null ? 'Catégorie requise' : null,
              ),
            ),
            const SizedBox(height: 14),

            // ── Priority ──────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Priorité',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<AlertPriority>(
                  segments: const [
                    ButtonSegment(
                      value: AlertPriority.low,
                      label: Text('Faible'),
                      icon: Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.priorityLow,
                      ),
                    ),
                    ButtonSegment(
                      value: AlertPriority.medium,
                      label: Text('Moyenne'),
                      icon: Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.priorityMedium,
                      ),
                    ),
                    ButtonSegment(
                      value: AlertPriority.high,
                      label: Text('Haute'),
                      icon: Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.priorityHigh,
                      ),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Location ──────────────────────────────────────────────────
            _LocationSection(
              latitude: _latitude,
              longitude: _longitude,
              locationSet: _locationSet,
              addressController: _addressCtr,
              onGps: _acquireGps,
              onMap: _openMapPicker,
            ),
            const SizedBox(height: 14),

            // ── Anonymous toggle ──────────────────────────────────────────
            SwitchListTile(
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
              title: const Text('Signalement anonyme'),
              subtitle: const Text('Votre nom ne sera pas affiché'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 14),

            // ── Images ────────────────────────────────────────────────────
            _ImagePickerSection(
              existingImages: widget.alertToEdit?.images ?? [],
              newImages: _newImages,
              onAdd: _pickImages,
              onRemoveNew: _removeNewImage,
            ),
            const SizedBox(height: 28),

            // ── Submit ────────────────────────────────────────────────────
            AppButton(
              label: _isEdit ? 'Enregistrer' : 'Publier le signalement',
              loading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private section widgets ───────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.latitude,
    required this.longitude,
    required this.locationSet,
    required this.addressController,
    required this.onGps,
    required this.onMap,
  });

  final double latitude;
  final double longitude;
  final bool locationSet;
  final TextEditingController addressController;
  final VoidCallback onGps;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: addressController,
          label: 'Adresse (optionnel)',
          hint: 'Ex: Rue Mohammed V, Casablanca',
          prefixIcon: const Icon(Icons.location_on_outlined),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGps,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Ma position'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Carte'),
              ),
            ),
          ],
        ),
        if (locationSet) ...[
          const SizedBox(height: 6),
          Text(
            '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ],
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.existingImages,
    required this.newImages,
    required this.onAdd,
    required this.onRemoveNew,
  });

  final List<String> existingImages;
  final List<XFile> newImages;
  final VoidCallback onAdd;
  final void Function(int index) onRemoveNew;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAny = existingImages.isNotEmpty || newImages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Photos',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        if (hasAny) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Existing images (read-only on edit)
                ...existingImages.map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Newly picked images
                ...newImages.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            entry.value.path,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 90,
                              height: 90,
                              color: scheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_outlined),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => onRemoveNew(entry.key),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
