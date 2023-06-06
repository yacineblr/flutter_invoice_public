import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';
import 'package:image_picker/image_picker.dart';


class _FormField {
  final String title;
  final TextEditingController controller;
  final Function(String value) onChange; 
  _FormField({required this.title, required this.controller, required this.onChange});
}

class SettingForm extends StatefulWidget {
  final Setting setting;
  const SettingForm({super.key, required this.setting});

  @override
  State<SettingForm> createState() => _SettingFormState();
}

class _SettingFormState extends State<SettingForm> {
  final _settingService = locator<SettingsService>();
  final ImagePicker _picker = ImagePicker();
  late final Setting _setting;
  late final List<_FormField> _list;
  XFile? _imageFileList;
  dynamic _pickImageError;

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : value;
  }

  @override
  void initState() {
    _setting = widget.setting.copyWith();
    // companyName
    // email
    // id
    // logo
    // phone
    // address
    // city
    // zip
    // rcs
    // siren
    // siret
    // userId
    // website
    _list = [
      _FormField(
        title: 'Nom',
        controller: TextEditingController(text: _setting.companyName),
        onChange: (value) => _setting.companyName = value
      ),
      _FormField(
        title: 'Email',
        controller: TextEditingController(text: _setting.email),
        onChange: (value) => _setting.email = value
      ),
      _FormField(
        title: 'Téléphone',
        controller: TextEditingController(text: _setting.phone),
        onChange: (value) => _setting.phone = value
      ),
      _FormField(
        title: 'Adresse',
        controller: TextEditingController(text: _setting.address),
        onChange: (value) => _setting.address = value
      ),
      _FormField(
        title: 'Ville',
        controller: TextEditingController(text: _setting.city),
        onChange: (value) => _setting.city = value
      ),
      _FormField(
        title: 'Code postal',
        controller: TextEditingController(text: _setting.zip),
        onChange: (value) => _setting.zip = value
      ),
      _FormField(
        title: 'RCS',
        controller: TextEditingController(text: _setting.rcs),
        onChange: (value) => _setting.rcs = value
      ),
      _FormField(
        title: 'SIREN',
        controller: TextEditingController(text: _setting.siren),
        onChange: (value) => _setting.siren = value
      ),
      _FormField(
        title: 'SIRET',
        controller: TextEditingController(text: _setting.siret),
        onChange: (value) => _setting.siret = value
      ),
      _FormField(
        title: 'Site web',
        controller: TextEditingController(text: _setting.website),
        onChange: (value) => _setting.website = value
      ),
    ];
    super.initState();
  }

  _onImageButtonPressed() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 300,
        imageQuality: 100,
      );
      setState(() {
        _setImageFileListFromFile(pickedFile);
        _pickImageError = null;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  displayLogoBase64(String base64) {
    return base64 == '' ? null : Image(
      image: MemoryImage(base64Decode(base64.split(',').last)),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_setting.id == null ? 'Nouvelle société' : 'Modifier société'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        )
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _onImageButtonPressed,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFileList == null 
                    ? _setting.logo != null && _setting.logo!.isNotEmpty 
                      ? displayLogoBase64(_setting.logo!) 
                      : Center(child: Text('Ajouter un logo')) 
                    : Image.network(_imageFileList!.path, fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_imageFileList != null || _setting.logo != null) TextButton(
                onPressed: _onImageButtonPressed,
                child: Text('Modifier le logo', style: TextStyle(color: Colors.red, fontSize: 10)),
              ),
              if (_pickImageError != null) Text(
                'Pick image error: $_pickImageError',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: _list.length,
                itemBuilder: (context, index) {
                  final item = _list[index];
                  return TextFormField(
                    controller: item.controller,
                    onChanged: item.onChange,
                    decoration: InputDecoration(
                      labelText: item.title,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  if (_setting.id != null) Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: () async {
                        await _settingService.delete(_setting.id!);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Société supprimée'),
                          duration: Duration(seconds: 2),
                        ));
                        Navigator.of(context).pop(null);
                      },
                      child: Text('Supprimer'),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_imageFileList != null) {
                          _setting.logo = base64Encode(await _imageFileList!.readAsBytes());
                        }
                        if (_setting.id != null) {
                          await _settingService.update(_setting);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Société modifiée'),
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          await _settingService.add(_setting);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Société ajoutée'),
                            duration: Duration(seconds: 2),
                          ));
                        }
                        Navigator.of(context).pop(_setting);
                      },
                      child: Text('Enregistrer'),
                    ),
                  ),
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}