import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dailyneedsserver/screens/individualOrders/individualOrders.dart';
import 'package:dailyneedsserver/screens/individualOrders/timeComparison.dart';
import 'package:provider/provider.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
List _orders = [];
List<DocumentSnapshot> _allOrdersFiltered = [];
List<DocumentSnapshot> _allOrders;
var _whichDay;
String _whichType = 'all';
List whichTypeList = ['all', 'ordered', 'canceled', 'delivered'];
String uid;

class AllOrders extends StatefulWidget {
  @override
  _AllOrdersState createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  @override
  void initState() {
    uid = Provider.of<IsInList>(context, listen: false).userDetails['uid'];

    _whichType = 'all';
    _whichDay = DateTime.now();
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _whichDay,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != _whichDay) _whichDay = picked;
    print('date changed');
    setState(() {});
    callSetStateWIthDelay();
  }

  DateTime _today = DateTime.now();
  String toYesterday(DateTime now) {
    final lastMidnight = new DateTime(now.year, now.month, now.day - 1);
    return lastMidnight.toLocal().toString().split(' ')[0];
  }

  void callSetStateWIthDelay() async {
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {});
  }

  List filterOrder(String whichType, List allOrders) {
    if (whichType == 'all') {
      return allOrders;
    }
    return allOrders
        .where((value) => value.data()['status'] == whichType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('All orders'),
        actions: <Widget>[
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Text(
                "${_whichDay.toLocal()}".split(' ')[0],
                textAlign: TextAlign.center,
              ),
              alignment: Alignment.center,
              height: double.infinity,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection(
                'orders/byTime/${_whichDay.toString().substring(0, 10)}')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData == false) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // _allOrders = snapshot.data.documents;
          _allOrders = snapshot.data.documents
              .where((value) => isForMe(value.data()['shopDetails'], uid))
              .toList();
          _allOrdersFiltered = filterOrder(_whichType, _allOrders);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                    height: 50,
                    child: ListView.builder(
                      padding: EdgeInsets.all(0),
                      scrollDirection: Axis.horizontal,
                      itemCount: whichTypeList.length,
                      itemBuilder: (context, i) {
                        return FlatButton(
                          onPressed: () {
                            setState(() {
                              columWidget = [];
                              _whichType = whichTypeList[i];
                            });
                          },
                          child: Container(
                            height: 50,
                            // width: 50,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Container(
                                  child: Text(
                                      odersCountByStatus(
                                              whichTypeList[i], _allOrders)
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                  decoration: BoxDecoration(
                                      color: _whichType == whichTypeList[i]
                                          ? Color(0xfff25d9c)
                                          : Colors.lightBlueAccent,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  width: 20,
                                  height: 15,
                                  alignment: Alignment.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${whichTypeList[i]}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _whichType == whichTypeList[i]
                                          ? Color(0xfff25d9c)
                                          : Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemCount: _allOrdersFiltered.length,
                    itemBuilder: (context, index) {
                      String status =
                          _allOrdersFiltered[index].data()['status'];
                      bool shopViewed =
                          _allOrdersFiltered[index].data()['shopViewed'];
                      var orderedTime =
                          _allOrdersFiltered[index].data()['time'];
                      Timestamp deliveredTime =
                          _allOrdersFiltered[index].data()['deliveredTime'] ??
                              null;
                      Map shopDetails =
                          _allOrdersFiltered[index].data()['boyDetails'];

                      return ExtractedAllOrdersContainer(
                        index: index,
                        status: status,
                        orderedTime: orderedTime,
                        deliveredTime: deliveredTime,
                        totalOrders: _allOrdersFiltered.length,
                        shopDetails: shopDetails,
                        shopViewed: shopViewed,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
//          StreamBuilder<QuerySnapshot>(
  }
}

bool isForMe(Map boyDetails, String uid) {
  if (boyDetails == null) {
    return false;
  } else {
    String boyUid = boyDetails['uid'];
    if (boyUid == uid) {
      return true;
    } else {
      return false;
    }
  }
}

int odersCountByStatus(String status, List allOrders) {
  int count = 0;
  if (status == 'all') {
    return count = allOrders.length;
  }
  for (DocumentSnapshot orders in allOrders) {
    String ostatus = orders.data()['status'];
    if (status == ostatus) {
      count++;
    }
  }
  print('count $count');
  return count;
}

class ExtractedAllOrdersContainer extends StatelessWidget {
  final int index;
  final String status;
  final orderedTime;
  final deliveredTime;
  final int totalOrders;
  final Map shopDetails;
  final bool shopViewed;
  ExtractedAllOrdersContainer(
      {this.index,
      this.status,
      this.orderedTime,
      this.deliveredTime,
      this.shopDetails,
      this.shopViewed,
      this.totalOrders});
  @override
  Widget build(BuildContext context) {
    int _nowInMS = DateTime.now().millisecondsSinceEpoch;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IndividualOrders(
                        email: '${_allOrders[index].data()['email']}',
                        orderedTimeFrmPrvsScreen: orderedTime,
                        orderNumber: _allOrders[index].data()['refNo'],
                        byTimeId: _allOrders[index].id,
                        shopViewed: shopViewed,
                        shopDetails: shopDetails,
                      )));
        },
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        width: 40,
                        color: status == 'ordered'
                            ? Colors.purple
                            : status == 'delivered'
                                ? status == 'shipped'
                                    ? Colors.orange
                                    : Colors.green
                                : status == 'canceled'
                                    ? Colors.grey
                                    : Colors.orange,
                        child: Text(
                          '${_allOrders[index].data()['refNo']}',
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(width: 6),
                    Expanded(
                        child: Text('${_allOrders[index].data()['email']}')),
                    Text(status,
                        style: TextStyle(
                            fontSize: 12,
                            color: status == 'ordered'
                                ? Colors.purple
                                : status == 'delivered'
                                    ? status == 'shipped'
                                        ? Colors.orange
                                        : Colors.green
                                    : status == 'canceled'
                                        ? Colors.grey
                                        : Colors.orange)),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Ordered: ${timeConvertor(_nowInMS - orderedTime.millisecondsSinceEpoch, orderedTime)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 11),
                      ),
                    ),
                    deliveredTime != null
                        ? Expanded(
                            child: Text(
                              'Delivered:${timeConvertor(_nowInMS - deliveredTime.millisecondsSinceEpoch, deliveredTime)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                  fontSize: 11),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    color: status == 'ordered'
                        ? Colors.purple
                        : status == 'delivered'
                            ? status == 'shipped'
                                ? Colors.orange
                                : Colors.green
                            : status == 'canceled'
                                ? Colors.grey
                                : Colors.orange,
                    width: 1.5),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
      ),
    );
  }
}
