import 'package:flutter/material.dart';
import 'package:flutter_lite_tableview/flutter_lite_tableview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Lite Table Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Lite Table Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    List<String> sectionList = new List();
    for(int i = 0;i<100;i++){
      sectionList.add('section ' + i.toString());
    }
    List<String> itemList = new List();
    for(int i = 0;i<20;i++){
      itemList.add('item ' + i.toString());
    }

    LiteTableViewController _liteTableViewController = new LiteTableViewController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 500,
            child: LiteTableView(
              liteTableViewController: _liteTableViewController,  //控制器
              isSectionHeaderStay: true,                          //保留section header
              sectionCount: sectionList.length,
              rowCountAtSection: ((int section){
                return itemList.length;
              }),
              sectionHeaderHeight:(BuildContext context, int section) => 44,
              cellHeight: (BuildContext context, int section, int row) => 20,
              sectionHeaderBuilder: ((BuildContext context, int section) {
                return Container(
                  color: Color.fromARGB(100, 255, 0, 0),
                  alignment: Alignment.center,
                  child: Text(sectionList[section],
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }),
              cellBuilder: ((BuildContext context, int section, int row){
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(itemList[row],
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                );
              }),

            ),
          ),
          Expanded(
            child: Wrap(
              children: <Widget>[
                FlatButton(
                  color: Colors.orange,
                  child: Text('jump to section 50 row 0'),
                  onPressed: ((){
                    _liteTableViewController.jump(50, 0);
                  }),
                ),
                FlatButton(
                  color: Colors.orange,
                  child: Text('jump to section 50 row 1'),
                  onPressed: ((){
                    _liteTableViewController.jump(50, 1);
                  }),
                ),
                FlatButton(
                  color: Colors.orange,
                  child: Text('jump to section 50 row 5'),
                  onPressed: ((){
                    _liteTableViewController.jump(50, 5);
                  }),
                ),
                FlatButton(
                  color: Colors.orange,
                  child: Text('jump to section 50 row 10'),
                  onPressed: ((){
                    _liteTableViewController.jump(50, 10);
                  }),
                )
              ],
            ),
          )
        ],
      )
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
