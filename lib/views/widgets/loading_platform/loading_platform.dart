
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../components/styles/size_config.dart';

class LoadingPlatform extends StatelessWidget {
  final Color? color;
  const LoadingPlatform({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhysicalModel(
          color: Theme.of(context).dialogBackgroundColor,
          // color: Colors.black87,
          clipBehavior: Clip.antiAlias,
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: SpinKitCircle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.heightMultiplier * 1,
        ),
        PhysicalModel(
          color: Theme.of(context).dialogBackgroundColor,
          // color: Colors.black87,
          clipBehavior: Clip.antiAlias,
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "ກຳລັງໂຫຼດ",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: SizeConfig.textMultiplier * 3.8),
            ),
          ),
        ),
      ],
    );
  }
}

class ImageLoadingPlatform extends StatelessWidget {
  final Color? color;
  const ImageLoadingPlatform({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class ImageLoadingPlatformNoPadding extends StatelessWidget {
  final Color? color;
  const ImageLoadingPlatformNoPadding({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: Theme.of(context).colorScheme.primary,
    );
    // if (Platform.isIOS) {
    //   return Center(child: CupertinoActivityIndicator());
    // } else {
    //   return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor)));
    // }
  }
}











class CustomProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;

  const CustomProgressHUD({
    required Key key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = List<Widget>.empty(growable: true);
    widgetList.add(child);
    if (inAsyncCall) {
      final modal = Stack(
        children: [
          Opacity(
            opacity: opacity,
            child: ModalBarrier(
              dismissible: false,
              color: color,
            ),
          ),
          Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.blue,
              size: 50,
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}

