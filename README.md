# TrackpadQuit

This repository contains a minimal example of a macOS application that quits the frontmost application when a four‑finger downward swipe is detected on the trackpad. It relies on the private `MultiTouchSupport.framework` used by macOS.

## Building

1. Open **Xcode** and create a new **macOS** project using the *App* template.
2. Add the files in the `TrackpadQuit` directory to the project.
3. Link against `MultiTouchSupport.framework`. This framework is located in `/System/Library/PrivateFrameworks`.
4. Build and run the application. It runs as a background app with no dock icon.

When four fingers swipe down on the trackpad, the app attempts to terminate the application that currently has focus.

**Note:** because the app uses private APIs, future macOS versions may break this implementation, and it may not be suitable for App Store distribution.
