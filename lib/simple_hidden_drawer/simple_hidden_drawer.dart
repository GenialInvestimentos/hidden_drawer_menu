import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/controllers/hidden_drawer_controller.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/animated_drawer_content.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/bloc/simple_hidden_drawer_bloc.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/provider/simple_hidden_drawer_provider.dart';

class SimpleHiddenDrawer extends StatefulWidget {
  /// position initial item selected in menu( start in 0)
  final int initPositionSelected;

  /// enable and disable open and close with gesture
  final bool isDraggable;

  /// percent the container should be slided to the side
  final double slidePercent;

  /// percent the content should scale vertically
  final double verticalScalePercent;

  /// radius applied to the content when active
  final double contentCornerRadius;

  /// curve effect to open and close drawer
  final Curve curveAnimation;

  /// enable animation Scale
  final bool enableScaleAnimation;

  /// enable animation borderRadius
  final bool enableCornerAnimation;

  /// Function of the receive screen to show
  final Widget Function(int position, SimpleHiddenDrawerBloc bloc)
      screenSelectedBuilder;

  final Widget menu;

  final TypeOpen typeOpen;

  /// display shadow on the edge of the drawer
  final bool withShadow;

  const SimpleHiddenDrawer(
      {Key key,
      this.initPositionSelected = 0,
      this.isDraggable = true,
      this.slidePercent = 80.0,
      this.verticalScalePercent = 80.0,
      this.contentCornerRadius = 10.0,
      this.curveAnimation = Curves.decelerate,
      this.screenSelectedBuilder,
      this.menu,
      this.enableScaleAnimation = true,
      this.enableCornerAnimation = true,
      this.typeOpen = TypeOpen.FROM_LEFT,
      this.withShadow = true})
      : assert(screenSelectedBuilder != null),
        assert(menu != null),
        super(key: key);
  @override
  _SimpleHiddenDrawerState createState() => _SimpleHiddenDrawerState();
}

class _SimpleHiddenDrawerState extends State<SimpleHiddenDrawer>
    with TickerProviderStateMixin {
  SimpleHiddenDrawerBloc _bloc;

  /// controller responsible to animation of the drawer
  HiddenDrawerController _controller;

  @override
  void initState() {
    _bloc = SimpleHiddenDrawerBloc(
      widget.initPositionSelected,
      widget.screenSelectedBuilder,
    );

    _controller = new HiddenDrawerController(
      vsync: this,
      animationCurve: widget.curveAnimation,
    );

    _controller.addListener(() {
      _bloc.controllers.setMenuState(_controller.state);
    });

    _bloc.controllers.getActionToggle.listen((d) {
      _controller.toggle();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleHiddenDrawerProvider(
      hiddenDrawerBloc: _bloc,
      child: Stack(
        children: [widget.menu, _createContentDisplay()],
      ),
    );
  }

  Widget _createContentDisplay() {
    return AnimatedDrawerContent(
      withPaddingTop: true,
      controller: _controller,
      isDraggable: widget.isDraggable,
      slidePercent: widget.slidePercent,
      verticalScalePercent: widget.verticalScalePercent,
      contentCornerRadius: widget.contentCornerRadius,
      enableScaleAnimation: widget.enableScaleAnimation,
      enableCornerAnimation: widget.enableCornerAnimation,
      typeOpen: widget.typeOpen,
      withShadow: widget.withShadow,
      child: StreamBuilder(
        stream: _bloc.controllers.getScreenSelected,
        initialData: SizedBox.shrink(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.data;
        },
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
