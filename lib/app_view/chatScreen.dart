import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sidework_mobile/utilities/constants.dart';
import 'package:sidework_mobile/utilities/customFormTextFields.dart';

class ChatScreen extends StatefulWidget {
  String clientEmail;
  String handymanEmail;
  String firstName;
  String lastName;
  ChatScreen({
    Key? key,
    required this.clientEmail,
    required this.handymanEmail,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController cardHolderNumberController = TextEditingController();
  TextEditingController cardHolderMonthController = TextEditingController();
  TextEditingController cardHolderYearController = TextEditingController();
  TextEditingController cardHolderCodeController = TextEditingController();
  TextEditingController cardHolderZipController = TextEditingController();
  List<QueryDocumentSnapshot> allChatMessages = [];
  TextEditingController newMessageController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  int initialPrice = 0;
  bool initialLoadFinish = false;
  late var currentBooking;
  String? selectedValue = '5';
  bool bookingPaid = true;
  bool invoiceSent = false;
  List<String> tags = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  @override
  void initState() {
    super.initState();
    getInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.sideworkBlue,
        centerTitle: true,
        title: Text(
          '${widget.firstName} ${widget.lastName}',
          style: const TextStyle(
            color: Constants.lightTextColor,
          ),
        ),
        actions: [
          initialLoadFinish
              ? bookingPaid
                  ? Container()
                  : workOption()
              : Container(),
          initialLoadFinish
              ? invoiceSent
                  ? bookingPaid
                      ? Container()
                      : clientOption()
                  : Container()
              : Container(),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            buildListMessage(),
            buildInput(),
          ],
        ),
      ),
    );
  }

  /// Get initial data of the booking
  Future<void> getInitialData() async {
    FirebaseFirestore.instance
        .collection('bookings')
        .where('clientEmail', isEqualTo: widget.clientEmail)
        .where('handymanEmail', isEqualTo: widget.handymanEmail)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      setState(() {
        for (var v in snapshot.docs) {
          initialPrice = int.parse(v['totalPrice'].toStringAsFixed(0));
          bookingPaid = v['bookingPaid'];
          invoiceSent = v['invoiceSent'];
          currentBooking = v;
        }
        initialLoadFinish = true;
      });
    });
  }

  /// Function to build the input section to send a message
  Widget buildInput() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Constants.darkTextColor,
          width: 0.5,
        ),
        color: Constants.lightTextColor,
      ),
      child: Row(
        children: <Widget>[
          /// Text Fields
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                // onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(
                color: Constants.darkTextColor,
                fontSize: 15,
              ),
              controller: newMessageController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(
                  color: Constants.regularTextColor,
                ),
              ),
              autofocus: true,
            ),
          ),

          /// Button to send message
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              child: IconButton(
                  color: Constants.sideworkBlue,
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    onSendMessage(newMessageController.text);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  /// Function to build message section
  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('groupId',
                isEqualTo: '${widget.clientEmail}${widget.handymanEmail}')
            .orderBy('timestamp')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            allChatMessages = snapshot.data!.docs;
            if (allChatMessages.isNotEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) =>
                    buildItem(index, snapshot.data?.docs[index]),
                itemCount: snapshot.data!.docs.length,
                controller: listScrollController,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 4,
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No message here yet..."),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Constants.sideworkBlue,
              ),
            );
          }
        },
      ),
    );
  }

  /// Build each message and adjust their position to the left or right based on the person looking at it.
  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      /// When clients is current user
      if (document['sender'] == FirebaseAuth.instance.currentUser!.email!) {
        /// My message
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(
                15,
                10,
                15,
                10,
              ),
              width: 200,
              decoration: BoxDecoration(
                color: Constants.sideworkGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                document['content'],
                style: const TextStyle(
                  color: Constants.lightTextColor,
                ),
              ),
            ),
          ],
        );
      } else {
        /// Other person's message
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Constants.regularTextColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      document['content'],
                      style: const TextStyle(
                        color: Constants.darkTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Function to add messages to the chat & Firestore
  onSendMessage(String content) async {
    if (newMessageController.text.isNotEmpty) {
      newMessageController.clear();
      var data = {
        "sender": FirebaseAuth.instance.currentUser!.email!,
        "idTo": FirebaseAuth.instance.currentUser!.email! == widget.clientEmail
            ? widget.handymanEmail
            : widget.clientEmail,
        "content": content,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "groupId": "${widget.clientEmail}${widget.handymanEmail}",
      };

      try {
        FirebaseFirestore.instance
            .collection("messages")
            .doc()
            .set(
              data,
            )
            .then((value) {});
      } catch (e) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: Constants.sideworkBlue,
          textColor: Constants.lightTextColor,
        );
      }
    }
  }

  /// Function to start invoice form for handyman to get paid
  Widget workOption() {
    if (FirebaseAuth.instance.currentUser!.email == widget.handymanEmail &&
        initialPrice <= 0) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Constants.sideworkGreen,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          launchApprovalForm();
        },
        child: const Text('Complete'),
      );
    } else {
      return Container();
    }
  }

  /// Function to start credit card form for client to pay
  Widget clientOption() {
    if (FirebaseAuth.instance.currentUser!.email == widget.clientEmail &&
        initialPrice >= 0) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Constants.sideworkGreen,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          launchPaymentForm();
        },
        child: const Text('Approve'),
      );
    } else {
      return Container();
    }
  }

  /// Approval form that handymen sends
  Future<void> launchApprovalForm() async {
    TextEditingController priceController = TextEditingController();

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CustomFormTextFields(
              maxLines: 1,
              controller: priceController,
              hintTitle: 'Enter invoice amount',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await updateBooking(
                      priceController.text, widget.handymanEmail, context);
                },
                child: const Text('Send for approval'),
              ),
            ],
          );
        });
  }

  /// Approving and rating form that clients fill out
  Future<void> launchClientApprovalForm() async {
    TextEditingController ratingController = TextEditingController();

    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Approve payment of \$50.75?'),
            content: DropdownButton<String>(
              hint: const Text('Please rate your handyman'),
              items: <String>['5', '4', '3', '2', '1'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  ratingController.text = value!;
                });
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await updateBooking(
                      ratingController.text, widget.clientEmail, context);
                },
                child: const Text('Approve'),
              ),
            ],
          );
        });
  }

  /// Function to create a new booking
  Future<void> updateBooking(
      String price, String handymanEmail, BuildContext context) async {
    try {
      var data = {
        "totalPrice": double.parse(price),
        "bookingPaid": false,
        "invoiceSent": true,
      };

      FirebaseFirestore.instance
          .collection('bookings')
          .where('clientEmail', isEqualTo: widget.clientEmail)
          .where('handymanEmail', isEqualTo: widget.handymanEmail)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .then((snapshot) {
        snapshot.docs[0].reference.update(data);
        getInitialData();
        Fluttertoast.showToast(
          msg: "Approval request sent!",
          backgroundColor: Constants.sideworkBlue,
          textColor: Constants.lightTextColor,
        );
        Navigator.pop(context);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }

  /// Function to pay the handyman by the client
  Future<void> launchPaymentForm() async {
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Pay \$${currentBooking['totalPrice'].toStringAsFixed(2)}?',
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomFormTextFields(
                      hintTitle: 'Card Name Holder',
                      maxLines: 1,
                      controller: cardHolderNameController,
                    ),
                    CustomFormTextFields(
                      hintTitle: 'Card Number',
                      maxLines: 1,
                      controller: cardHolderNumberController,
                    ),
                    CustomFormTextFields(
                      hintTitle: 'Expiration Month',
                      maxLines: 1,
                      controller: cardHolderMonthController,
                    ),
                    CustomFormTextFields(
                      hintTitle: 'Expiration Year',
                      maxLines: 1,
                      controller: cardHolderYearController,
                    ),
                    CustomFormTextFields(
                      hintTitle: 'Security code',
                      maxLines: 1,
                      controller: cardHolderCodeController,
                    ),
                    CustomFormTextFields(
                      hintTitle: 'Zip code',
                      maxLines: 1,
                      controller: cardHolderZipController,
                    ),
                    const Text(
                      'Rate your handyman: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text(
                            'Choose a rating',
                            textAlign: TextAlign.center,
                          ),
                          value: selectedValue,
                          onChanged: (val) {
                            setState(() {
                              selectedValue = val.toString();
                            });
                          },
                          items: tags.map((tag) {
                            return DropdownMenuItem<String>(
                              value: tag,
                              child: Text(
                                tag,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    validatePay();
                  },
                  child: const Text('Pay'),
                ),
              ],
            );
          });
        });
  }

  /// Function to validate payment
  validatePay() {
    if (cardHolderNameController.text.isEmpty ||
        cardHolderNameController.text == '') {
      Fluttertoast.showToast(
        msg: 'Card holder name is empty.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (cardHolderNumberController.text.isEmpty ||
        cardHolderNumberController.text == '' ||
        cardHolderNumberController.text.length != 16) {
      Fluttertoast.showToast(
        msg: 'Card holder number must be 16 digits.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (cardHolderMonthController.text.isEmpty ||
        cardHolderMonthController.text == '' ||
        cardHolderMonthController.text.length != 2) {
      Fluttertoast.showToast(
        msg: 'Month must be two digits.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (cardHolderYearController.text.isEmpty ||
        cardHolderYearController.text == '' ||
        cardHolderYearController.text.length != 4) {
      Fluttertoast.showToast(
        msg: 'Year must be four digits.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (cardHolderCodeController.text.isEmpty ||
        cardHolderCodeController.text == '' ||
        cardHolderCodeController.text.length != 3) {
      Fluttertoast.showToast(
        msg: 'Year must be three digits.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else if (cardHolderZipController.text.isEmpty ||
        cardHolderZipController.text == '' ||
        cardHolderZipController.text.length != 5) {
      Fluttertoast.showToast(
        msg: 'Year must be five digits.',
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    } else {
      pay();
    }
  }

  /// Update firebase to update [bookingPaid] to true
  Future<void> pay() async {
    try {
      var data = {
        "bookingPaid": true,
        "rating": int.parse(selectedValue!),
      };

      FirebaseFirestore.instance
          .collection('bookings')
          .where('clientEmail', isEqualTo: widget.clientEmail)
          .where('handymanEmail', isEqualTo: widget.handymanEmail)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .then((snapshot) {
        snapshot.docs[0].reference.update(data);
        getInitialData();
        Fluttertoast.showToast(
          msg: "Handyman paid!",
          backgroundColor: Constants.sideworkBlue,
          textColor: Constants.lightTextColor,
        );
        Navigator.pop(context);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Constants.sideworkBlue,
        textColor: Constants.lightTextColor,
      );
    }
  }
}
