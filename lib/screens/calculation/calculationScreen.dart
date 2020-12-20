import 'package:dailyneedsserver/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/screens/orders/calculations/calculations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class CalculationScreen extends StatefulWidget {
  @override
  _CalculationScreenState createState() => _CalculationScreenState();
}

DateTime _lowerDate, _upperDate;
bool _showSpinner = false;

class _CalculationScreenState extends State<CalculationScreen> {
  List<DocumentSnapshot> dateRangeFirestoreData = [];
  @override
  void initState() {
    _lowerDate = DateTime.now();
    _upperDate = DateTime.now();
    _showSpinner = false;
    dateRangeFirestoreData = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Calculations'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Lower : '),
                      Material(
                        elevation: 4,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () => _selectDate(context, _lowerDate, true),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "${_lowerDate.toLocal()}".split(' ')[0],
                              textAlign: TextAlign.center,
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text('upper : '),
                      Material(
                        elevation: 4,
                        color: Colors.white,
                        child: GestureDetector(
                          onTap: () => _selectDate(context, _upperDate, false),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "${_upperDate.toLocal()}".split(' ')[0],
                              textAlign: TextAlign.center,
                            ),
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  FlatButton(
                    child: Text(
                      ' View Bill ',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.purple,
                    onPressed: () async {
                      dateRangeFirestoreData = [];
                      String uid = Provider.of<IsInList>(context, listen: false)
                          .userDetails['uid'];

                      _showSpinner = true;
                      setState(() {});
                      _upperDate = new DateTime(_upperDate.year,
                          _upperDate.month, _upperDate.day, 6, 30);
                      _lowerDate = new DateTime(_lowerDate.year,
                          _lowerDate.month, _lowerDate.day, 6, 30);
                      DateTime incrementDate = _lowerDate;
                      List<DateTime> dateRange = [];
                      while (incrementDate.millisecondsSinceEpoch <
                          _upperDate.millisecondsSinceEpoch) {
                        dateRange.add(incrementDate);
                        DateTime temp = incrementDate;
                        incrementDate = DateTime(
                            temp.year, temp.month, temp.day + 1, 6, 30);
                      }
                      dateRange.add(_upperDate);

                      for (DateTime whichDay in dateRange) {
                        if (dateRange.length < 32) {
                          QuerySnapshot snap = await _firestore
                              .collection(
                                  'orders/byTime/${whichDay.toString().substring(0, 10)}')
                              .where('shopDetails.uid', isEqualTo: uid)
                              // .orderBy('time', descending: true)
                              .get();
                          List<DocumentSnapshot> snapshot = snap.docs;

                          dateRangeFirestoreData.addAll(snapshot);
                        }
                        print(dateRangeFirestoreData);
                        createBill(dateRangeFirestoreData, context, whichDay);
                        _showSpinner = false;
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(height: 2),
                  billWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> _selectDate(
      BuildContext context, DateTime _whichDay, bool isLower) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _whichDay,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    print('$_whichDay $picked');
    if (picked != null && picked != _whichDay && isLower) _lowerDate = picked;
    if (picked != null && picked != _whichDay && !isLower) _upperDate = picked;
    setState(() {});
    // callSetStateWIthDelay();
  }
}

Widget billWidget = Text('No Data');

void createBill(List<DocumentSnapshot> dateRangeFirestoreData,
    BuildContext context, DateTime date) {
  Map calculatedResult = profitDetails(dateRangeFirestoreData);
  List<Map> filteredShops = calculatedResult['shops'];
  List unSupportedOrders = calculatedResult['unSupportedOrders'];
  billWidget = Column(
    children: [
      Material(
        color: Colors.white,
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(10),
          // height: MediaQuery.of(context).size.height - 270,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              unSupportedOrders.isNotEmpty
                  ? Text('Not Supported: $unSupportedOrders')
                  : Container(),
              Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 10000),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredShops.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map shop = filteredShops[index];
                    String shopName = filteredShops[index]['shopName'];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          SizedBox(
                            child: Text('${shop['shopName']} : '),
                            width: 150,
                          ),
                          Text('₹'),
                          SizedBox(
                            child: Text(
                              '${shop['total']}',
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.end,
                            ),
                            width: 60,
                          ),
                          Spacer(),
                          Text(
                            profitMap[shopName] != null
                                ? '₹${(shop['total'] * profitMap[shopName]) / 100}'
                                : '',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    SizedBox(child: Text('Total Shops Fees :'), width: 150),
                    Text('₹'),
                    SizedBox(
                      child: Text(
                        '${calculatedResult['total']}',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.end,
                      ),
                      width: 60,
                    ),
                    Spacer(),
                    Text(
                      '₹${calculatedResult['profit']}',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    SizedBox(
                      child: Text(
                        'Profit:  ',
                      ),
                      width: 150,
                    ),
                    Text('₹'),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${calculatedResult['profit']}',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    SizedBox(child: Text('Total :'), width: 150),
                    Text('₹'),
                    SizedBox(
                      child: Text(
                        '${calculatedResult['total'] - calculatedResult['profit']}',
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.end,
                      ),
                      width: 60,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Divider(),
              SizedBox(height: 50),
            ],
          ),
          // decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border.all(color: Colors.black)),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
