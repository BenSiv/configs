"""Minimal window chrome: hides menus, toolbars and docks, and exposes
toggles for them as palette actions."""

import FreeCAD
import FreeCADGui
from PySide import QtCore, QtGui

from .settings import SETTINGS, PREFERENCES

SIDE_WORDS = ("combo", "tree", "property", "model", "task")
BOTTOM_WORDS = ("report", "python", "console", "selection")
TASK_WORDS = ("combo", "task")


def _dock_key(dock):
    return (dock.objectName() + " " + dock.windowTitle()).lower()


def apply_preferences():
    for group, key, value in PREFERENCES:
        param = FreeCAD.ParamGet("User parameter:" + group)
        if isinstance(value, bool):
            param.SetBool(key, value)
        elif isinstance(value, int):
            param.SetInt(key, value)
        elif isinstance(value, float):
            param.SetFloat(key, value)
        else:
            param.SetString(key, str(value))


def _alive(obj):
    try:
        obj.objectName()
        return True
    except RuntimeError:
        return False


class Layout(QtCore.QObject):
    def __init__(self, mw):
        super().__init__(mw)
        self.mw = mw
        self.state = {
            "menuBar": SETTINGS["window.menuBar"],
            "toolBars": SETTINGS["window.toolBars"],
            "statusBar": SETTINGS["window.statusBar"],
            "sidePanel": SETTINGS["sidePanel.visible"],
            "bottomPanel": SETTINGS["bottomPanel.visible"],
        }
        self.hidden_toolbars = []
        self.task_auto_shown = False
        self.task_suppressed = False

        self.timer = QtCore.QTimer(self)
        self.timer.setInterval(250)
        self.timer.timeout.connect(self._tick)

    # ───── setup ─────
    def start(self):
        color = SETTINGS.get("window.statusBarColor")
        if color:
            self.mw.statusBar().setStyleSheet(
                "QStatusBar { background: %s; color: #ffffff; }"
                "QStatusBar QLabel, QStatusBar QPushButton { color: #ffffff; }" % color
            )
        try:
            self.mw.workbenchActivated.connect(self._on_workbench)
        except AttributeError:
            pass
        self._apply_all()
        self.timer.start()

    def _apply_all(self):
        self._apply_menubar()
        self._apply_toolbars()
        self.mw.statusBar().setVisible(self.state["statusBar"])
        self._set_docks(SIDE_WORDS, self.state["sidePanel"])
        self._set_docks(BOTTOM_WORDS, self.state["bottomPanel"])

    # ───── docks ─────
    def docks(self, words):
        found = []
        for dock in self.mw.findChildren(QtGui.QDockWidget):
            key = _dock_key(dock)
            if any(w in key for w in words):
                found.append(dock)
        return found

    def _set_docks(self, words, visible):
        for dock in self.docks(words):
            dock.setVisible(visible)

    def toggle_side_panel(self):
        if self.task_auto_shown:
            # Panel is only up for a task dialog: hide it and keep it hidden
            # until that dialog closes.
            self.task_auto_shown = False
            self.task_suppressed = True
            self._set_docks(SIDE_WORDS, False)
            return
        self.state["sidePanel"] = not self.state["sidePanel"]
        self._set_docks(SIDE_WORDS, self.state["sidePanel"])

    def toggle_bottom_panel(self):
        self.state["bottomPanel"] = not self.state["bottomPanel"]
        self._set_docks(BOTTOM_WORDS, self.state["bottomPanel"])

    def focus_console(self):
        """Like vscode terminal.focus: show + focus, or hide if focused."""
        consoles = self.docks(("python",))
        if not consoles:
            return
        dock = consoles[0]
        inner = dock.widget()
        focused = QtGui.QApplication.focusWidget()
        has_focus = focused is not None and inner is not None and (
            focused is inner or inner.isAncestorOf(focused)
        )
        if dock.isVisible() and has_focus:
            dock.hide()
            return
        dock.show()
        dock.raise_()
        if inner is not None:
            inner.setFocus(QtCore.Qt.ShortcutFocusReason)

    def show_report(self):
        for dock in self.docks(("report",)):
            dock.show()
            dock.raise_()

    # ───── menu bar ─────
    def _apply_menubar(self):
        bar = self.mw.menuBar()
        bar.setVisible(self.state["menuBar"])
        if not self.state["menuBar"]:
            # Shortcuts of actions in a hidden menu bar stop firing in Qt;
            # attaching them to the main window keeps them alive.
            for action in self._menu_actions(bar):
                self.mw.addAction(action)

    def _menu_actions(self, widget):
        out = []
        for action in widget.actions():
            menu = action.menu()
            if menu is not None:
                out.extend(self._menu_actions(menu))
            elif not action.isSeparator():
                out.append(action)
        return out

    def toggle_menubar(self):
        self.state["menuBar"] = not self.state["menuBar"]
        self._apply_menubar()

    # ───── toolbars ─────
    def _main_toolbars(self):
        return [
            tb for tb in self.mw.findChildren(QtGui.QToolBar)
            if tb.parentWidget() is self.mw
        ]

    def _apply_toolbars(self):
        if self.state["toolBars"]:
            for tb in self.hidden_toolbars:
                if _alive(tb):
                    tb.show()
            self.hidden_toolbars = []
        else:
            self._hide_visible_toolbars()

    def _hide_visible_toolbars(self):
        for tb in self._main_toolbars():
            if tb.isVisible():
                tb.hide()
                if tb not in self.hidden_toolbars:
                    self.hidden_toolbars.append(tb)

    def toggle_toolbars(self):
        self.state["toolBars"] = not self.state["toolBars"]
        self._apply_toolbars()

    def toggle_statusbar(self):
        self.state["statusBar"] = not self.state["statusBar"]
        self.mw.statusBar().setVisible(self.state["statusBar"])

    def zen_mode(self):
        """Hide everything, or restore the configured defaults."""
        anything = any(self.state.values())
        if anything:
            for k in self.state:
                self.state[k] = False
        else:
            self.state.update({
                "menuBar": SETTINGS["window.menuBar"],
                "toolBars": SETTINGS["window.toolBars"],
                "statusBar": SETTINGS["window.statusBar"],
                "sidePanel": SETTINGS["sidePanel.visible"],
                "bottomPanel": SETTINGS["bottomPanel.visible"],
            })
        self._apply_all()

    # ───── events ─────
    def _on_workbench(self, *_):
        self.hidden_toolbars = [tb for tb in self.hidden_toolbars if _alive(tb)]
        QtCore.QTimer.singleShot(0, self._apply_menubar)
        QtCore.QTimer.singleShot(0, self._apply_toolbars)

    def _tick(self):
        if not self.state["toolBars"]:
            self._hide_visible_toolbars()
        if not SETTINGS["sidePanel.autoShowForTasks"] or self.state["sidePanel"]:
            return
        try:
            active = bool(FreeCADGui.Control.activeDialog())
        except Exception:
            return
        if not active:
            self.task_suppressed = False
        if active and not self.task_auto_shown and not self.task_suppressed:
            self._set_docks(TASK_WORDS, True)
            self.task_auto_shown = True
        elif not active and self.task_auto_shown:
            self._set_docks(TASK_WORDS, False)
            self.task_auto_shown = False


# Palette entries for the layout. id -> (label, method name)
ACTIONS = {
    "minimal.toggleSidePanel": ("View: Toggle Side Panel", "toggle_side_panel"),
    "minimal.toggleBottomPanel": ("View: Toggle Bottom Panel", "toggle_bottom_panel"),
    "minimal.focusConsole": ("View: Focus Python Console", "focus_console"),
    "minimal.showReport": ("View: Show Report View", "show_report"),
    "minimal.toggleMenuBar": ("View: Toggle Menu Bar", "toggle_menubar"),
    "minimal.toggleToolBars": ("View: Toggle Toolbars", "toggle_toolbars"),
    "minimal.toggleStatusBar": ("View: Toggle Status Bar", "toggle_statusbar"),
    "minimal.zenMode": ("View: Toggle Zen Mode", "zen_mode"),
}
