# Flutter Calendar Widget

## Description
This Flutter Calendar Widget is a customizable, feature-rich calendar implementation designed for Flutter applications. It provides an elegant, user-friendly interface for displaying dates, holidays, and special events with smooth scrolling capabilities through multiple months.

## Features

- **Interactive Calendar Interface**: Tap on any date to select it
- **Multi-Month View**: Scroll through 12 months (configurable)
- **Today Highlighting**: Current date is clearly highlighted with distinct styling
- **Special Events & Holidays**: Built-in support for international holidays
- **Dynamic Special Days**: Custom logic for variable dates like Mother's Day (second Sunday in May)
- **Automatic Midnight Updates**: Calendar refreshes automatically at midnight
- **Jump to Today**: Quick navigation back to the current date with a floating action button
- **Responsive Design**: Adapts to different screen sizes with proper aspect ratios

## International Holidays
The calendar comes pre-configured with several international holidays:
- New Year's Day (January 1)
- Valentine's Day (February 14)
- St. Patrick's Day (March 17)
- Earth Day (April 22)
- Labour Day (May 1)
- Summer Solstice (June 21)
- Independence Day (US) (July 4)
- Halloween (October 31)
- Christmas Day (December 25)
- New Year's Eve (December 31)
- Mother's Day (Second Sunday in May)

## Usage

1. Import the Calendar widget into your Flutter project
2. Add the Calendar widget to your layout:

```dart
import 'package:your_package_name/calendar.dart';

// In your build method:
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('My Calendar')),
    body: const Calendar(),
  );
}
```

## Requirements

- Flutter SDK
- Dart SDK
- `intl` package for date formatting

## Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  intl: ^0.18.0  # Or the latest version
```

## Customization

You can extend this calendar by:
- Adding more holidays or special events to the `_internationalHolidays` map
- Creating additional custom date logic similar to `_isMothersDay()`
- Adjusting the styling parameters in the various build methods
- Modifying the `_monthsToShow` parameter to display more or fewer months

