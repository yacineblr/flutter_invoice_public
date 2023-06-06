import 'package:flutter/material.dart';
import 'package:flutter_invoice/components/modal-choice.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/customer-service.dart';

class CustomerForm extends StatefulWidget {
  final Setting setting;
  final Customer customer;
  const CustomerForm({ Key? key, required this.setting, required this.customer }) : super(key: key);

  @override
  _CustomerFormState createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final CustomerService _customerService = locator<CustomerService>();
  late final Customer customer;
  late final TextEditingController _lastnameTextEditing;
  late final TextEditingController _firstnameTextEditing;
  late final TextEditingController _emailTextEditing;
  late final TextEditingController _phoneTextEditing;
  late final TextEditingController _addressTextEditing;
  late final TextEditingController _postalCodeTextEditing;
  late final TextEditingController _cityTextEditing;

  bool _disableBtnSave = false;

  @override
  void initState() {
    customer = widget.customer.copyWith();
    _lastnameTextEditing = TextEditingController(text: customer.lastname ?? "");
    _firstnameTextEditing = TextEditingController(text: customer.firstname ?? "");
    _emailTextEditing = TextEditingController(text: customer.email ?? "");
    _phoneTextEditing = TextEditingController(text: customer.phone ?? "");
    _addressTextEditing = TextEditingController(text: customer.address ?? "");
    _postalCodeTextEditing = TextEditingController(text: customer.zip ?? "");
    _cityTextEditing = TextEditingController(text: customer.city ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: UnderlineInputBorder(),
                          labelText: 'Nom'),
                      controller: _lastnameTextEditing,
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: UnderlineInputBorder(),
                          labelText: "Prénom"),
                      controller: _firstnameTextEditing,
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: UnderlineInputBorder(),
                    labelText: 'Email'),
                controller: _emailTextEditing,
              ),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: UnderlineInputBorder(),
                        labelText: 'Téléphone'),
                    controller: _phoneTextEditing,
                  ),
                )
              ]),
              TextFormField(
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: UnderlineInputBorder(),
                    labelText: 'Adresse'),
                controller: _addressTextEditing,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: UnderlineInputBorder(),
                          labelText: 'Code postal'),
                      controller: _postalCodeTextEditing,
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    flex: 6,
                    child: TextFormField(
                      decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: UnderlineInputBorder(),
                          labelText: "Ville"),
                      controller: _cityTextEditing,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (customer.id != null) GestureDetector(
                    onTap: () async {
                      final choice = await showDialog<bool>(context: context, builder: (_) {
                        return ModalChoice();
                      });
                      if (choice == true) {
                        _customerService.delete(customer);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      color: Colors.red[500],
                      child: Center(child: Text('Supprimer', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      print('HUHU');
                      if (_disableBtnSave == true) return;
                      try {
                        setState(() {
                          _disableBtnSave = true;
                        });
                        customer.settingId = widget.setting.id;
                        customer.lastname = _lastnameTextEditing.value.text;
                        customer.firstname = _firstnameTextEditing.value.text;
                        customer.email = _emailTextEditing.value.text;
                        customer.phone = _phoneTextEditing.value.text;
                        customer.address = _addressTextEditing.value.text;
                        customer.city = _cityTextEditing.value.text;
                        customer.zip = _postalCodeTextEditing.value.text;
                        if (customer.id != null) {
                          _customerService.update(customer);
                        } else {
                          _customerService.add(widget.setting.id!, customer);
                        }
                        Navigator.pop(context, customer);
                      } catch (e) {
                        print(e);
                        setState(() {
                          _disableBtnSave = false;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      color: _disableBtnSave ? Colors.grey[400] : Colors.blue[300],
                      child: Center(child: Text('Enregistrer')),
                    ),
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}