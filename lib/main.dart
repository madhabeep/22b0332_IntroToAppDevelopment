//import 'dart:js_interop';

import 'package:flutter/material.dart';

void main() => runApp(budgeTrackerapp());

class budgeTrackerapp extends StatelessWidget{
  const budgeTrackerapp({super.key});
  @override
  Widget build(BuildContext context) {
    return(MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: homepage(),
    ));
  }
}
class Expense {
  final int amount;
  final String name;
  Expense({required this.amount,required this.name});
}
class homepage extends StatefulWidget{
  @override
  homepageState createState() => homepageState();
}
class homepageState extends State<homepage>{
  int totalbudget=1000;
  List<Expense> expenses=[];
  bool showexpense=false;

  final TextEditingController nameController=TextEditingController();
  final TextEditingController amountController=TextEditingController();
  @override
  void dispose(){
    nameController.dispose();
    amountController.dispose();
    super.dispose();}
  void addexpense(String name,int amount){
    if(name.isNotEmpty && amount!=null){
      final Expense newExpense=Expense(amount: -amount, name: name);
      setState(() {
        expenses.add(newExpense);
        totalbudget-=amount;
      });
    }

  }
  void removeexpense(int index){
    setState(() {
      final removedExpense=expenses.removeAt(index);
      totalbudget-=removedExpense.amount;
    });
  }
  void showAddExpenseDialog(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
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
                      labelText:'Category',
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
                  SizedBox(height:15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed:(){
                            Navigator.of(context).pop();
                          } ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red
                          ),
                          child: Container(
                            child: Text('Cancel'),
                          )),
                      ElevatedButton(
                          onPressed: (){
                            final String name=nameController.text;
                            final int amount=int.tryParse(amountController.text)??0;
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


          );}
    );
  }
  Widget build(BuildContext context) {

    return
      Scaffold(
        appBar: AppBar(
          title: Text('Budget Tracker',
            style: TextStyle(
              fontSize: 40,

            ),
            textAlign: TextAlign.center,),
        ),
        body: 
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image:AssetImage('images/page.jpg'),
                fit:BoxFit.cover,)
          ),
            child:Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 90),
              Container
                (child:Align(
                alignment: Alignment(0,-0.3),
                child:Text('Welcome back!',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Pangolin',


                  ),),
              )),
              SizedBox(height: 35,),
              GestureDetector(
                onTap:(){
                  setState(() {
                    showexpense=!showexpense;
                  });
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
                          color:Colors.grey.withOpacity(0.5)
                      )],
                      gradient: LinearGradient(
                        colors: [Colors.orange,Colors.deepOrange],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(child:Text('Total : ₹${totalbudget}',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'VT323',
                        fontWeight: FontWeight.bold,
                      ),),

                    )),
              ),
              if (showexpense)...[
                SizedBox(height:15),
                Text('Expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Colors.deepPurple[900],
                    fontFamily: 'Lugrasimo',

                  ),),
                Expanded(
                    child:ListView.builder(
                      shrinkWrap: true,
                      itemCount: expenses.length,
                      itemBuilder: (context,index){
                        final expense=expenses[index];
                        return
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 5,horizontal: 50),
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20),
                                color: Colors.transparent,
                                //gradient: LinearGradient(
                                  //colors: [Colors.purple,Colors.deepPurple],
                                  //begin: Alignment.topCenter,
                                  //end: Alignment.bottomCenter,
                                //)

                            ),
                            child:ListTile(
                                title: Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                    children:[Text('${expense.name}',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Pacifico',
                                        color: Colors.green,
                                      ),
                                    ),
                                      Text('₹${expense.amount}',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Pacifico',
                                          color: Colors.red
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:() {
                                          removeexpense(index);

                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(width: 2)
                                          ),
                                          child:Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),),)
                                    ])   )
                        );
                      }
                      ,

                    )),
              ]







            ],
          ),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showAddExpenseDialog(context);
          },
          child: Icon(Icons.add),
        ),
      );



  }




}
