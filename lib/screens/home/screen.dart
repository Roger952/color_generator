import 'package:color_generator/cubit/color_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ColorCubit>().state;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: state.color),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hexa(
                        color: state.color,
                        onInputHexadecimal: (hexa) {
                          context.read<ColorCubit>().updateHexa(hexa);
                        },
                      ),
                      SizedBox(height: 60),
                      Row(
                        children: [
                          Expanded(
                            child: ColorSlider(
                              activeColor: Colors.red,
                              value: state.color.red,
                              onChange: (value) {
                                context.read<ColorCubit>().updateRed(value);
                              },
                              onInputValue: (value) {
                                context.read<ColorCubit>().updateRed(value);
                              },
                              onLongPressLabel: () {
                                _setClipboardText(
                                  context,
                                  state.color.red.toString(),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ColorSlider(
                              activeColor: Colors.green,
                              value: state.color.green,
                              onChange: (value) {
                                context.read<ColorCubit>().updateGreen(value);
                              },
                              onInputValue: (value) {
                                context.read<ColorCubit>().updateGreen(value);
                              },
                              onLongPressLabel: () {
                                _setClipboardText(
                                  context,
                                  state.color.green.toString(),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: ColorSlider(
                              activeColor: Colors.blue,
                              value: state.color.blue,
                              onChange: (value) {
                                context.read<ColorCubit>().updateBlue(value);
                              },
                              onInputValue: (value) {
                                context.read<ColorCubit>().updateBlue(value);
                              },
                              onLongPressLabel: () {
                                _setClipboardText(
                                  context,
                                  state.color.blue.toString(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _setClipboardText(BuildContext context, String text) async {
    Scaffold.of(context).hideCurrentSnackBar();

    await Clipboard.setData(ClipboardData(text: text));

    final _snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          Icon(Icons.assignment),
          SizedBox(width: 15),
          Text('Value copied to clipboard'),
        ],
      ),
    );

    Scaffold.of(context).showSnackBar(_snackbar);
  }
}

class Hexa extends StatelessWidget {
  final Color color;
  final Function(String hexa) onInputHexadecimal;

  const Hexa({
    Key key,
    this.color,
    this.onInputHexadecimal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _colorString = color.toString().substring(10, 16).toUpperCase();
    final _hexaColorString = '#' + _colorString;

    return SelectableText(
      _hexaColorString,
      onTap: () {
        _showValuePickerDialog(
          context: context,
          initialValue: _hexaColorString,
          onSubmit: onInputHexadecimal,
        );
      },
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color.computeLuminance() > .5 ? Colors.black : Colors.white,
      ),
    );
  }
}

class ColorSlider extends StatelessWidget {
  final int value;
  final Color activeColor;
  final Function(int value) onChange;
  final Function(int value) onInputValue;
  final Function() onLongPressLabel;

  const ColorSlider({
    Key key,
    this.value,
    this.activeColor,
    this.onChange,
    this.onInputValue,
    this.onLongPressLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _color = context.watch<ColorCubit>().state.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlatButton(
          highlightColor: contrastColor(_color).withOpacity(.1),
          splashColor: activeColor.withOpacity(.2),
          child: Text(
            value.toString(),
            style: TextStyle(
              color: contrastColor(_color),
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            _showValuePickerDialog(
              context: context,
              initialValue: _color.toString(),
              inputType: TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              onSubmit: (value) {
                final _intColor = int.parse(value);

                onInputValue(_intColor);
              },
            );
          },
          onLongPress: onLongPressLabel,
        ),
        SizedBox(height: 15),
        RotatedBox(
          quarterTurns: 3,
          child: CupertinoSlider(
            min: 0,
            max: 255,
            thumbColor: activeColor,
            activeColor: activeColor.withOpacity(.5),
            value: value.toDouble(),
            onChanged: (value) => onChange(value.toInt()),
          ),
        ),
      ],
    );
  }

  Color contrastColor(Color color) =>
      color.computeLuminance() > .5 ? Colors.black : Colors.white;
}

_showValuePickerDialog({
  BuildContext context,
  String initialValue,
  Function(String value) onSubmit,
  TextInputType inputType,
}) {
  final _focusNode = FocusNode();
  final _inputController = TextEditingController(
    text: initialValue,
  );

  _focusNode.requestFocus();

  showDialog(
    context: context,
    child: AlertDialog(
      title: Text('Input value'),
      content: TextFormField(
        focusNode: _focusNode,
        controller: _inputController,
        decoration: InputDecoration(labelText: 'Color value'),
        keyboardType: inputType,
      ),
      actions: [
        FlatButton(
          onPressed: () {
            final _value = _inputController.text;

            if (_value.isNotEmpty && _value != initialValue) {
              onSubmit(_value);
            }

            Navigator.pop(context);
          },
          child: Text('Ok'),
        ),
      ],
    ),
  );
}
