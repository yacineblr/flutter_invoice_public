import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/customer-service.dart';
import 'package:flutter_invoice/views/customer/customer-detail.dart';
import 'package:flutter_invoice/views/customer/customer-form.dart';
import 'package:intl/intl.dart';

class CustomerList extends StatefulWidget {
  final Setting setting;
  const CustomerList({ Key? key, required this.setting }) : super(key: key);

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  CustomerService _customerService = locator<CustomerService>();

  @override
  void initState() {
    _customerService.getCustomers(widget.setting.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("Liste clients"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            _customerService.customersStream.add([]);
            Navigator.of(context).pop();
          },
        )
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final customerForm = await showDialog<Customer>(
            context: context,
            builder: (_) => CustomerForm(
              setting: widget.setting,
              customer: new Customer(),
            )
          );
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.blue[400]
          ),
          child: Center(child: Icon(Icons.add, color: Colors.white))
        ),
      ),
      body: Container(
        child: StreamBuilder<List<Customer>>(
          stream: _customerService.customersStream,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
            if (snapshot.hasData == true && snapshot.data!.length == 0) return Center(child: Text("Aucun client"));
            return ListView.separated(
              itemBuilder: (_, index) {
                final customer = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => CustomerDetail(
                      customer: customer,
                      setting: widget.setting,
                    )));
                  },
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: Text('${customer.lastname?.toUpperCase()} ${customer.firstname}')),
                        // Container(
                        //   width: 70,
                        //   child: Text('D: ${customer.quotations.length} / F: ${customer.invoices.length}', style: TextStyle(fontSize: 11))
                        // ),
                        Text(DateFormat('dd/MM/yyyy').format(customer.dateCreated))
                      ],
                    )
                  ),
                );
              },
              separatorBuilder: (_, i) => Container(
                height: 1,
                color: Colors.black.withOpacity(0.1)
              ),
              itemCount: snapshot.data!.length
            );
          }
        )
      ),
    );
  }
}