import 'package:flutter/material.dart';
import 'package:flutter_admin/data/data1.dart';
import 'package:flutter_admin/utils/globalUtil.dart';
import 'package:flutter_admin/vo/pageVO.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class Layout1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Layout1State();
}

class Layout1State extends State with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();
  List<PageVO> pageVoAll;
  List<PageVO> pageVoOpened;
  TabController tabController;
  Container content;
  int length;
  bool expandMenu = true;
  List<bool> isSelected = [true, false, false];
  @override
  void initState() {
    super.initState();
    pageVoAll = testPageVOAll;
    pageVoOpened = <PageVO>[pageVoAll[0]];
    length = pageVoOpened.length;
    tabController = TabController(vsync: this, length: length);
    if (pageVoOpened.length > 0) {
      loadPage(pageVoOpened[0]);
    }
    WidgetsBinding.instance.addPostFrameCallback((v) {
      scaffoldStateKey.currentState.openEndDrawer();
    });
  }

  loadPage(page) {
    content = Container(
      child: Expanded(
        child: page.widget != null ? page.widget : Center(child: Text('404')),
      ),
    );
    int index = pageVoOpened.indexWhere((note) => note.id == page.id);
    if (index > -1) {
      tabController.index = index;
    } else {
      pageVoOpened.add(page);
      tabController = TabController(vsync: this, length: ++length);
      tabController.index = length - 1;
    }
    setState(() {});
  }

  List<Widget> genListTile(data) {
    List<Widget> listTileList = data.map<Widget>((PageVO page) {
      Text title = Text(expandMenu ? page.title : '');
      if (page.children != null && page.children.length > 0) {
        return ExpansionTile(
          leading: Icon(expandMenu ? page.icon : null),
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
          children: genListTile(page.children),
          title: title,
        );
      } else {
        return ListTile(
          leading: Icon(page.icon),
          title: title,
          onTap: () => loadPage(page),
        );
      }
    }).toList();
    return listTileList;
  }

  @override
  Widget build(BuildContext context) {
    ListTile menuHeader = ListTile(
      title: Icon(Icons.menu),
      onTap: () {
        expandMenu = !expandMenu;
        setState(() {});
      },
    );
    List<Widget> menuBody = genListTile(pageVoAll);
    ListView menu = ListView(children: [menuHeader, ...menuBody]);
    TabBar tabBar = TabBar(
      onTap: (index) => loadPage(pageVoOpened[index]),
      controller: tabController,
      isScrollable: true,
      indicator: getIndicator(),
      tabs: pageVoOpened.map<Tab>((PageVO page) {
        return Tab(
          text: page.title,
        );
      }).toList(),
    );

    Row body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: expandMenu ? 300 : 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              // border: Border(right: BorderSide(color: Colors.black)),
            ),
            child: menu,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: tabBar,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content,
            ],
          ),
        ),
      ],
    );
    Scaffold subWidget = Scaffold(
      key: scaffoldStateKey,
      // endDrawer: getDrawer(),
      body: body,
      appBar: AppBar(
        title: Text("FLUTTER_ADMIN"),
        actions: <Widget>[
          OutlineButton.icon(
            label: Text("退出"),
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          scaffoldStateKey.currentState.openEndDrawer();
        },
      ),
    );
    return subWidget;
  }

  getToggleButton() {
    return ToggleButtons(
      children: <Widget>[
        Icon(Icons.cake),
        Icon(Icons.cake),
        Icon(Icons.cake),
      ],
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
            if (buttonIndex == index) {
              isSelected[buttonIndex] = true;
            } else {
              isSelected[buttonIndex] = false;
            }
          }
        });
      },
      isSelected: isSelected,
    );
  }

  getDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('我的'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: getToggleButton(),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {},
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  logout() {
    GlobalUtil.token = null;
    Navigator.of(context, rootNavigator: true).pop();
  }

  getIndicator() {
    return const UnderlineTabIndicator();
  }
}
