import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

int calcTotalMoney(Map orderDetails, int refNo) {
  int total = 0;
  if (orderDetails['details'] != null) {
    List ordersList = orderDetails['details']['ordersList'];
    for (Map order in ordersList) {
      total = total + order['amount'];
    }
    // print('{$refNo : $total}');
    return total;
  } else {
    // print('order $refNo excluded');
    return 0;
  }
}

Map profitDetails(List<DocumentSnapshot> orderDetailsList) {
  int total = 0;
  int totalDeliverFee = 0;
  double totalProfit = 0;
  List<Map> shops = [];
  List unSupportedOrders = [];
  int offlineCash = 0;
  int onlineCash = 0;
  List<Map> boyDetails = [];
  for (DocumentSnapshot orderDetailData in orderDetailsList) {
    int refNo;
    Map orderDetails = orderDetailData.data();
    if (orderDetails['status'] != 'canceled') {
      bool shopExists = false;
      refNo = orderDetails['refNo'];
      String boyName;
      if (orderDetails['boyDetails'] != null) {
        boyName = orderDetails['boyDetails']['name'];
      }
      print('boyName $boyName');
      if (orderDetails['details'] != null) {
        List ordersList = orderDetails['details']['ordersList'];
        totalDeliverFee = totalDeliverFee + orderDetails['deliveryFee'];
        print(orderDetails['paymentMethod']);
        //add deliveryFee
        if (orderDetails['paymentMethod'] == 'online') {
          onlineCash = onlineCash + orderDetails['deliveryFee'];
        } else {
          offlineCash = offlineCash + orderDetails['deliveryFee'];
          addBoyData(boyDetails, boyName, orderDetails['deliveryFee']);
        }
        for (Map order in ordersList) {
          total = total + order['amount'];
          if (orderDetails['paymentMethod'] == 'online') {
            onlineCash = onlineCash + order['amount'];
          } else {
            offlineCash = offlineCash + order['amount'];
            addBoyData(boyDetails, boyName, order['amount']);
          }
          if (profitMap[order['shopName']] != null) {
            totalProfit = totalProfit +
                ((order['amount'] * profitMap[order['shopName']]) / 100);
          }
          for (Map shop in shops) {
            if (shop['shopName'] == order['shopName']) {
              shop['total'] = shop['total'] + order['amount'];

              shopExists = true;
            }
          }
          if (shopExists == false) {
            double profit = 0;
            if (profitMap[order['shopName']] != null) {
              double profit =
                  (order['amount'] * profitMap[order['shopName']]) / 100;
            }

            shops.add({
              'shopName': order['shopName'],
              'total': order['amount'],
              'profit': profit
            });
          }
        }

        // print('{$refNo : $total}');
      } else {
        print('order $refNo excluded');
        unSupportedOrders.add(' ref no : $refNo ');
      }
    }
  }

  return {
    'shops': shops,
    'unSupportedOrders': unSupportedOrders,
    'total': total,
    'deliveryFee': totalDeliverFee,
    'profit': totalProfit,
    'onlineCash': onlineCash,
    "offlineCash": offlineCash,
    'boyDataList': boyDetails,
  };
}

Map profitMap = {
  'Coconut Grove': 15,
  'Black Bowl': 15,
  "Vkp's Cafe": 10,
  'Ammuma Kitchen': 20,
};

void addBoyData(List<Map> boyDetails, String boyName, int cash) {
  bool boyExists = false;
  for (Map boy in boyDetails) {
    if (boy['name'] == boyName) {
      boy['cashInHand'] = boy['cashInHand'] + cash;

      boyExists = true;
    }
  }
  if (boyExists == false) {
    boyDetails.add({'name': boyName, 'cashInHand': cash});
  }
}
