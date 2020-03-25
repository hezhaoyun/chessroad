import 'package:flutter/material.dart';
import '../services/player.dart';
import '../services/ranks.dart';
import '../common/color-consts.dart';
import '../main.dart';
import 'settings-page.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  //
  bool _loading = false;
  String _status = '';

  int _pageIndex = 1;
  final List<RankItem> _items = [];

  final _scrollController = ScrollController();

  @override
  void initState() {
    //
    super.initState();

    _status = '全网排名';

    _scrollController.addListener(() {
      final pos = _scrollController.position;
      if (pos.pixels > pos.maxScrollExtent) loadMore();
    });

    refresh();
  }

  Future<void> refresh() async {
    //
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    _items.clear();

    List<RankItem> loaded = [];

    loaded = await queryRankItems();

    if (mounted) {
      setState(() {
        if (loaded != null) _items.addAll(loaded);
        _loading = false;
      });
    }
  }

  loadMore() async {
    //
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    final loaded = await queryRankItems(pageIndex: ++_pageIndex);

    if (loaded == null || loaded.isEmpty) {
      _pageIndex--; // 没有下一页了
    }

    if (mounted) {
      setState(() {
        _items.addAll(loaded);
        _loading = false;
      });
    }
  }

  queryRankItems({pageIndex = 1, pageSize = 10}) async {
    this._pageIndex = pageIndex;
    return await Ranks.mockLoad(pageIndex: pageIndex);
  }

  showRankDetail(int index) {
    //
    final rank = index >= 0 ? _items[index] : Player.shared;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(rank.name, style: TextStyle(color: ColorConsts.Primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5),
            Text('分数：${rank.score}'),
            SizedBox(height: 5),
            Text('姓名：${rank.name}'),
            SizedBox(height: 5),
            Text('战胜云库：${rank.winCloudEngine}'),
            SizedBox(height: 5),
            Text('战胜手机：${rank.winPhoneAi}'),
          ],
        ),
        actions: <Widget>[
          FlatButton(child: Text('好的'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  showPointRules() {
    //
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('计分规则'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('战胜云库：+ 30分'),
            SizedBox(height: 5),
            Text('战胜手机：+ 5分'),
            SizedBox(height: 5),
          ],
        ),
        actions: <Widget>[
          FlatButton(child: Text('好的'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget createPageHeader() {
    //
    final titleStyle = TextStyle(fontSize: 28, color: ColorConsts.DarkTextPrimary);
    final subTitleStyle = TextStyle(fontSize: 16, color: ColorConsts.DarkTextSecondary);

    return Container(
      margin: EdgeInsets.only(top: ChessRoadApp.StatusBarHeight),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: ColorConsts.DarkTextPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(child: SizedBox()),
              Hero(tag: 'logo', child: Image.asset('images/logo-mini.png')),
              SizedBox(width: 10),
              Text('排行榜', style: titleStyle),
              Expanded(child: SizedBox()),
              IconButton(
                icon: Icon(Icons.settings, color: ColorConsts.DarkTextPrimary),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                ),
              ),
            ],
          ),
          Container(
            height: 4,
            width: 180,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: ColorConsts.BoardBackground,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(_status, maxLines: 1, style: subTitleStyle),
          ),
        ],
      ),
    );
  }

  buildTile(int index) {
    //
    if (index == _items.length) {
      //
      if (_items.length == 0 && !_loading) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('<无数据>', style: TextStyle(fontSize: 16, color: Colors.black38)),
          ),
        );
      }

      return _loading ? loadingWidget : SizedBox();
    }

    return ListTile(
      leading: Icon(Icons.person_pin, color: ColorConsts.Secondary),
      title: Text(
        _items[index].name,
        style: TextStyle(color: ColorConsts.Primary, fontSize: 16, fontFamily: ''),
      ),
      subtitle: Text(
        '${_items[index].score}分',
        style: TextStyle(color: ColorConsts.Secondary, fontSize: 14, fontFamily: ''),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(
          '#${index + 1}',
          style: TextStyle(
            fontFamily: '',
            fontSize: 14,
            color: index < 3 ? ColorConsts.Primary : Colors.black38,
          ),
        ),
        Icon(Icons.keyboard_arrow_right, color: ColorConsts.Secondary),
      ]),
      onTap: () => showRankDetail(index),
    );
  }

  get loadingWidget {
    //
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator(strokeWidth: 1.0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    final tileTitleStyle = TextStyle(color: ColorConsts.Primary, fontSize: 18);
    final fuctionBar = Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: ColorConsts.BoardBackground),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('${Player.shared.name}(我)', style: tileTitleStyle),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('${Player.shared.score}分'),
                Icon(Icons.keyboard_arrow_right, color: ColorConsts.Secondary),
              ],
            ),
            onTap: () => showRankDetail(-1),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            height: 1.0,
            color: ColorConsts.Secondary,
          ),
          ListTile(
            title: Text("计分规则", style: tileTitleStyle),
            trailing: Icon(Icons.keyboard_arrow_right, color: ColorConsts.Secondary),
            onTap: showPointRules,
          ),
        ],
      ),
    );

    final list = Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 32),
      padding: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: ColorConsts.BoardBackground),
      child: RefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _items.length + 1,
          itemBuilder: (context, index) => buildTile(index),
        ),
        onRefresh: refresh,
      ),
    );

    final header = createPageHeader();

    return Scaffold(
      backgroundColor: ColorConsts.DarkBackground,
      body: Column(children: <Widget>[
        header,
        fuctionBar,
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: list)),
      ]),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
