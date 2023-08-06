import 'package:flutter/material.dart';
import 'package:my_tracker/models/user.dart';
import 'package:my_tracker/services/auth.dart';
import 'package:my_tracker/services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {

  String id;
  String name;
  int price;

  Expense({required this.id, required this.name, required this.price});

  Expense.fromDocumentSnapshot(DocumentSnapshot doc)
      : id = doc.id,
        name = doc['name'],
        price = doc['price'];
}
class homepage extends StatefulWidget{
  String? get userId => null;

  @override
  homepageState createState() => homepageState();
}
class homepageState extends State<homepage> {
  int totalbudget=0;
  List<Expense> expenses = [];
  bool showexpense = false;
  final authservice _auth = authservice();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  get onCategoryChanged => null;

  @override
  void initState(){
    super.initState();
    _gettotalbudget();
  }
  Future<void> _gettotalbudget() async {
    SharedPreferences preferences=await SharedPreferences.getInstance();
    int? budget=preferences.getInt('total_budget');
    if (budget!=null){
      setState(() {
        totalbudget=budget;
      });
    }
    else _showbudgetdialog();
  }
  void _showbudgetdialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Total Budget'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                totalbudget = int.tryParse(value) ?? 0;
              });
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                SharedPreferences preferences = await SharedPreferences.getInstance();
                preferences.setInt('total_budget', totalbudget);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }


  homepageState() {
    this.expenses;
    this.onCategoryChanged;
  }


  void fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(
        widget.userId).collection('categories').get();
    setState(() {
      expenses.clear();
      totalbudget=0;
      for (var doc in snapshot.docs) {
        final category = Expense.fromDocumentSnapshot(doc);
        expenses.add(category);

      }
    });
  }
  void deleteCategory(String categoryId) async {
    final categoryRef = FirebaseFirestore.instance.collection('users').doc(
        widget.userId).collection('categories').doc(categoryId);
    final categorySnapshot = await categoryRef.get();
    if (categorySnapshot.exists) {
      final category = Expense.fromDocumentSnapshot(categorySnapshot);
      await categoryRef.delete();
      setState(() {
        expenses.removeWhere((element) => element.id == categoryId);
        //totalbudget += ;
      });
    }
  }


  void addexpense(String name, int amount) async {
    if (name.isNotEmpty && amount != null) {
      final Expense newExpense = Expense(price: 0, name: '', id: '');
      setState(() {
        //expenses.add(newExpense);

      });
      final newCategoryRef = await FirebaseFirestore.instance.collection(
          'users').doc(widget.userId).collection('categories').add({
        'name': name,
        'price': amount,
      });
      final newCategory = Expense(
          id: newCategoryRef.id, name: name, price: -amount);
      setState(() {
        expenses.add(newCategory);
        totalbudget -= amount;
      });
    }
    }


    void removeexpense(int index) {
      setState(() {
        final removedExpense = expenses.removeAt(index);
        totalbudget -= removedExpense.price;
      });
    }
    void showAddExpenseDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('New Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),),
                    SizedBox(height: 15,),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red
                            ),
                            child: Container(
                              child: Text('Cancel'),
                            )),
                        ElevatedButton(
                            onPressed: () {
                              final String name = nameController.text;
                              final int amount = int.tryParse(
                                  amountController.text) ?? 0;
                              addexpense(name, amount);
                              nameController.clear();
                              amountController.clear();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green
                            ),
                            child: Container(
                              child: Text('Add'),
                            ))
                      ],
                    )
                  ],
                ),
              ),


            );
          }
      );
    }
    Widget build(BuildContext context) {
      return
        StreamProvider<QuerySnapshot?>.value(
            initialData: null,
            value: DatabaseService().details,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Budget Tracker',
                  style: TextStyle(
                    fontSize: 40,

                  ),
                  textAlign: TextAlign.center,),
                actions: [
                  ElevatedButton(
                    child: Column(children: [Icon(Icons.logout),
                      Text('Logout')]),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  )
                ],
              ),
              body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/page.jpg'),
                        fit: BoxFit.cover,)
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 90),
                        Container
                          (child: Align(
                          alignment: Alignment(0, -0.3),
                          child: Text('Welcome back!',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Pangolin',


                            ),),
                        )),
                        SizedBox(height: 35,),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showexpense = !showexpense;
                            });
                          },
                          onDoubleTap: (){
                            _showbudgetdialog();
                          },
                          child: Container(
                              height: 35,
                              width: 300,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [BoxShadow(
                                    blurRadius: 4,
                                    color: Colors.grey.withOpacity(0.5)
                                )
                                ],
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Text('Total : ₹${totalbudget}',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'VT323',
                                    fontWeight: FontWeight.bold,
                                  ),),

                              )),
                        ),
                        if (showexpense)...[
                          SizedBox(height: 15),
                          Text('Expenses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                              color: Colors.deepPurple[900],
                              fontFamily: 'Lugrasimo',

                            ),),
                          Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  final expense = expenses[index];
                                  var amount=expense.price;
                                  return
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 50),
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(
                                              20),
                                          color: Colors.transparent,
                                          //gradient: LinearGradient(
                                          //colors: [Colors.purple,Colors.deepPurple],
                                          //begin: Alignment.topCenter,
                                          //end: Alignment.bottomCenter,
                                          //)

                                        ),
                                        child: ListTile(
                                            title: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceEvenly,
                                                children: [
                                                  Text('${expense.name}',
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontWeight: FontWeight
                                                          .w700,
                                                      fontFamily: 'Pacifico',
                                                      color: Colors.pinkAccent,
                                                    ),
                                                  ),
                                                  Text('₹${expense.price}',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight: FontWeight
                                                            .w600,
                                                        fontFamily: 'Pacifico',
                                                        color: expense.price>=0 ? Colors.green:Colors.red

                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      removeexpense(index);
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          border: Border.all(
                                                              width: 2)
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.black,
                                                      ),),)
                                                ]))
                                    );
                                }
                                ,

                              )),
                        ]


                      ],
                    ),
                  ))

              ,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showAddExpenseDialog(context);
                },
                child: Icon(Icons.add),
              ),
            )
        );
    }
  }


//Container(
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image:AssetImage('images/page.jpg'),
//                   fit:BoxFit.cover,)
//             ),
//             child:Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(height: 90),
//                   Container
//                     (child:Align(
//                     alignment: Alignment(0,-0.3),
//                     child:Text('Welcome back!',
//                       style: TextStyle(
//                         fontSize: 50,
//                         fontWeight: FontWeight.w900,
//                         fontFamily: 'Pangolin',
//
//
//                       ),),
//                   )),
//                   SizedBox(height: 35,),
//                   GestureDetector(
//                     onTap:(){
//                       setState(() {
//                         showexpense=!showexpense;
//                       });
//                     },
//                     child: Container(
//                         height: 35,
//                         width: 300,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.rectangle,
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(10),
//                           boxShadow: [BoxShadow(
//                               blurRadius: 4,
//                               color:Colors.grey.withOpacity(0.5)
//                           )],
//                           gradient: LinearGradient(
//                             colors: [Colors.orange,Colors.deepOrange],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                         child: Center(child:Text('Total : ₹${totalbudget}',
//                           style: TextStyle(
//                             fontSize: 25,
//                             fontFamily: 'VT323',
//                             fontWeight: FontWeight.bold,
//                           ),),
//
//                         )),
//                   ),
//                   if (showexpense)...[
//                     SizedBox(height:15),
//                     Text('Expenses',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 35,
//                         color: Colors.deepPurple[900],
//                         fontFamily: 'Lugrasimo',
//
//                       ),),
//                     Expanded(
//                         child:ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: expenses.length,
//                           itemBuilder: (context,index){
//                             final expense=expenses[index];
//                             return
//                               Container(
//                                   margin: EdgeInsets.symmetric(vertical: 5,horizontal: 50),
//                                   padding: EdgeInsets.all(2),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.rectangle,
//                                     borderRadius: BorderRadius.circular(20),
//                                     color: Colors.transparent,
//                                     //gradient: LinearGradient(
//                                     //colors: [Colors.purple,Colors.deepPurple],
//                                     //begin: Alignment.topCenter,
//                                     //end: Alignment.bottomCenter,
//                                     //)
//
//                                   ),
//                                   child:ListTile(
//                                       title: Row(
//                                           mainAxisAlignment:MainAxisAlignment.spaceEvenly,
//                                           children:[Text('${expense.name}',
//                                             style: TextStyle(
//                                               fontSize: 30,
//                                               fontWeight: FontWeight.w700,
//                                               fontFamily: 'Pacifico',
//                                               color: Colors.green,
//                                             ),
//                                           ),
//                                             Text('₹${expense.amount}',
//                                               style: TextStyle(
//                                                   fontSize: 30,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontFamily: 'Pacifico',
//                                                   color: Colors.red
//                                               ),
//                                             ),
//                                             GestureDetector(
//                                               onTap:() {
//                                                 removeexpense(index);
//
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     border: Border.all(width: 2)
//                                                 ),
//                                                 child:Icon(
//                                                   Icons.delete,
//                                                   color: Colors.black,
//                                                 ),),)
//                                           ])   )
//                               );
//                           }
//                           ,
//
//                         )),
//                   ]
//
//
//
//
//
//
//
//                 ],
//               ),
//             ))
