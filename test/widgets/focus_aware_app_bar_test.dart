import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auto-hidden app bar reserves no space while unfocused', () {
    const appBar = FocusAwareAppBar(
      autoHide: true,
      focused: false,
      onFocusChanged: _ignoreFocusChange,
    );

    expect(appBar.preferredSize.height, 0);
  });

  test('focused and non-auto-hidden app bars reserve toolbar space', () {
    const focusedAppBar = FocusAwareAppBar(
      autoHide: true,
      focused: true,
      onFocusChanged: _ignoreFocusChange,
    );
    const alwaysVisibleAppBar = FocusAwareAppBar(
      autoHide: false,
      focused: false,
      onFocusChanged: _ignoreFocusChange,
    );

    expect(focusedAppBar.preferredSize.height, kToolbarHeight);
    expect(alwaysVisibleAppBar.preferredSize.height, kToolbarHeight);
  });
}

void _ignoreFocusChange(bool focused) {}
