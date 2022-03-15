library infinite_tabview;

import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A type of callback to build [Widget] on specified index.
typedef SelectIndexedWidgetBuilder = Widget Function(
    BuildContext context, int index, bool isSelected);

/// A type of callback to build [Text] Widget on specified index.
typedef SelectIndexedTextBuilder = Text Function(int index, bool isSelected);

/// A type of callback to execute processing on tapped tab.
typedef IndexedTapCallback = void Function(int index);

/// A widget for display combo of tabs and pages.
///
/// Internally, the tabs and pages will build as just Scrollable elements like
/// `ListView`. But these have massive index range from [double.negativeInfinity]
/// to [double.infinity], so that these can scroll infinitely.
class InfiniteScrollTabView extends StatelessWidget {
  /// Creates a tab view widget that can scroll infinitely.
  const InfiniteScrollTabView({
    Key? key,
    required this.contentLength,
    required this.tabBuilder,
    required this.pageBuilder,
    this.onTabTap,
    this.separator,
    this.backgroundColor = Colors.transparent,
    this.onPageChanged,
    this.indicatorColor = Colors.pinkAccent,
    this.indicatorHeight,
    this.tabHeight = 44.0,
    this.tabPadding = 12.0,
    this.size,
    this.forceFixedTabWidth = false,
    this.fixedTabWidthFraction = 0.5,
  }) : super(key: key);

  /// A length of tabs and pages.
  ///
  /// This value is shared between tabs and pages, so those must have same
  /// content length.
  ///
  /// Otherwise, if this value is less than tab contents, [tabBuilder] output
  /// will be repeated in [contentLength].
  final int contentLength;

  /// A callback for build tab contents that can scroll infinitely.
  ///
  /// This must return [Text] Widget as specified by the type.
  ///
  /// See: [SelectIndexedTextBuilder]
  /// `index` is modulo number of real index by [contentLength].
  /// `isSelected` is the state that indicates whether the tab is selected or not.
  final SelectIndexedTextBuilder tabBuilder;

  /// A callback for build page contents that can scroll infinitely.
  ///
  /// See: [SelectIndexedWidgetBuilder]
  /// `index` is modulo number of real index by [contentLength].
  /// `isSelected` is the state that indicates whether the tab is selected or not.
  final SelectIndexedWidgetBuilder pageBuilder;

  /// A callback for tapped tab element.
  ///
  /// `index` is modulo number of real index by [contentLength].
  final IndexedTapCallback? onTabTap;

  /// The border specification that displays between tabs and pages.
  ///
  /// If this is null, any border line will not be displayed.
  final BorderSide? separator;

  /// The color of tab list.
  ///
  /// If this is null, the list background color will become [Material] default.
  final Color? backgroundColor;

  /// A callback on changed selected page.
  ///
  /// This will called by both tab tap occurred and page swipe occurred.
  final ValueChanged<int>? onPageChanged;

  /// The color of indicator that shows selected page.
  ///
  /// Defaults to [Colors.pinkAccent], and must not be null.
  final Color indicatorColor;

  /// The height of indicator.
  ///
  /// If this is null, the indicator height is aligned to [separator] height, or
  /// it also null, then fallbacks to 2.0.
  ///
  /// This must 1.0 or higher.
  final double? indicatorHeight;

  /// The height of tab contents.
  ///
  /// Defaults to 44.0.
  final double tabHeight;

  /// The padding value of each tab contents.
  ///
  /// Defaults to 12.0.
  /// This value sets as horizontal padding. For example, specify 12.0 then
  /// the tabs will have padding as `EdgeInsets.symmetric(horizontal: 12.0)`.
  final double tabPadding;

  /// The size constraint of this widget.
  ///
  /// If this is null, then `MediaQuery.of(context).size` is used as default.
  /// This value should specify only in some rare case, testing or something
  /// like that.
  /// Internally this is only used for get page width, but this value determines
  /// entire widget's width.
  final Size? size;

  /// The flag of using fixed tab width.
  ///
  /// When enable this, the tabs size will align fixed size that calculated from
  /// [size] with [fixedTabWidthFraction].
  ///
  /// If the tab content width exceeds fixed width, the content will be resized
  /// by [FittedBox] with [BoxFit.contain].
  final bool forceFixedTabWidth;

  /// The value of fraction when fixed tab size used.
  ///
  /// Defaults to 0.5.
  /// This will be ignored when [forceFixedTabWidth] is false.
  final double fixedTabWidthFraction;

  @override
  Widget build(BuildContext context) {
    if (indicatorHeight != null) {
      assert(indicatorHeight! >= 1.0);
    }

    return InnerInfiniteScrollTabView(
      size: MediaQuery.of(context).size,
      contentLength: contentLength,
      tabBuilder: tabBuilder,
      pageBuilder: pageBuilder,
      onTabTap: onTabTap,
      separator: separator,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      defaultTextStyle: DefaultTextStyle.of(context).style,
      textDirection: Directionality.of(context),
      backgroundColor: backgroundColor,
      onPageChanged: onPageChanged,
      indicatorColor: indicatorColor,
      indicatorHeight: indicatorHeight,
      defaultLocale: Localizations.localeOf(context),
      tabHeight: tabHeight,
      tabPadding: tabPadding,
      forceFixedTabWidth: forceFixedTabWidth,
      fixedTabWidthFraction: fixedTabWidthFraction,
    );
  }
}

const _tabAnimationDuration = Duration(milliseconds: 550);

@visibleForTesting
class InnerInfiniteScrollTabView extends StatefulWidget {
  const InnerInfiniteScrollTabView({
    Key? key,
    required this.size,
    required this.contentLength,
    required this.tabBuilder,
    required this.pageBuilder,
    this.onTabTap,
    this.separator,
    required this.textScaleFactor,
    required this.defaultTextStyle,
    required this.textDirection,
    this.backgroundColor,
    this.onPageChanged,
    required this.indicatorColor,
    this.indicatorHeight,
    required this.defaultLocale,
    required this.tabHeight,
    required this.tabPadding,
    required this.forceFixedTabWidth,
    required this.fixedTabWidthFraction,
  }) : super(key: key);

  final Size size;
  final int contentLength;
  final SelectIndexedTextBuilder tabBuilder;
  final SelectIndexedWidgetBuilder pageBuilder;
  final IndexedTapCallback? onTabTap;
  final BorderSide? separator;
  final double textScaleFactor;
  final TextStyle defaultTextStyle;
  final TextDirection textDirection;
  final Color? backgroundColor;
  final ValueChanged<int>? onPageChanged;
  final Color indicatorColor;
  final double? indicatorHeight;
  final Locale defaultLocale;
  final double tabHeight;
  final double tabPadding;
  final bool forceFixedTabWidth;
  final double fixedTabWidthFraction;

  @override
  InnerInfiniteScrollTabViewState createState() =>
      InnerInfiniteScrollTabViewState();
}

@visibleForTesting
class InnerInfiniteScrollTabViewState extends State<InnerInfiniteScrollTabView>
    with SingleTickerProviderStateMixin {
  late final _tabController = CycledScrollController(
    initialScrollOffset: centeringOffset(0),
  );
  late final _pageController = CycledScrollController();

  final ValueNotifier<bool> _isContentChangingByTab = ValueNotifier(false);
  final bool _isTabForceScrolling = false;

  late double _previousTextScaleFactor = widget.textScaleFactor;

  late final ValueNotifier<double> _indicatorSize;
  final _isTabPositionAligned = ValueNotifier<bool>(true);
  final _selectedIndex = ValueNotifier<int>(0);

  final List<double> _tabTextSizes = [];
  List<double> get tabTextSizes => _tabTextSizes;

  final List<double> _tabSizesFromIndex = [];
  List<double> get tabSizesFromIndex => _tabSizesFromIndex;

  final List<Tween<double>> _tabOffsets = [];
  List<Tween<double>> get tabOffsets => _tabOffsets;

  final List<Tween<double>> _tabSizeTweens = [];
  List<Tween<double>> get tabSizeTweens => _tabSizeTweens;

  double get indicatorHeight =>
      widget.indicatorHeight ?? widget.separator?.width ?? 2.0;

  late final _indicatorAnimationController =
      AnimationController(vsync: this, duration: _tabAnimationDuration)
        ..addListener(() {
          if (_indicatorAnimation == null) return;
          _indicatorSize.value = _indicatorAnimation!.value;
        });
  Animation<double>? _indicatorAnimation;

  double _totalTabSizeCache = 0.0;
  double get _totalTabSize {
    if (_totalTabSizeCache != 0.0) return _totalTabSizeCache;
    _totalTabSizeCache = widget.forceFixedTabWidth
        ? _fixedTabWidth * widget.contentLength
        : _tabTextSizes.reduce((v, e) => v += e);
    return _totalTabSizeCache;
  }

  double get _fixedTabWidth => widget.size.width * widget.fixedTabWidthFraction;

  double _calculateTabSizeFromIndex(int index) {
    var size = 0.0;
    for (var i = 0; i < index; i++) {
      size += _tabTextSizes[i];
    }
    return size;
  }

  double centeringOffset(int index) {
    final tabSize =
        widget.forceFixedTabWidth ? _fixedTabWidth : _tabTextSizes[index];
    return -(widget.size.width - tabSize) / 2;
  }

  @visibleForTesting
  void calculateTabBehaviorElements(double textScaleFactor) {
    _tabTextSizes.clear();
    _tabSizesFromIndex.clear();
    _tabOffsets.clear();
    _tabSizeTweens.clear();
    _totalTabSizeCache = 0.0;

    for (var i = 0; i < widget.contentLength; i++) {
      final text = widget.tabBuilder(i, false);
      final style = (text.style ?? widget.defaultTextStyle).copyWith(
        fontFamily:
            text.style?.fontFamily ?? widget.defaultTextStyle.fontFamily,
      );
      final layoutedText = TextPainter(
        text: TextSpan(text: text.data, style: style),
        maxLines: 1,
        locale: text.locale ?? widget.defaultLocale,
        textScaleFactor: text.textScaleFactor ?? textScaleFactor,
        textDirection: widget.textDirection,
      )..layout();
      final calculatedWidth = layoutedText.size.width + widget.tabPadding * 2;
      final sizeConstraint =
          widget.forceFixedTabWidth ? _fixedTabWidth : widget.size.width;
      _tabTextSizes.add(math.min(calculatedWidth, sizeConstraint));
      _tabSizesFromIndex.add(_calculateTabSizeFromIndex(i));
    }

    for (var i = 0; i < widget.contentLength; i++) {
      if (widget.forceFixedTabWidth) {
        final offsetBegin = _fixedTabWidth * i + centeringOffset(i);
        final offsetEnd = _fixedTabWidth * (i + 1) + centeringOffset(i);
        _tabOffsets.add(Tween(begin: offsetBegin, end: offsetEnd));
      } else {
        final offsetBegin = _tabSizesFromIndex[i] + centeringOffset(i);
        final offsetEnd = i == widget.contentLength - 1
            ? _totalTabSize + centeringOffset(0)
            : _tabSizesFromIndex[i + 1] + centeringOffset(i + 1);
        _tabOffsets.add(Tween(begin: offsetBegin, end: offsetEnd));
      }

      final sizeBegin = _tabTextSizes[i];
      final sizeEnd = _tabTextSizes[(i + 1) % widget.contentLength];
      _tabSizeTweens.add(Tween(
        begin: math.min(sizeBegin, _fixedTabWidth),
        end: math.min(sizeEnd, _fixedTabWidth),
      ));
    }
  }

  @override
  void didChangeDependencies() {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    if (_previousTextScaleFactor != textScaleFactor) {
      _previousTextScaleFactor = textScaleFactor;
      setState(() {
        calculateTabBehaviorElements(textScaleFactor);
      });
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    calculateTabBehaviorElements(widget.textScaleFactor);

    _indicatorSize = ValueNotifier(_tabTextSizes[0]);

    _tabController.addListener(() {
      if (_isTabForceScrolling) return;

      if (_isTabPositionAligned.value) {
        _isTabPositionAligned.value = false;
      }
    });

    _pageController.addListener(() {
      if (_isContentChangingByTab.value) return;

      final currentIndexDouble = _pageController.offset / widget.size.width;
      final currentIndex = currentIndexDouble.floor();
      final modIndex = currentIndexDouble.round() % widget.contentLength;

      final currentIndexDecimal =
          currentIndexDouble - currentIndexDouble.floor();

      _tabController.jumpTo(_tabOffsets[currentIndex % widget.contentLength]
          .transform(currentIndexDecimal));

      _indicatorSize.value = _tabSizeTweens[currentIndex % widget.contentLength]
          .transform(currentIndexDecimal);

      if (!_isTabPositionAligned.value) {
        _isTabPositionAligned.value = true;
      }

      if (modIndex != _selectedIndex.value) {
        widget.onPageChanged?.call(modIndex);
        _selectedIndex.value = modIndex;
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: widget.tabHeight + (widget.separator?.width ?? 0),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isContentChangingByTab,
                builder: (context, value, _) => AbsorbPointer(
                  absorbing: value,
                  child: _buildTabSection(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isTabPositionAligned,
                builder: (context, value, _) => Visibility(
                  visible: value,
                  child: _CenteredIndicator(
                    indicatorColor: widget.indicatorColor,
                    size: _indicatorSize,
                    indicatorHeight: indicatorHeight,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: CycledListView.builder(
            scrollDirection: Axis.horizontal,
            contentCount: widget.contentLength,
            controller: _pageController,
            physics: const PageScrollPhysics(),
            itemBuilder: (context, modIndex, rawIndex) => SizedBox(
              width: widget.size.width,
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, value, _) =>
                    widget.pageBuilder(context, modIndex, value == modIndex),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return CycledListView.builder(
      scrollDirection: Axis.horizontal,
      controller: _tabController,
      contentCount: widget.contentLength,
      itemBuilder: (context, modIndex, rawIndex) {
        final tab = Material(
          color: widget.backgroundColor,
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedIndex,
            builder: (context, index, _) => ValueListenableBuilder<bool>(
              valueListenable: _isTabPositionAligned,
              builder: (context, tab, _) => _TabContent(
                isTabPositionAligned: tab,
                selectedIndex: index,
                indicatorColor: widget.indicatorColor,
                tabPadding: widget.tabPadding,
                modIndex: modIndex,
                tabBuilder: widget.tabBuilder,
                separator: widget.separator,
                tabWidth: widget.forceFixedTabWidth
                    ? _fixedTabWidth
                    : _tabTextSizes[modIndex],
                indicatorHeight: indicatorHeight,
                indicatorWidth: _tabTextSizes[modIndex],
              ),
            ),
          ),
        );

        return widget.forceFixedTabWidth
            ? SizedBox(width: _fixedTabWidth, child: tab)
            : tab;
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _indicatorAnimationController.dispose();
    super.dispose();
  }
}

/// 選択したページまでの距離を計算する。
///
/// modの境界をまたぐ場合を考慮して、近い方向を指すように正負を調整する。
@visibleForTesting
int calculateMoveIndexDistance(int current, int selected, int length) {
  final tabDistance = selected - current;
  var move = tabDistance;
  if (tabDistance.abs() >= length ~/ 2) {
    move += (-tabDistance.sign * length);
  }

  return move;
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    Key? key,
    required this.isTabPositionAligned,
    required this.selectedIndex,
    required this.modIndex,
    required this.tabPadding,
    required this.indicatorColor,
    required this.tabBuilder,
    this.separator,
    required this.indicatorHeight,
    required this.indicatorWidth,
    required this.tabWidth,
  }) : super(key: key);

  final int modIndex;
  final int selectedIndex;
  final bool isTabPositionAligned;
  final double tabPadding;
  final Color indicatorColor;
  final SelectIndexedTextBuilder tabBuilder;
  final BorderSide? separator;
  final double indicatorHeight;
  final double indicatorWidth;
  final double tabWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: tabWidth,
          padding: EdgeInsets.symmetric(horizontal: tabPadding),
          decoration: BoxDecoration(
            border: Border(bottom: separator ?? BorderSide.none),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: tabBuilder(modIndex, selectedIndex == modIndex),
            ),
          ),
        ),
        if (selectedIndex == modIndex && !isTabPositionAligned)
          Positioned(
            bottom: 0,
            height: indicatorHeight,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: indicatorWidth,
                decoration: BoxDecoration(
                  color: indicatorColor,
                ),
              ),
            ),
          )
      ],
    );
  }
}

class _CenteredIndicator extends StatelessWidget {
  const _CenteredIndicator({
    Key? key,
    required this.indicatorColor,
    required this.size,
    required this.indicatorHeight,
  }) : super(key: key);

  final Color indicatorColor;
  final ValueNotifier<double> size;
  final double indicatorHeight;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: size,
      builder: (context, value, _) => Center(
        child: Container(
          height: indicatorHeight,
          decoration: BoxDecoration(
            color: indicatorColor,
          ),
          width: 50,
        ),
      ),
    );
  }
}

typedef ModuloIndexedWidgetBuilder = Widget Function(
    BuildContext context, int modIndex, int rawIndex);

class CycledListView extends StatefulWidget {
  /// See [ListView.builder]
  const CycledListView.builder({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.physics,
    this.padding,
    required this.itemBuilder,
    required this.contentCount,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.anchor = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  /// See: [ScrollView.scrollDirection]
  final Axis scrollDirection;

  /// See: [ScrollView.reverse]
  final bool reverse;

  /// See: [ScrollView.controller]
  final CycledScrollController? controller;

  /// See: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// See: [BoxScrollView.padding]
  final EdgeInsets? padding;

  /// See: [ListView.builder]
  final ModuloIndexedWidgetBuilder itemBuilder;

  /// See: [SliverChildBuilderDelegate.childCount]
  final int? itemCount;

  /// See: [ScrollView.cacheExtent]
  final double? cacheExtent;

  /// See: [ScrollView.anchor]
  final double anchor;

  /// See: [SliverChildBuilderDelegate.addAutomaticKeepAlives]
  final bool addAutomaticKeepAlives;

  /// See: [SliverChildBuilderDelegate.addRepaintBoundaries]
  final bool addRepaintBoundaries;

  /// See: [SliverChildBuilderDelegate.addSemanticIndexes]
  final bool addSemanticIndexes;

  /// See: [ScrollView.dragStartBehavior]
  final DragStartBehavior dragStartBehavior;

  /// See: [ScrollView.keyboardDismissBehavior]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See: [ScrollView.restorationId]
  final String? restorationId;

  /// See: [ScrollView.clipBehavior]
  final Clip clipBehavior;

  final int contentCount;

  @override
  _CycledListViewState createState() => _CycledListViewState();
}

class _CycledListViewState extends State<CycledListView> {
  CycledScrollController? _controller;

  CycledScrollController get _effectiveController =>
      widget.controller ?? _controller!;

  UniqueKey positiveListKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = CycledScrollController(initialScrollOffset: 0.0);
    }
  }

  @override
  void didUpdateWidget(CycledListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _controller = CycledScrollController(initialScrollOffset: 0.0);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> slivers = _buildSlivers(context);
    final AxisDirection axisDirection = _getDirection(context);
    final scrollPhysics =
        widget.physics ?? const AlwaysScrollableScrollPhysics();
    return Scrollable(
      axisDirection: axisDirection,
      controller: _effectiveController,
      physics: scrollPhysics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return Viewport(
          axisDirection: axisDirection,
          anchor: widget.anchor,
          offset: offset,
          center: positiveListKey,
          slivers: slivers,
          cacheExtent: widget.cacheExtent,
        );
      },
    );
  }

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(
        context, widget.scrollDirection, widget.reverse);
  }

  List<Widget> _buildSlivers(BuildContext context) {
    return <Widget>[
      SliverList(
        delegate: negativeChildrenDelegate,
      ),
      SliverList(
        delegate: positiveChildrenDelegate,
        key: positiveListKey,
      ),
    ];
  }

  SliverChildDelegate get positiveChildrenDelegate {
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (context, index) {
        return widget.itemBuilder(context, index % widget.contentCount, index);
      },
      childCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  SliverChildDelegate get negativeChildrenDelegate {
    final itemCount = widget.itemCount;
    return SliverChildBuilderDelegate(
      (context, index) {
        if (index == 0) return const SizedBox.shrink();
        return widget.itemBuilder(
            context, -index % widget.contentCount, -index);
      },
      childCount: itemCount,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    properties.add(FlagProperty('reverse',
        value: widget.reverse, ifTrue: 'reversed', showName: true));
    properties.add(DiagnosticsProperty<ScrollController>(
        'controller', widget.controller,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', widget.physics,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>(
        'padding', widget.padding,
        defaultValue: null));
    properties.add(
        DoubleProperty('cacheExtent', widget.cacheExtent, defaultValue: null));
  }
}

/// Same as a [ScrollController] except it provides [ScrollPosition] objects with infinite bounds.
class CycledScrollController extends ScrollController {
  /// Creates a new [CycledScrollController]
  CycledScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
  }) : super(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        );

  ScrollDirection get currentScrollDirection => position.userScrollDirection;

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return _InfiniteScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _InfiniteScrollPosition extends ScrollPositionWithSingleContext {
  _InfiniteScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  @override
  double get minScrollExtent => double.negativeInfinity;

  @override
  double get maxScrollExtent => double.infinity;
}
