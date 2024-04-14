import 'package:flutter/material.dart';

class CustomModalBottomSheet extends StatelessWidget {
  final Widget child;
  final bool dismissOnTap;
  final bool resizeToAvoidBottomPadding;

  const CustomModalBottomSheet({
    Key? key,
    required this.child,
    this.dismissOnTap = false,
    this.resizeToAvoidBottomPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissOnTap ? () => Navigator.pop(context) : null,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: resizeToAvoidBottomPadding
                ? MediaQuery.of(context).viewInsets.bottom
                : 0.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
