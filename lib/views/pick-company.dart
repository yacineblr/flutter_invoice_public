
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';
import 'package:flutter_invoice/views/customer/customer-detail.dart';
import 'package:flutter_invoice/views/customer/customer-list.dart';
import 'package:flutter_invoice/views/settings/setting-form.dart';

class PickCompany extends StatefulWidget {
  PickCompany({Key? key}) : super(key: key);

  @override
  State<PickCompany> createState() => _PickCompanyState();
}

class _PickCompanyState extends State<PickCompany> {
  final settingService = locator<SettingsService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: StreamBuilder(
        stream: settingService.settingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
          final list = [...snapshot.data!, Setting()];
          return ListView.separated(
            itemBuilder: (_, index) {
              final setting = list[index];
              if (setting.id == null) return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => SettingForm(
                    setting: setting,
                  )));
                },
                child: Text('Ajouter une entreprise', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
              );
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(setting.companyName ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          child: Text('Clients'),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => CustomerList(
                              setting: setting,
                            )));
                          },
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Text('Modifier infos'),
                          onPressed: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (_) => SettingForm(
                              setting: setting,
                            )));
                          },
                        )
                      ]
                    )
                  ],
                ),
              );
            },
            separatorBuilder: (_, index) => Divider(),
            itemCount: list.length,
          );
        }
      )
    );
  }
}