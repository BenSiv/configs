"""Minimal FreeCAD UI: VS Code style chrome + Ctrl+Space command palette."""

import FreeCAD
import FreeCADGui
from PySide import QtCore, QtGui

from .layout import ACTIONS, Layout, apply_preferences
from .palette import Palette
from .settings import KEYS

_instance = {}


def _resolve(command, layout, palette):
    if command == "minimal.commandPalette":
        return palette.open
    if command in ACTIONS:
        return getattr(layout, ACTIONS[command][1])
    return lambda: FreeCADGui.runCommand(command)


def _bind_keys(mw, layout, palette):
    shortcuts = []
    for binding in KEYS:
        handler = _resolve(binding["command"], layout, palette)
        sc = QtGui.QShortcut(QtGui.QKeySequence(binding["key"]), mw)
        sc.setContext(QtCore.Qt.ApplicationShortcut)
        sc.activated.connect(handler)
        # If FreeCAD has an action on the same key Qt reports it as
        # ambiguous and fires neither; the binding here wins.
        sc.activatedAmbiguously.connect(handler)
        shortcuts.append(sc)
    return shortcuts


def setup():
    if _instance:
        return
    mw = FreeCADGui.getMainWindow()
    layout = Layout(mw)
    palette = Palette(mw, layout)
    _instance.update(
        layout=layout,
        palette=palette,
        shortcuts=_bind_keys(mw, layout, palette),
    )
    layout.start()
    FreeCAD.Console.PrintLog("Minimal UI loaded (Ctrl+Space for commands)\n")


def init():
    """Called from InitGui.py, before the main window is fully restored."""
    FreeCADGui.getMainWindow()  # fail early if there's no GUI
    apply_preferences()
    # FreeCAD restores dock/toolbar state after modules init; run after it.
    QtCore.QTimer.singleShot(1500, setup)
