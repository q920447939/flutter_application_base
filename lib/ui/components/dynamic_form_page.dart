/// 动态表单页面组件
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/router/models/route_config.dart';
import '../../core/network/network_service.dart';

/// 动态表单页面
class DynamicFormPage extends StatefulWidget {
  final String title;
  final FormConfig form;
  final Map<String, dynamic>? arguments;
  final Map<String, dynamic>? customStyles;

  const DynamicFormPage({
    super.key,
    required this.title,
    required this.form,
    this.arguments,
    this.customStyles,
  });

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeForm() {
    for (final field in widget.form.fields) {
      final controller = TextEditingController();
      _controllers[field.name] = controller;

      // 设置默认值
      if (field.defaultValue != null) {
        _formData[field.name] = field.defaultValue;
        controller.text = field.defaultValue.toString();
      }

      // 从参数中获取初始值
      if (widget.arguments?.containsKey(field.name) == true) {
        final value = widget.arguments![field.name];
        _formData[field.name] = value;
        controller.text = value.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: null,
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('提交'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...widget.form.fields.map(_buildFormField),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  child:
                      _isSubmitting
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('提交中...'),
                            ],
                          )
                          : const Text('提交'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(FormFieldConfig field) {
    switch (field.type.toLowerCase()) {
      case 'text':
      case 'string':
        return _buildTextField(field);
      case 'email':
        return _buildEmailField(field);
      case 'password':
        return _buildPasswordField(field);
      case 'number':
      case 'int':
      case 'double':
        return _buildNumberField(field);
      case 'textarea':
        return _buildTextAreaField(field);
      case 'select':
      case 'dropdown':
        return _buildSelectField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'date':
        return _buildDateField(field);
      case 'time':
        return _buildTimeField(field);
      case 'datetime':
        return _buildDateTimeField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.properties?['placeholder']?.toString(),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => _validateField(field, value),
        onChanged: (value) => _formData[field.name] = value,
      ),
    );
  }

  Widget _buildEmailField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.properties?['placeholder']?.toString(),
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.email),
        ),
        validator: (value) {
          final baseValidation = _validateField(field, value);
          if (baseValidation != null) return baseValidation;

          if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
            return '请输入有效的邮箱地址';
          }
          return null;
        },
        onChanged: (value) => _formData[field.name] = value,
      ),
    );
  }

  Widget _buildPasswordField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        obscureText: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.properties?['placeholder']?.toString(),
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.lock),
        ),
        validator: (value) => _validateField(field, value),
        onChanged: (value) => _formData[field.name] = value,
      ),
    );
  }

  Widget _buildNumberField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.properties?['placeholder']?.toString(),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final baseValidation = _validateField(field, value);
          if (baseValidation != null) return baseValidation;

          if (value != null && value.isNotEmpty && !GetUtils.isNum(value)) {
            return '请输入有效的数字';
          }
          return null;
        },
        onChanged: (value) {
          if (field.type.toLowerCase() == 'int') {
            _formData[field.name] = int.tryParse(value);
          } else {
            _formData[field.name] = double.tryParse(value);
          }
        },
      ),
    );
  }

  Widget _buildTextAreaField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        maxLines: field.properties?['maxLines'] as int? ?? 4,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.properties?['placeholder']?.toString(),
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        validator: (value) => _validateField(field, value),
        onChanged: (value) => _formData[field.name] = value,
      ),
    );
  }

  Widget _buildSelectField(FormFieldConfig field) {
    final options = field.properties?['options'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _formData[field.name]?.toString(),
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        items:
            options.map<DropdownMenuItem<String>>((option) {
              if (option is Map<String, dynamic>) {
                return DropdownMenuItem<String>(
                  value: option['value']?.toString(),
                  child: Text(option['label']?.toString() ?? ''),
                );
              } else {
                return DropdownMenuItem<String>(
                  value: option.toString(),
                  child: Text(option.toString()),
                );
              }
            }).toList(),
        validator: (value) => _validateField(field, value),
        onChanged: (value) => setState(() => _formData[field.name] = value),
      ),
    );
  }

  Widget _buildRadioField(FormFieldConfig field) {
    final options = field.properties?['options'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            String value, label;
            if (option is Map<String, dynamic>) {
              value = option['value']?.toString() ?? '';
              label = option['label']?.toString() ?? '';
            } else {
              value = label = option.toString();
            }

            return RadioListTile<String>(
              title: Text(label),
              value: value,
              groupValue: _formData[field.name]?.toString(),
              onChanged: (selectedValue) {
                setState(() => _formData[field.name] = selectedValue);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckboxField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CheckboxListTile(
        title: Text(field.label),
        value: _formData[field.name] as bool? ?? false,
        onChanged: (value) => setState(() => _formData[field.name] = value),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildDateField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) => _validateField(field, value),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            final dateString = date.toIso8601String().split('T')[0];
            _controllers[field.name]!.text = dateString;
            _formData[field.name] = dateString;
          }
        },
      ),
    );
  }

  Widget _buildTimeField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        validator: (value) => _validateField(field, value),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            final timeString =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            _controllers[field.name]!.text = timeString;
            _formData[field.name] = timeString;
          }
        },
      ),
    );
  }

  Widget _buildDateTimeField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.event),
        ),
        validator: (value) => _validateField(field, value),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              final dateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              final dateTimeString = dateTime.toIso8601String();
              _controllers[field.name]!.text = dateTimeString;
              _formData[field.name] = dateTimeString;
            }
          }
        },
      ),
    );
  }

  String? _validateField(FormFieldConfig field, String? value) {
    if (field.required && (value == null || value.isEmpty)) {
      return '${field.label}不能为空';
    }

    // 可以根据field.properties中的验证规则进行更多验证
    final minLength = field.properties?['minLength'] as int?;
    if (minLength != null && value != null && value.length < minLength) {
      return '${field.label}至少需要$minLength个字符';
    }

    final maxLength = field.properties?['maxLength'] as int?;
    if (maxLength != null && value != null && value.length > maxLength) {
      return '${field.label}不能超过$maxLength个字符';
    }

    return null;
  }
}
