import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../components/styles/size_config.dart';

/// Shows a month picker dialog.
///
/// [initialDate] is the initially selected month.
/// [firstDate] is the lower bound for month selection.
/// [lastDate] is the upper bound for month selection.
///
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  Locale? locale,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  TransitionBuilder? builder,
}) async {
  return await showDialog<DateTime>(
    context: context,
    builder: (context) {
      Widget dialog = _MonthPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );

      if (locale != null) {
        dialog = Localizations.override(
          context: context,
          locale: locale,
          child: dialog,
        );
      }

      if (builder != null) {
        dialog = builder(context, dialog);
      }

      return dialog;
    },
  );
}

class _MonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _MonthPickerDialog({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  final _pageViewKey = GlobalKey();
  late final PageController _pageController;
  late final DateTime _firstDate;
  late final DateTime _lastDate;
  late DateTime _selectedDate;
  late int _displayedPage;
  bool _isYearSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month);
    _firstDate = DateTime(widget.firstDate.year, widget.firstDate.month);
    _lastDate = DateTime(widget.lastDate.year, widget.lastDate.month);
    _displayedPage = _selectedDate.year;
    _pageController = PageController(initialPage: _displayedPage);
  }

  String _locale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return '${locale.languageCode}_${locale.countryCode}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final locale = _locale(context);
    final header = _buildHeader(theme, locale);
    final pager = _buildPager(theme.colorScheme, locale);

    final borderRadius =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0))
            : const BorderRadius.only(
                topRight: Radius.circular(4.0),
                bottomRight: Radius.circular(4.0));

    final content = Material(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          pager,
          Container(height: 24),
          _buildButtonBar(context, localizations)
        ],
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) {
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              return IntrinsicWidth(
                child: Column(children: [
                  header,
                  content,
                ]),
              );
            }
            return IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  content,
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildButtonBar(
      BuildContext context, MaterialLocalizations localizations) {
    return ButtonTheme(
      child: ButtonBar(
        children: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(localizations.cancelButtonLabel,
                  style: GoogleFonts.notoSansLao(
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
          // TextButton(
          //   onPressed: () => Navigator.pop(context, _selectedDate),
          //   child: Text(localizations.okButtonLabel),
          // ),
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedDate),
            child: Text(
              localizations.okButtonLabel,
              style: GoogleFonts.notoSansLao(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String locale) {
    final borderRadius =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? const BorderRadius.only(
                topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
            : const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0));

    return Material(
      clipBehavior: Clip.antiAlias,
      // color: theme.brightness == Brightness.dark
      //     ? theme.colorScheme.surface
      //     : theme.colorScheme.primary,
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Text(
            //   DateFormat.yMMM(locale).format(_selectedDate),
            //   style: theme.primaryTextTheme.titleMedium,
            // ),
            DefaultTextStyle(
              style: theme.primaryTextTheme.headlineSmall!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!_isYearSelection)
                    GestureDetector(
                      onTap: () {
                        setState(() => _isYearSelection = true);
                        _pageController.jumpToPage(_displayedPage ~/ 12);
                      },
                      child: Text(DateFormat.y(locale)
                          .format(DateTime(_displayedPage))),
                    ),
                  if (_isYearSelection)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(DateFormat.y(locale)
                            .format(DateTime(_displayedPage * 12))),
                        Text('-'),
                        Text(DateFormat.y(locale)
                            .format(DateTime(_displayedPage * 12 + 11))),
                      ],
                    ), // Text(
                  Text(
                    DateFormat.yMMMM(locale).format(_selectedDate),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: SizeConfig.textMultiplier * 2.5),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          // Icons.keyboard_arrow_up,
                          Icons.keyboard_arrow_left_sharp,
                          color: theme.primaryIconTheme.color,
                        ),
                        onPressed: () => _pageController.animateToPage(
                            _displayedPage - 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut),
                      ),
                      IconButton(
                        icon: Icon(
                          // Icons.keyboard_arrow_down,
                          Icons.keyboard_arrow_right,
                          color: theme.primaryIconTheme.color,
                        ),
                        onPressed: () => _pageController.animateToPage(
                            _displayedPage + 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPager(ColorScheme colorScheme, String locale) {
    return SizedBox(
      height: 220.0,
      width: 300.0,
      child: PageView.builder(
          key: _pageViewKey,
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() => _displayedPage = index);
          },
          pageSnapping: !_isYearSelection,
          itemBuilder: (context, page) {
            return GridView.count(
              padding: const EdgeInsets.all(8.0),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              children: _isYearSelection
                  ? List<int>.generate(12, (i) => page * 12 + i)
                      .map(
                        (year) => Padding(
                          padding: const EdgeInsets.all(4.0),
                        ),
                      )
                      .toList()
                  : List<int>.generate(12, (i) => i + 1)
                      .map((month) => DateTime(page, month))
                      .map(
                        (date) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _getMonthButton(date, colorScheme, locale),
                        ),
                      )
                      .toList(),
            );
          }),
    );
  }

  Widget _getMonthButton(
      final DateTime date, final ColorScheme colorScheme, final String locale) {
    final int? firstDateCompared = _firstDate.compareTo(date);
    final int? lastDateCompared = _lastDate.compareTo(date);

    VoidCallback? callback = (firstDateCompared == null ||
                firstDateCompared <= 0) &&
            (lastDateCompared == null || lastDateCompared >= 0)
        ? () => setState(() => _selectedDate = DateTime(date.year, date.month))
        : null;

    bool isSelected =
        date.month == _selectedDate.month && date.year == _selectedDate.year;

    return TextButton(
      onPressed: callback,
      style: TextButton.styleFrom(
        foregroundColor: isSelected
            ? colorScheme.onPrimary
            : date.month == DateTime.now().month &&
                    date.year == DateTime.now().year
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.87),
        backgroundColor: isSelected ? Colors.blueAccent : null,
        shape: const StadiumBorder(),
      ),
      child: Text(
        DateFormat.MMMM(locale).format(date),
        style: GoogleFonts.notoSansLao(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
