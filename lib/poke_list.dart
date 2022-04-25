import 'package:flutter/material.dart';
import 'package:pokepoke/const/pokeapi.dart';
import 'package:pokepoke/models/favorite.dart';
import 'package:pokepoke/models/pokemon.dart';
import 'package:pokepoke/poke_list_item.dart';
import 'package:provider/provider.dart';

class PokeList extends StatefulWidget {
  const PokeList({Key? key}) : super(key: key);

  @override
  _PokeListState createState() => _PokeListState();
}

class _PokeListState extends State<PokeList> {
  static const int pageSize = 30;
  bool isFavoriteMode = false;
  int _currentPage = 1;

  int itemCount(int favsCount, int page, int inputPageSize, int maxId,
      bool favoriteMode) {
    int ret = page * inputPageSize;
    if (favoriteMode && ret > favsCount) {
      ret = favsCount;
    }
    if (ret > maxId) {
      ret = maxId;
    }
    return ret;
  }

  int itemId(List<Favorite> favs, int index, bool favoriteMode) {
    int ret = index + 1;
    if (favoriteMode) {
      ret = favs[index].pokeId;
    }
    return ret;
  }

  bool isLastPage(int favsCount, int page, int inputPageSize, int maxId,
      bool favoriteMode) {
    if (favoriteMode) {
      if (page * inputPageSize < favsCount) {
        return false;
      }
      return true;
    } else {
      if (page * inputPageSize < maxId) {
        return false;
      }
      return true;
    }
  }

  void changeMode(bool fav) {
    setState(() {
      isFavoriteMode = !fav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesNotifier>(
      builder: (context, favs, child) => Column(
        children: [
          Container(
            height: 24,
            alignment: Alignment.topRight,
            child: IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(Icons.auto_awesome_outlined),
              onPressed: () async {
                // 非同期関数にデータの型を指定すると終了時に型の値を受け取れる
                var ret = await showModalBottomSheet<bool>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return ViewModeBottomSheet(
                      favMode: isFavoriteMode,
                    );
                  },
                );
                if (ret != null && ret) {
                  print(ret);
                  changeMode(isFavoriteMode);
                }
              },
            ),
          ),
          Expanded(child: Consumer<PokemonsNotifer>(
            builder: (context, pokes, child) {
              if (itemCount(
                    favs.favs.length,
                    _currentPage,
                    pageSize,
                    pokeMaxId,
                    isFavoriteMode,
                  ) ==
                  0) {
                return const Text('no data');
              } else {
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  itemCount: itemCount(
                        favs.favs.length,
                        _currentPage,
                        pageSize,
                        pokeMaxId,
                        isFavoriteMode,
                      ) +
                      1,
                  itemBuilder: (context, index) {
                    if (index ==
                        itemCount(
                          favs.favs.length,
                          _currentPage,
                          pageSize,
                          pokeMaxId,
                          isFavoriteMode,
                        )) {
                      return OutlinedButton(
                        child: const Text('more'),
                        onPressed: isLastPage(
                          favs.favs.length,
                          _currentPage,
                          pageSize,
                          pokeMaxId,
                          isFavoriteMode,
                        )
                            ? null
                            : () => {
                                  setState(() {
                                    _currentPage++;
                                  })
                                },
                      );
                    } else {
                      return PokeListItem(
                        poke: pokes
                            .byId(itemId(favs.favs, index, isFavoriteMode)),
                      );
                    }
                  },
                );
              }
            },
          )),
        ],
      ),
    );
  }
}

class ViewModeBottomSheet extends StatelessWidget {
  const ViewModeBottomSheet({Key? key, required this.favMode})
      : super(key: key);

  final bool favMode;

  String mainText(bool fav) {
    if (fav) {
      return "お気に入りのポケモンが表示されています";
    } else {
      return 'すべてのポケモンが表示されています';
    }
  }

  String menuTitle(bool fav) {
    if (fav) {
      return '「すべて」表示に切り替え';
    } else {
      return '「お気に入り」表示に切り替え';
    }
  }

  String menuSubTitle(bool fav) {
    if (fav) {
      return 'すべてのポケモンが表示されます';
    } else {
      return 'お気に入りに登録したポケモンのみが表示されます';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 5,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).backgroundColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                mainText(favMode),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(
                menuTitle(favMode),
              ),
              subtitle: Text(
                menuSubTitle(favMode),
              ),
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              child: const Text('キャンセル'),
              onPressed: () => Navigator.pop(context, false),
            )
          ],
        ),
      ),
    );
  }
}
