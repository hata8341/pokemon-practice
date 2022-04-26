import 'package:flutter/material.dart';
import 'package:pokepoke/const/pokeapi.dart';
import 'package:pokepoke/models/favorite.dart';
import 'package:pokepoke/models/pokemon.dart';
import 'package:pokepoke/poke_grid_item.dart';
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
  bool isGridMode = true;

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

  void changeFavMode(bool fav) {
    setState(() {
      isFavoriteMode = !fav;
    });
  }

  void changeDisplayMode(bool mode) {
    setState(() {
      isGridMode = !mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesNotifier>(
      builder: (context, favs, child) => Column(
        children: [
          TopHeadMenu(
              isFavoriteMode: isFavoriteMode,
              changeFavMode: changeFavMode,
              isGridMode: isGridMode,
              changeGridMode: changeDisplayMode),
          Expanded(child:
              Consumer<PokemonsNotifer>(builder: (context, pokes, child) {
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
              if (isGridMode) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
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
                        itemCount(favs.favs.length, _currentPage, pageSize,
                            pokeMaxId, isFavoriteMode)) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton(
                          child: const Text('more'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: isLastPage(
                            favs.favs.length,
                            _currentPage,
                            pageSize,
                            pokeMaxId,
                            isFavoriteMode,
                          )
                              ? null
                              : () => {
                                    setState(() => _currentPage++),
                                  },
                        ),
                      );
                    } else {
                      return PokeGridItem(
                          poke: pokes
                              .byId(itemId(favs.favs, index, isFavoriteMode)));
                    }
                  },
                );
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
            }
          })),
        ],
      ),
    );
  }
}

class TopHeadMenu extends StatelessWidget {
  const TopHeadMenu({
    Key? key,
    required this.isFavoriteMode,
    required this.changeFavMode,
    required this.isGridMode,
    required this.changeGridMode,
  }) : super(key: key);

  final bool isFavoriteMode;
  final Function(bool) changeFavMode;
  final bool isGridMode;
  final Function(bool) changeGridMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.topRight,
      child: IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(Icons.auto_awesome_outlined),
        onPressed: () async {
          await showModalBottomSheet(
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
                  changeFavMode: changeFavMode,
                  gridMode: isGridMode,
                  changeGridMode: changeGridMode,
                );
              });
        },
      ),
    );
  }
}

class ViewModeBottomSheet extends StatelessWidget {
  const ViewModeBottomSheet({
    Key? key,
    required this.favMode,
    required this.changeFavMode,
    required this.gridMode,
    required this.changeGridMode,
  }) : super(key: key);

  final bool favMode;
  final Function(bool) changeFavMode;
  final bool gridMode;
  final Function(bool) changeGridMode;

  String mainFavText(bool fav) {
    if (fav) {
      return "お気に入りのポケモンが表示されています";
    } else {
      return 'すべてのポケモンが表示されています';
    }
  }

  String menuFavTitle(bool fav) {
    if (fav) {
      return '「すべて」表示に切り替え';
    } else {
      return '「お気に入り」表示に切り替え';
    }
  }

  String menuFavSubTitle(bool fav) {
    if (fav) {
      return 'すべてのポケモンが表示されます';
    } else {
      return 'お気に入りに登録したポケモンのみが表示されます';
    }
  }

  String menuGridTitle(bool grid) {
    if (grid) {
      return 'リスト表示へ切り替え';
    } else {
      return 'グリッド表示へ切り替え';
    }
  }

  String menuGridSubTitle(bool grid) {
    if (grid) {
      return 'ポケモンをグリッド表示します';
    } else {
      return 'ポケモンをリスト表示します';
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                '表示設定',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(
                menuFavTitle(favMode),
              ),
              subtitle: Text(
                menuFavSubTitle(favMode),
              ),
              onTap: () {
                changeFavMode(favMode);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_3x3),
              title: Text(
                menuGridTitle(gridMode),
              ),
              subtitle: Text(
                menuGridSubTitle(gridMode),
              ),
              onTap: () {
                changeGridMode(gridMode);
                Navigator.pop(context);
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

// class PokeGridItem extends StatelessWidget {
//   const PokeGridItem({Key? key, required this.poke}) : super(key: key);

//   final Pokemon? poke;

//   @override
//   Widget build(BuildContext context) {
//     if (poke != null) {
//       return Column(
//         children: [
//           InkWell(
//             onTap: () => {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (BuildContext context) => PokeDetail(poke: poke!),
//                 ),
//               ),
//             },
//             child: Hero(
//               tag: poke!.name,
//               child: Container(
//                 height: 100,
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: (pokeTypeColors[poke!.types.first] ?? Colors.grey[100])
//                       ?.withOpacity(.3),
//                   borderRadius: BorderRadius.circular(10),
//                   image: DecorationImage(
//                     fit: BoxFit.fitWidth,
//                     image: CachedNetworkImageProvider(
//                       poke!.imageUrl,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Text(
//             poke!.name,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           )
//         ],
//       );
//     } else {
//       return const SizedBox(
//         height: 100,
//         width: 100,
//         child: Center(
//           child: Text('...'),
//         ),
//       );
//     }
//   }
// }
