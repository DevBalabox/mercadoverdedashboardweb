import 'package:flutter/material.dart';
import 'package:web_verde/src/utils/theme.dart';

class ButtonLight extends StatefulWidget {
  final String mainText;
  final Function pressed;

  const ButtonLight({this.mainText, this.pressed});

  @override
  _ButtonLightState createState() => _ButtonLightState();
}

class _ButtonLightState extends State<ButtonLight> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          borderRadius: BorderRadius.circular(100),
          border: Border.all(width: 1.0, color: primaryGreen),
          color: Colors.white),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // customBorder: CircleBorder(),
          borderRadius: BorderRadius.circular(100),
          onTap: widget.pressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            alignment: Alignment.center,
            // height: 50.0,
            child: Text(
              widget.mainText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryGreen,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      // color: Colors.white,
    );
  }
}

class ButtonPrimary extends StatefulWidget {
  final Color color;
  final String mainText;
  final Function pressed;

  ButtonPrimary({Key key, this.mainText, this.pressed, this.color})
      : super(key: key);

  @override
  _ButtonPrimaryState createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1.0,
            color: Colors.transparent,
          ),
          color: widget.color == null ? null : widget.color,
          gradient: widget.color == null
              ? LinearGradient(
                  begin: Alignment.topRight,
                  colors: [Color(0xff009F39), Color(0xff00A83C)])
              : null),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // customBorder: CircleBorder(),
          borderRadius: BorderRadius.circular(100),
          onTap: widget.pressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            alignment: Alignment.center,
            // height: 50.0,
            child: Text(
              widget.mainText,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      // color: Colors.white,
    );
  }
}

class ButtonWhitePrimary extends StatefulWidget {
  final String mainText;
  final Function pressed;

  ButtonWhitePrimary({Key key, this.mainText, this.pressed}) : super(key: key);

  @override
  _ButtonWhitePrimaryState createState() => _ButtonWhitePrimaryState();
}

class _ButtonWhitePrimaryState extends State<ButtonWhitePrimary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1.0,
            color: Colors.transparent,
          ),
          color: Colors.white),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // customBorder: CircleBorder(),
          borderRadius: BorderRadius.circular(100),
          onTap: widget.pressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            // height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    widget.mainText,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // color: Colors.white,
    );
  }
}

class ButtonLoad extends StatefulWidget {
  ButtonLoad({Key key}) : super(key: key);

  @override
  _ButtonLoadState createState() => _ButtonLoadState();
}

class _ButtonLoadState extends State<ButtonLoad> with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                0.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            width: 1.0,
            color: Colors.transparent,
          ),
          // color: primaryGreen
          gradient: LinearGradient(
              begin: Alignment.topRight,
              colors: [Color(0xff009F39), Color(0xff00A83C)])),
      child: Material(
        color: Colors.transparent,
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            alignment: Alignment.center,
            // height: 50.0,
            child: Container(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                backgroundColor: primaryYellow.withOpacity(0.5),
                valueColor: animationController.drive(
                    ColorTween(begin: primaryOrange, end: primaryYellow)),
              ),
            )),
      ),
      // color: Colors.white,
    );
  }
}
