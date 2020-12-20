import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ExtractedContainer extends StatelessWidget {
  ExtractedContainer(
      {this.colour, this.onclick, this.icon, this.text, this.hero});
  final Color colour;
  final Function onclick;
  final IconData icon;
  final String text;
  final String hero;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onclick,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          shadowColor: Colors.black,
          color: Colors.white.withOpacity(1),
          elevation: 5,
          child: Container(
//            padding: EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 43,
                  height: 43,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Icon(
                    icon,
                    color: colour,
                    size: 35.0,
                  ),
                ),
                SizedBox(
                  height: 7.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                    ),
                    child: AutoSizeText(
                      '$text',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          fontFamily: 'Sanspro'),
                    ),
                  ),
                ),
              ],
            ),
            margin:
                EdgeInsets.only(right: 3.0, left: 3.0, top: 4.0, bottom: 4.0),
//            decoration: BoxDecoration(
////            color: Colors.white,
////          gradient: LinearGradient(colors: [Colors.black, Colors.black26]),
//              border: Border.all(color: Colors.grey),
//              borderRadius: BorderRadius.only(
//                topLeft: Radius.circular(20.0),
//                topRight: Radius.circular(20.0),
//                bottomRight: Radius.circular(20.0),
//                bottomLeft: Radius.circular(20.0),
//              ),
//            ),
          ),
        ),
      ),
    );
  }
}
