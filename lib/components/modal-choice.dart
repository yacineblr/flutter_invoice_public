import 'package:flutter/material.dart';

class ModalChoice extends StatefulWidget {
  const ModalChoice({ Key? key }) : super(key: key);

  @override
  _ModalChoiceState createState() => _ModalChoiceState();
}

class _ModalChoiceState extends State<ModalChoice> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Êtes-vous sûr ?', style: TextStyle(fontSize: 20)),
              SizedBox(height: 30),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Center(child: Text('Non')),
                    ),
                  ),
                  SizedBox(width: 80),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: Colors.red[500],
                      child: Center(child: Text('Oui', style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}