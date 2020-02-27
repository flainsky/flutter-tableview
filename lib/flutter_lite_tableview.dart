library flutter_lite_tableview;

import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

typedef int RowCountAtSection(int section);
typedef Widget ListViewFatherWidgetBuilder(
    BuildContext context, Widget canScrollWidget);
typedef Widget SectionHeaderBuilder(BuildContext context, int section);
typedef Widget CellBuilder(BuildContext context, int section, int row);
typedef double CellHeight(BuildContext context, int section, int row);
typedef double SectionHeaderHeight(BuildContext context, int section);

const String ErorrFlagBegin =
    '\n\n\n====================FlutterTableView  Error========================\n\n\n\n';

const String ErorrFlagEnd =
    '\n\n\n\n\n==================================================================\n\n\n\n.';

class IndexPath {
  final int section;
  final int row;
  IndexPath({this.section, this.row});
  @override
  String toString() {
    return 'section_${section}_row_$row';
  }

  @override
  int get hashCode => super.hashCode;
  @override
  bool operator ==(other) {
    if (other.runtimeType != IndexPath) {
      return false;
    }
    IndexPath otherIndexPath = other;
    return section == otherIndexPath.section && row == otherIndexPath.row;
  }
}

class LiteTableViewController extends ChangeNotifier{
  IndexPath topIndex = IndexPath(section: 0, row: -1);

  jump(int section, int row){
    topIndex = IndexPath(section: section, row: row);
    notifyListeners();
  }
}

class LiteTableView extends StatefulWidget{
  LiteTableView({
    @required this.sectionCount,
    @required this.rowCountAtSection,
    @required this.sectionHeaderBuilder,
    @required this.cellBuilder,
    @required this.sectionHeaderHeight,
    @required this.cellHeight,
    this.isSectionHeaderStay = true,
    this.listViewFatherWidgetBuilder,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.all(0.0),
    this.cacheExtent = 50.0,
    this.backgroundColor = Colors.transparent,
    this.liteTableViewController,
    this.initSection = 0,
    this.initRow = 0,
  })  : assert(
  (sectionCount != null),
  '$ErorrFlagBegin sectionCount must > 0 and could not be null. $ErorrFlagEnd',
  ),
        assert(
        (rowCountAtSection != null),
        '$ErorrFlagBegin function rowCountAtSection could not be null. $ErorrFlagEnd',
        ),
        assert(
        (sectionHeaderBuilder != null),
        '$ErorrFlagBegin function sectionHeaderBuilder could not be null. $ErorrFlagEnd',
        ),
        assert(
        (cellBuilder != null),
        '$ErorrFlagBegin function cellBuilder could not be null. $ErorrFlagEnd',
        ),
        assert(
        (sectionHeaderHeight != null),
        '$ErorrFlagBegin function sectionHeaderHeight could not be null. $ErorrFlagEnd',
        ),
        assert(
        (cellHeight != null),
        '$ErorrFlagBegin function cellHeight could not be null. $ErorrFlagEnd',
        );

  @override
  _LiteTableViewState createState() {
    return _LiteTableViewState();
  }

  /// How many section.
  final int sectionCount;

  /// How many item in each section.
  final RowCountAtSection rowCountAtSection;

  /// You can through sectionHeaderBuilder create section header widget.
  /// Each section has at most one headWidget.
  /// In a special section, if you don't need section header widget, you can return null.
  final SectionHeaderBuilder sectionHeaderBuilder;

  /// You can through cellBuilder create items.
  final CellBuilder cellBuilder;

  /// return each item widget height.
  final CellHeight cellHeight;

  /// return each section header widget height.
  final SectionHeaderHeight sectionHeaderHeight;

  /// You can wrap a widget for listView
  final ListViewFatherWidgetBuilder listViewFatherWidgetBuilder;

  /// see ScrollView controller
  final ScrollController controller;

  /// see ScrollView physics
  final ScrollPhysics physics;

  /// see ScrollView shrinkWrap
  final bool shrinkWrap;

  final EdgeInsetsGeometry padding;

  /// see ScrollView cacheExtent
  final double cacheExtent;

  final Color backgroundColor;

  /// is SectionHeader keep in top
  final bool isSectionHeaderStay;

  final LiteTableViewController liteTableViewController;

  ///初始位置 段落
  final int initSection;
  ///初始位置 行
  final int initRow;

}

class _LiteTableViewState extends State<LiteTableView> {
  ////////////////////////////////////////////////////////////////////
  //                          variables
  ////////////////////////////////////////////////////////////////////
  SectionHeaderModel currentHeaderModel;
  int totalItemCount = 0;
  List<SectionHeaderModel> sectionHeaderList = List();
  List<int> sectionTotalWidgetCountList = List();
  ScrollController scrollController;
  LiteTableViewController liteTableViewController;
  ListView listView;
  bool insideSetStateFlag = false;

  bool isJumping = false;
  List<double> sectionOffsetList = new List();
  List<List> rowOffsetList = new List();

  IndexPath topIndexPath;
  double _screenHeight;

  var scrollListener;
  var liteTableListener;

  bool isCellInScreen(IndexPath currentCell, IndexPath objCell) {
    if (currentCell == objCell) {
      return true;
    }
    else if (currentCell.section < objCell.section ||
        (currentCell.section == objCell.section &&
            currentCell.row < objCell.row)) {
      //之上
      double currentOff = getCellYOffset(currentCell, true);
      double objOff = getCellYOffset(objCell, false);
      if((objOff - currentOff) <= _screenHeight){
        return true;
      }
      else {
        return false;
      }
    }
    else {
      double objOff = getCellYOffset(objCell, true);
      double currentOff = getCellYOffset(currentCell, false);
      if((currentOff - objOff) <= _screenHeight){
        return true;
      }
      else {
        return false;
      }
    }
  }

  double getCellYOffset(IndexPath indexPath, bool isWithHeight){
    double y = 0.0;
    if(sectionOffsetList != null && indexPath.section < sectionOffsetList.length){
      y += sectionOffsetList[indexPath.section];
      if(rowOffsetList != null && indexPath.section < rowOffsetList.length){
        List<double> ll = rowOffsetList[indexPath.section];
        if(ll != null && indexPath.row < ll.length){
          y += ll[indexPath.row];
        }
      }
    }
    return y + (isWithHeight?widget.cellHeight(context,indexPath.section,indexPath.row):0.0);
  }

  bool isHeaderInScreen(int headerSection, IndexPath objCell) {
    if (headerSection == objCell.section) {
      return true;
    }
    else if (headerSection < objCell.section) {
      //之上
      double currentOff = getHeaderYOffset(headerSection, true);
      double objOff = getCellYOffset(objCell, false);
      if((objOff - currentOff) <= _screenHeight){
        return true;
      }
      else {
        return false;
      }
    }
    else {
      double objOff = getCellYOffset(objCell, true);
      double currentOff = getHeaderYOffset(headerSection, false);
      if((currentOff - objOff) <= _screenHeight){
        return true;
      }
      else {
        return false;
      }
    }
  }

  double getHeaderYOffset(int section, bool isWithHeight){
    double y = 0.0;
    //找上一个CELL
    if(section == 0){
      return 0.0 + (isWithHeight?widget.sectionHeaderHeight(context,section):0.0);
    }
    else {
      int cellCount = widget.rowCountAtSection(section - 1);
      if(cellCount == 0){
        return getHeaderYOffset(section - 1, true) + (isWithHeight?widget.sectionHeaderHeight(context,section):0.0);
      }
      else{
        return getCellYOffset(IndexPath(section: section - 1,row: cellCount - 1), true) + (isWithHeight?widget.sectionHeaderHeight(context,section):0.0);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////
  //                         init function
  ////////////////////////////////////////////////////////////////////
  void _initBaseData() {
    this.totalItemCount = 0;
    this.sectionHeaderList.clear();
    this.sectionTotalWidgetCountList.clear();

    double offsetY = 0;
    for (int section = 0; section < widget.sectionCount; section++) {
      int rowCount = widget.rowCountAtSection(section);
      Widget sectionHeader = widget.sectionHeaderBuilder(context, section);
      double sectionHeight;
      if (sectionHeader != null) {
        sectionHeight = this.widget.sectionHeaderHeight(context, section);
      } else {
        sectionHeight = 0;
      }

      double sectionHeaderY = offsetY;

      offsetY += sectionHeight;

      int sectionWidgetCount = sectionHeader == null ? rowCount : rowCount + 1;
      sectionTotalWidgetCountList.add(sectionWidgetCount);
      this.totalItemCount += sectionWidgetCount;

      for (int row = 0; row < rowCount; row++) {
        offsetY += this.widget.cellHeight(context, section, row);
      }

      SectionHeaderModel model = SectionHeaderModel(
        y: sectionHeaderY,
        sectionMaxY: offsetY,
        height: sectionHeight,
        section: section,
        headerWidget: sectionHeader,
      );
      sectionHeaderList.add(model);
    }
  }

  void makeHeightIndex(){
    double tmpOffset = 0;
    for(int i = 0 ;i < widget.sectionCount ;i++){
      List<double> rowList = new List();
      sectionOffsetList.add(tmpOffset.toDouble());    //如果不toDouble 会不会加的都是一个。。。
      tmpOffset += widget.sectionHeaderHeight(context,i);
      int rowCount = widget.rowCountAtSection(i);
      for(int j = 0; j < rowCount; j++){
        rowList.add(tmpOffset.toDouble());
        tmpOffset += widget.cellHeight(context, i, j);
      }
      rowOffsetList.add(rowList);
    }
  }

  void _initScrollController() {
    _screenHeight = window.physicalSize.height;

    makeHeightIndex();

    this.scrollController = this.widget.controller;
    if (this.scrollController == null) {

      double jumpOffset = 0.0;
      if(widget.initSection != 0 || widget.initRow != 0){
        topIndexPath = new IndexPath(section: widget.initSection,row: widget.initRow);
        isJumping = true;
        jumpOffset = rowOffsetList[widget.initSection][widget.initRow];

      }

      this.scrollController = ScrollController(initialScrollOffset: jumpOffset);
    }

    this.liteTableViewController = this.widget.liteTableViewController;
    if(this.liteTableViewController == null){
      this.liteTableViewController = LiteTableViewController();
    }

    if(this.scrollController.hasListeners){
      this.scrollController.removeListener(scrollListener);
    }

    this.scrollController.addListener(scrollListener);

    if(scrollController != null){
      if(liteTableViewController != null){
        if(liteTableViewController.hasListeners){
          liteTableViewController.removeListener(liteTableListener);
        }
        liteTableViewController.addListener(liteTableListener);
      }
    }

  }

  void jump(int section, int row){
    topIndexPath = new IndexPath(section: section,row: row);
    isJumping = true;
    double jumpOffset = sectionOffsetList[section];
    jumpOffset += rowOffsetList[section][row];
    jumpOffset += widget.sectionHeaderHeight(context, section);

    scrollController.jumpTo(jumpOffset);
  }

  ////////////////////////////////////////////////////////////////////
  //                       create listView
  ////////////////////////////////////////////////////////////////////
  void _createListView() {
    if (this.insideSetStateFlag == false) {
      this._initBaseData();
    }

    this.insideSetStateFlag = false;

    this.listView = ListView.builder(
      controller: this.scrollController,
      physics: this.widget.physics ?? AlwaysScrollableScrollPhysics(),
      shrinkWrap: this.widget.shrinkWrap,
      cacheExtent: this.widget.cacheExtent,
      itemBuilder: (BuildContext context, int index) {
        Widget itemWidget;
        RowSectionModel model = this._getRowSectionModel(index);
        double height;
        if (model.row == 0 && model.haveHeaderWidget) {
          height = this.widget.sectionHeaderHeight(context, model.section);
          if(isJumping && topIndexPath != null && !isHeaderInScreen(model.section, topIndexPath)){
            itemWidget = Container(height: height);
          }
          else {
            IndexPath ip = IndexPath(section: model.section,row: -1);
            isJumping = false;
            itemWidget = this.sectionHeaderList[model.section].headerWidget;
          }

        } else {
          int row = model.haveHeaderWidget == false ? model.row : model.row - 1;
          height = this.widget.cellHeight(context, model.section, row);
          if(isJumping && topIndexPath != null && !isCellInScreen(IndexPath(section: model.section, row: row),topIndexPath)){
            itemWidget = Container(height: height,);
          }
          else{
            IndexPath ip = IndexPath(section: model.section,row: row);
            isJumping = false;
            itemWidget = this.widget.cellBuilder(context, model.section, row);
          }
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            maxHeight: height,
          ),
          child: itemWidget,
        );
      },
      itemCount: this.totalItemCount,
    );
  }

  ////////////////////////////////////////////////////////////////////
  //                      tool function
  ////////////////////////////////////////////////////////////////////
  RowSectionModel _getRowSectionModel(int index) {
    int passCount = 0;
    for (int section = 0;
    section < this.sectionTotalWidgetCountList.length;
    section++) {
      int currentSectionWidgetCount = this.sectionTotalWidgetCountList[section];
      if (index >= passCount && index < passCount + currentSectionWidgetCount) {
        int row = index - passCount;
        bool haveSectionHeaderWidget =
            this.sectionHeaderList[section].headerWidget != null;
        RowSectionModel model = RowSectionModel(
          section: section,
          row: row,
          haveHeaderWidget: haveSectionHeaderWidget,
        );

        return model;
      }

      passCount += currentSectionWidgetCount;
    }
    return null;
  }

  void _updateCurrentSectionHeaderModel(
      SectionHeaderModel model, double topOffset) {
    bool needSetState = false;
    if (model == null) {
      if (this.currentHeaderModel != null) {
        this.currentHeaderModel = null;
        needSetState = true;
      }
    } else if (this.currentHeaderModel == null) {
      this.currentHeaderModel = model;
      this.currentHeaderModel.topOffset = topOffset;
      needSetState = true;
    } else {
      if (model != this.currentHeaderModel) {
        this.currentHeaderModel = model;

        needSetState = true;
      } else if (model.topOffset != topOffset) {
        needSetState = true;
      }

      this.currentHeaderModel.topOffset = topOffset;
    }

    if (needSetState == true) {
      this.insideSetStateFlag = true;
      setState(() {});
    }
  }

  ////////////////////////////////////////////////////////////////////
  //                          life cycle
  ////////////////////////////////////////////////////////////////////

  @override
  void dispose() {
    super.dispose();

    if(this.scrollController != null && scrollListener != null){
      this.scrollController.removeListener(scrollListener);
    }
  }

  @override
  void initState() {
    super.initState();

    scrollListener = () {
      double offsetY = this.scrollController.offset;

      if (offsetY <= 0.0) {
        this._updateCurrentSectionHeaderModel(null, 0);
      } else {
        int section = 0;
        for (int i = 0; i < this.sectionHeaderList.length; i++) {
          SectionHeaderModel model = this.sectionHeaderList[i];
          if (offsetY >= model.y && offsetY <= model.sectionMaxY) {
            section = i;
            break;
          }
        }

        SectionHeaderModel model = this.sectionHeaderList[section];
        double delta = model.sectionMaxY - this.scrollController.offset;
        double topOffset;
        if (delta >= model.height) {
          topOffset = 0.0;
        } else {
          topOffset = delta - model.height;
        }
        this._updateCurrentSectionHeaderModel(model, topOffset);
      }
    };

    liteTableListener = (){
      int section = liteTableViewController.topIndex.section;
      int row = liteTableViewController.topIndex.row;
      topIndexPath = new IndexPath(section: section,row: row);
      isJumping = true;
      double jumpOffset = rowOffsetList[section][row];
      jumpOffset -= widget.sectionHeaderHeight(context,section);
      scrollController.jumpTo(jumpOffset);
    };
  }

  @override
  Widget build(BuildContext context) {

    _initScrollController();
    makeHeightIndex();
    this._createListView();

    Widget listViewFatherWidget;
    if (this.widget.listViewFatherWidgetBuilder != null) {
      listViewFatherWidget =
          this.widget.listViewFatherWidgetBuilder(context, this.listView);
    }

    Widget listViewWidget = listViewFatherWidget ?? this.listView;

    if (this.currentHeaderModel != null &&
        this.currentHeaderModel.headerWidget != null &&
        this.widget.isSectionHeaderStay) {
      return Container(
        padding: this.widget.padding,
        color: widget.backgroundColor,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              child: listViewWidget,
            ),
            Positioned(
              top: this.currentHeaderModel.topOffset,
              left: 0.0,
              right: 0.0,
              height: this.currentHeaderModel.height,
              child: Container(
                color: Colors.white,
                child: this.currentHeaderModel.headerWidget,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: this.widget.padding,
      color: this.widget.backgroundColor,
      child: Stack(
        children: [
          Container(
            color: Colors.transparent,
            child: listViewWidget,
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////
//                          model class
////////////////////////////////////////////////////////////////////

class RowSectionModel {
  RowSectionModel({
    @required this.section,
    @required this.row,
    @required this.haveHeaderWidget,
  });

  final int section;
  final int row;
  final bool haveHeaderWidget;
}

class SectionHeaderModel {
  SectionHeaderModel({
    this.y,
    this.sectionMaxY,
    this.height,
    this.section,
    this.headerWidget,
  });

  final double y;
  final double sectionMaxY;
  final double height;
  final int section;
  final Widget headerWidget;

  double topOffset;
}
