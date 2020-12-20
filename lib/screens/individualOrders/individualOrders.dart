import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyneedsserver/functions/quantityFormat.dart';
import 'package:dailyneedsserver/functions/sendFcm.dart';
import 'package:dailyneedsserver/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timeComparison.dart';
import 'ExtractedAdressBox.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

String _whichType = 'all';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
List _orders = [];
bool isDataAvailable = false;
List<DocumentSnapshot> _details = [];
List<Widget> columWidget = [];

class IndividualOrders extends StatefulWidget {
  final String email;
  final Timestamp orderedTimeFrmPrvsScreen;
  final orderNumber;
  final String byTimeId;
  final Map shopDetails;
  final bool shopViewed;

  IndividualOrders(
      {this.email,
      this.orderedTimeFrmPrvsScreen,
      this.orderNumber,
      @required this.shopDetails,
      @required this.shopViewed,
      this.byTimeId});
  @override
  _IndividualOrdersState createState() => _IndividualOrdersState();
}

class _IndividualOrdersState extends State<IndividualOrders> {
  List whichTypeList = ['Order', 'all', 'ordered', 'canceled', 'delivered'];

  @override
  void initState() {
    _whichType = 'Order';
    columWidget = [];
    // var date = new DateTime.fromMicrosecondsSinceEpoch();
    int millSecond = widget.orderedTimeFrmPrvsScreen.microsecondsSinceEpoch;

    print('id ${widget.byTimeId.split('+')[0]}');
    super.initState();
  }

  _ago(Timestamp t) {
    return timeago.format(t.toDate());
  }

  openMapsSheet(context, String location) async {
    List stringList = location.split(',');
    try {
      final title = "Shanghai Tower";
      final description = "Asia's tallest building";
      final coords =
          Coords(double.parse(stringList[0]), double.parse(stringList[1]));
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                          description: description,
                        ),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Individual Orders'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Container(
          //     height: 50,
          //     child: ListView.builder(
          //       padding: EdgeInsets.all(0),
          //       scrollDirection: Axis.horizontal,
          //       itemCount: whichTypeList.length,
          //       itemBuilder: (context, i) {
          //         return FlatButton(
          //           onPressed: () {
          //             setState(() {
          //               columWidget = [];
          //               _whichType = whichTypeList[i];
          //             });
          //           },
          //           child: Text(
          //             '${whichTypeList[i]} ${i == 0 ? '(' + widget.orderNumber.toString() + ')' : ''}',
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //                 color: _whichType == whichTypeList[i]
          //                     ? Color(0xfff25d9c)
          //                     : Colors.black),
          //           ),
          //         );
          //       },
          //     )),
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('orders/by/${widget.email}')
                .doc(widget.byTimeId.split('+')[0])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _details = [snapshot.data];
              } else {
                _details = [];
              }
              _orders = [];
              int _nowInMS = DateTime.now().millisecondsSinceEpoch;
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 8),
                  itemCount: _details.length,
                  itemBuilder: (BuildContext context, int index) {
                    List ordersList = _details[index].data()['ordersList'];
                    Timestamp orderedTime = _details[index].data()['time'];
                    Timestamp deliveredTime =
                        _details[index].data()['deliveredTime'] ?? null;
                    var _address = _details[index].data()['address'];
                    var _deliveryFee = _details[index].data()['deliveryFee'];
                    var _deliverySolot = _details[index].data()['deliverySlot'];
                    var _location = _details[index].data()['location'];
                    String fcmId = _details[index].data()['fcmId'];
                    String status = _details[index].data()['status'];
                    bool prepared = _details[index].data()['prepared'];
                    String paymentMode =
                        _details[index].data()['paymentMethod'];
                    String _documentId = (_details[index].id);
                    int total = 0;
                    columWidget = [];
                    if (widget.shopViewed != true) {
                      _firestore
                          .collection(
                              'orders/byTime/${orderedTime.toDate().toString().substring(0, 10)}')
                          .doc(widget.byTimeId)
                          .update({
                        'shopViewed': true,
                      });
                    }
                    for (Map individualorder in ordersList) {
                      total = individualorder['amount'] + total;
                      Widget toAdd = Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 6, bottom: 6, right: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
//                            SizedBox(width: 8),
                            Expanded(
                                child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        text: '${individualorder['name']} ',
                                        children: [
                                          individualorder['shopName'] != null
                                              ? TextSpan(
                                                  text: '( ' +
                                                      individualorder[
                                                          'shopName'] +
                                                      ' )',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey),
                                                )
                                              : TextSpan(),
                                        ]),
                                  ),
                                  flex: 2,
                                ),
                              ],
                            )),
                            SizedBox(width: 8),
                            Text(
                                '${quantityFormat(individualorder['quantity'], individualorder['unit'])}'),
                            Text(' / ₹${individualorder['amount']}.00')
                          ],
                        ),
                      );
                      if (_whichType == 'Order') {
                        if (widget.orderedTimeFrmPrvsScreen == orderedTime) {
                          columWidget.add(toAdd);
                        }
                      } else if (status == _whichType) {
                        columWidget.add(toAdd);
                      } else if (_whichType == 'all') {
                        print('all order');
                        columWidget.add(toAdd);
                      }
                    }
                    bool _isOrderedToday =
                        orderedTime.toDate().toString().substring(0, 10) ==
                            DateTime.now().toString().substring(0, 10);
                    return columWidget.length <= 0
                        ? Container()
                        : Container(
                            padding: EdgeInsets.all(4),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 2,
                                  color: status == 'ordered'
                                      ? Colors.purple
                                      : status == 'delivered'
                                          ? status == 'shipped'
                                              ? Colors.orange
                                              : Colors.green
                                          : status == 'canceled'
                                              ? Colors.grey
                                              : Colors.orange,
                                )),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 4),
                                  child: Row(
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
                                  ),
                                ),
                                Material(
                                  elevation: 3,
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 10),
                                        Column(
                                          children: columWidget,
                                        ),
                                        SizedBox(height: 6),
                                        // deliveryFee
                                        Container(
                                          child: Row(
                                            children: [
                                              Text(
                                                'Delivery Fee :',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Spacer(),
                                              Text(
                                                '₹$_deliveryFee',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          width: double.infinity,
                                          height: 20,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  status ?? 'nill',
                                                  style: TextStyle(
                                                      color: status == 'ordered'
                                                          ? Colors.purple
                                                          : status ==
                                                                  'delivered'
                                                              ? status ==
                                                                      'shipped'
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors.green
                                                              : status ==
                                                                      'canceled'
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .orange),
                                                ),
                                                SizedBox(width: 2),
                                                status == 'ordered'
                                                    ? Icon(
                                                        Icons
                                                            .playlist_add_check,
                                                        color: Colors.purple)
                                                    : status == 'canceled'
                                                        ? Icon(
                                                            Icons.close,
                                                            color: Colors.grey,
                                                          )
                                                        : Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          ),
                                              ],
                                            ),
                                            Text(
                                              'Total : ₹ ${total + _deliveryFee}.00',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.purple),
                                              textAlign: TextAlign.end,
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                        ),
                                        SizedBox(height: 18),
                                        Text('Payment Method :  $paymentMode'),
                                        SizedBox(height: 18),
                                        Text(
                                          '$_deliverySolot',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 18),
                                FlatButton(
                                  child: Text(
                                    prepared == true
                                        ? 'Prepared'
                                        : 'Make Prepared',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    await _firestore
                                        .collection(
                                            'orders/byTime/${orderedTime.toDate().toString().substring(0, 10)}')
                                        .doc(widget.byTimeId)
                                        .update({
                                      'prepared': true,
                                    });
                                    await _firestore
                                        .collection('orders/by/${widget.email}')
                                        .doc(widget.byTimeId.split('+')[0])
                                        .update({'prepared': true});
                                    Map userData = Provider.of<IsInList>(
                                            context,
                                            listen: false)
                                        .userDetails;
                                    print(widget.shopDetails['token']);
                                    SendToAdmin(
                                        'Order ${widget.orderNumber} is prepared',
                                        'From ${userData['name']}',
                                        widget.shopDetails['token']);
                                  },
                                  color: prepared == true
                                      ? Colors.green
                                      : Colors.blueAccent,
                                ),
                              ],
                            ),
                          );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
