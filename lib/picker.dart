import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'area.dart';
import 'city.dart';
import 'model.dart';
import 'province.dart';
import 'street.dart';

const _kSmallDuration = Duration(milliseconds: 100);
const _kDuration = Duration(milliseconds: 200);

/// 省、市、区、街道 选择器
class AddressPicker extends StatefulWidget {
  final Province? province;
  final City? city;
  final Area? area;
  final Street? street;
  final WidgetBuilder? loadingBuilder;
  final String title;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;
  final BorderRadius? borderRadius;
  final Function(Province? province, City? city, Area? area, Street? street)?
      onConfirm;

  const AddressPicker({
    Key? key,
    this.onConfirm,
    this.province,
    this.city,
    this.area,
    this.street,
    this.loadingBuilder,
    this.borderRadius,
    this.title = '选择地区',
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  ///
  bool isLoading = true;
  bool showProvince = false,
      showCity = false,
      showArea = false,
      showStreet = false;

  var tabIndex = 0;

  List<Province>? provinces;
  List<City>? cities;
  List<Area>? areas;
  List<Street>? streets;

  Province? _province;
  City? _city;
  Area? _area;
  Street? _street;

  int initialIndexP = 0;
  int initialIndexC = 0;
  int initialIndexA = 0;
  int initialIndexS = 0;

  ///
  final provinceController = ItemScrollController();
  final cityController = ItemScrollController();
  final areaController = ItemScrollController();
  final streetController = ItemScrollController();
  final selectionController = ScrollController();

  /// 是否显示预设地址
  bool get isFindIndex => _province != null && _city != null && _area != null;

  /// 将地址信息返回
  void _onConfirm() async {
    Navigator.pop(context);
    widget.onConfirm?.call(_province, _city, _area, _street);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    selectionController.dispose();
  }

  /// 初始化时获取省份
  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _province = widget.province;
    _city = widget.city;
    _area = widget.area;
    _street = widget.street;

    // 省
    provinces = provinces ?? await loadProvinces();
    showProvince = provinces?.isNotEmpty ?? false;

    if (isFindIndex) {
      var pIndex = provinces?.indexWhere((e) => e.id == _province?.id) ?? -1;
      if (pIndex != -1) {
        initialIndexP = pIndex;
      }

      // 市
      var cities = await loadCities(_province!.id);
      var cIndex = cities?.indexWhere((e) => e.id == _city?.id) ?? -1;
      if (cIndex != -1) {
        this.cities = cities;
        initialIndexC = cIndex;
      }

      // 街道
      var streets = await loadStreets(_area?.id ?? '');
      var sIndex = streets?.indexWhere((e) => e.id == _street?.id) ?? -1;
      if (sIndex != -1) {
        this.streets = streets;
        initialIndexS = sIndex;
        _onStreetChanged(sIndex);
      }

      // 区
      var areas = await loadAreas(_city?.id ?? '');
      var aIndex = areas?.indexWhere((e) => e.id == _area?.id) ?? -1;
      if (aIndex != -1) {
        this.areas = areas;
        initialIndexA = aIndex;
        // 没有街道信息时，选择上一级
        if (sIndex == -1) {
          _onAreaChanged(aIndex);
        }
      }

      if (!mounted) return;
      isLoading = false;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (pIndex != -1) {
        provinceController.scrollTo(index: pIndex, duration: _kDuration);
      }
      if (cIndex != -1) {
        cityController.scrollTo(index: cIndex, duration: _kDuration);
      }
      if (aIndex != -1) {
        areaController.scrollTo(index: aIndex, duration: _kDuration);
      }
      if (sIndex != -1) {
        streetController.scrollTo(index: sIndex, duration: _kDuration);
      }
      await Future.delayed(_kDuration * 2);
      if (!mounted) return;
      setState(() {});
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  /// 省份选择
  void _onProvinceChanged(int index) async {
    if (_province == provinces![index]) return;
    _province = provinces![index];
    if (kDebugMode) {
      print('_onProvinceChanged ${_province?.name}');
    }
    if (tabIndex != 1) {
      tabIndex = 1;
      cities?.clear();
      areas?.clear();
      streets?.clear();
      _city = null;
      _area = null;
      _street = null;
      showCity = true;
      showArea = false;
      showStreet = false;
      setState(() {});

      // 获取对应的城市
      await Future.delayed(_kSmallDuration);
      if (!mounted) return;
      cities = await loadCities(_province!.id);
      isLoading = false;
      setState(() {});
    }
  }

  /// 城市选择
  void _onCityChanged(int index) async {
    if (_city == cities![index]) return;
    _city = cities![index];
    if (kDebugMode) {
      print('_onCityChanged ${_city?.name}');
    }
    if (tabIndex != 2) {
      tabIndex = 2;
      areas?.clear();
      streets?.clear();
      _area = null;
      _street = null;
      showCity = true;
      showArea = true;
      showStreet = false;
      isLoading = true;
      setState(() {});

      // 获取对应的区
      await Future.delayed(_kSmallDuration);
      if (!mounted) return;
      areas = await loadAreas(_city!.id);
      isLoading = false;
      setState(() {});
    }
  }

  /// 区域选择
  void _onAreaChanged(int index) async {
    if (_area == areas![index]) return;
    _area = areas![index];
    if (kDebugMode) {
      print('_onAreaChanged ${_area?.name}');
    }
    if (tabIndex != 3) {
      tabIndex = 2;
      streets?.clear();
      _street = null;
      showCity = true;
      showArea = true;
      isLoading = true;
      setState(() {});

      // 获取对应的街道
      await Future.delayed(_kDuration);
      if (!mounted) return;
      streets = await loadStreets(_area!.id);
      showStreet = streets?.isNotEmpty ?? false;
      tabIndex = showStreet ? 3 : 2;
      isLoading = false;
      setState(() {});
      _animatedToEnd();
    }
  }

  /// 街道选择
  void _onStreetChanged(int index) async {
    if (_street == streets?[index]) return;
    _street = streets?[index];
    if (kDebugMode) {
      print('_onStreetChanged ${_street?.name}');
    }
    tabIndex = 3;
    showCity = true;
    showArea = true;
    showStreet = true;
    setState(() {});
    _animatedToEnd();
  }

  /// 将选择地址信息滑动到最右端
  void _animatedToEnd() async {
    await Future.delayed(_kSmallDuration);
    if (!mounted) return;
    selectionController.animateTo(
      selectionController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      borderRadius: widget.borderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            Title(
              title: widget.title,
              textStyle: widget.textStyle,
              onConfirm: _onConfirm,
            ),

            /// 已选择地址信息
            Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: selectionController,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (showProvince)
                        TitleButton(
                          text: _province?.name,
                          select: tabIndex == 0,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 0),
                        ),
                      if (showCity)
                        TitleButton(
                          text: _city?.name,
                          select: tabIndex == 1,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 1),
                        ),
                      if (showArea)
                        TitleButton(
                          text: _area?.name,
                          select: tabIndex == 2,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 2),
                        ),
                      if (showStreet)
                        TitleButton(
                          text: _street?.name,
                          select: tabIndex == 3,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 3),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            ///
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IndexedStack(
                    index: tabIndex,
                    children: [
                      /// 省
                      ScrollablePositionedList.builder(
                        itemScrollController: provinceController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexP,
                        itemCount: provinces?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: provinces![index].name,
                          select: provinces![index].name == _province?.name,
                          onItem: () => _onProvinceChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),

                      /// 市
                      ScrollablePositionedList.builder(
                        itemScrollController: cityController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexC,
                        itemCount: cities?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: cities![index].name,
                          select: cities![index].name == _city?.name,
                          onItem: () => _onCityChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),

                      /// 区
                      ScrollablePositionedList.builder(
                        itemScrollController: areaController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexA,
                        itemCount: areas?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: areas![index].name,
                          select: areas![index].name == _area?.name,
                          onItem: () => _onAreaChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),

                      /// 街道
                      ScrollablePositionedList.builder(
                        itemScrollController: streetController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexS,
                        itemCount: streets?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: streets![index].name,
                          select: streets![index].name == _street?.name,
                          onItem: () => _onStreetChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),
                    ],
                  ),

                  /// Loading
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? widget.loadingBuilder?.call(context)
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择的信息
class TitleButton extends StatelessWidget {
  final String? text;
  final bool select;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;

  const TitleButton({
    Key? key,
    required this.text,
    this.select = false,
    this.onTap,
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith(
          (states) => const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      child: Text(
        text ?? '请选择',
        style: select
            ? textStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                )
            : unSelectTextStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
      ),
    );
  }
}

///标题栏
class Title extends StatelessWidget {
  final String? title;
  final TextStyle? textStyle;

  ///
  final VoidCallback? onConfirm;

  const Title({Key? key, this.title, this.textStyle, this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Material(
              child: Text(
                '取消',
                style: textStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
              ),
            ),
          ),
          Text(
            title ?? '选择地区',
            style: textStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Material(
              child: Text(
                '确定',
                style: textStyle ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyText1?.color,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item
class _ItemView extends StatelessWidget {
  final String label;
  final bool select;
  final VoidCallback? onItem;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;

  const _ItemView({
    Key? key,
    required this.label,
    this.select = false,
    this.onItem,
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onItem,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(
          label,
          style: select
              ? textStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  )
              : unSelectTextStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).textTheme.bodyText1?.color,
                  ),
        ),
      ),
    );
  }
}
