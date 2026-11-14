"""VS Code style command palette for FreeCAD.

Lists every registered FreeCAD command, the workbenches, user macros and the
minimal.* layout actions, with fuzzy search and recently-used on top.
"""

import os
import re

import FreeCAD
import FreeCADGui
from PySide import QtCore, QtGui

from .settings import KEYS, SETTINGS

PARAMS = "User parameter:BaseApp/Preferences/Mod/Minimal"

CATEGORY_NAMES = {"Std": "General", "Part": "Part", "PartDesign": "Part Design"}

STYLE = """
#MinimalPalette {
    background: #1f1f1f;
    border: 1px solid #454545;
    border-radius: 6px;
}
#MinimalPalette QLineEdit {
    background: #313131;
    color: #cccccc;
    border: 1px solid #0078d4;
    border-radius: 3px;
    padding: 4px 6px;
    font-family: "%(font)s", monospace;
}
#MinimalPalette QTreeWidget {
    background: #1f1f1f;
    color: #cccccc;
    border: none;
    outline: none;
    font-family: "%(font)s", monospace;
}
#MinimalPalette QTreeWidget::item {
    padding: 3px 2px;
    border: none;
}
#MinimalPalette QTreeWidget::item:selected {
    background: #04395e;
    color: #ffffff;
}
"""


def _clean(text):
    text = (text or "").replace("&&", "\0").replace("&", "").replace("\0", "&")
    return text.rstrip(".").strip()


def _category(name):
    prefix = name.split("_", 1)[0] if "_" in name else "Command"
    if prefix in CATEGORY_NAMES:
        return CATEGORY_NAMES[prefix]
    return re.sub(r"(?<=[a-z])(?=[A-Z])", " ", prefix)


def _subsequence(token, hay):
    pos, gaps = -1, 0
    for ch in token:
        nxt = hay.find(ch, pos + 1)
        if nxt < 0:
            return None
        if pos >= 0:
            gaps += nxt - pos - 1
        pos = nxt
    return max(1, 20 - gaps)


def score(query, hay):
    hay = hay.lower()
    total = 0
    for token in query.lower().split():
        i = hay.find(token)
        if i < 0:
            s = _subsequence(token, hay)
            if s is None:
                return None
            total += s
            continue
        total += 100 - min(i, 60)
        if i == 0 or not hay[i - 1].isalnum():
            total += 40
    return total


class Entry(object):
    __slots__ = ("id", "label", "detail", "shortcut", "icon", "run")

    def __init__(self, id, label, detail="", shortcut="", icon=None, run=None):
        self.id = id
        self.label = label
        self.detail = detail
        self.shortcut = shortcut
        self.icon = icon
        self.run = run

    def haystack(self):
        return self.label + " " + self.detail


class Palette(QtGui.QFrame):
    def __init__(self, mw, layout):
        super().__init__(mw, QtCore.Qt.Popup | QtCore.Qt.FramelessWindowHint)
        self.mw = mw
        self.layout_ctl = layout
        self.entries = []
        self.params = FreeCAD.ParamGet(PARAMS)

        self.setObjectName("MinimalPalette")
        self.setStyleSheet(STYLE % {"font": SETTINGS["palette.fontFamily"]})

        box = QtGui.QVBoxLayout(self)
        box.setContentsMargins(6, 6, 6, 6)
        box.setSpacing(4)

        self.input = QtGui.QLineEdit(self)
        self.input.setPlaceholderText("Type a command, workbench or macro")
        self.input.installEventFilter(self)
        self.input.textChanged.connect(self.refresh)
        box.addWidget(self.input)

        self.list = QtGui.QTreeWidget(self)
        self.list.setColumnCount(2)
        self.list.setHeaderHidden(True)
        self.list.setRootIsDecorated(False)
        self.list.setIndentation(0)
        self.list.setUniformRowHeights(True)
        self.list.setFocusPolicy(QtCore.Qt.NoFocus)
        self.list.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.list.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAlwaysOff)
        self.list.setIconSize(QtCore.QSize(16, 16))
        header = self.list.header()
        header.setStretchLastSection(False)
        try:
            header.setSectionResizeMode(0, QtGui.QHeaderView.Stretch)
            header.setSectionResizeMode(1, QtGui.QHeaderView.ResizeToContents)
        except AttributeError:  # Qt4-era PySide
            header.setResizeMode(0, QtGui.QHeaderView.Stretch)
            header.setResizeMode(1, QtGui.QHeaderView.ResizeToContents)
        self.list.itemClicked.connect(lambda item, _col: self._run(item))
        box.addWidget(self.list)

    # ───── sources ─────
    def _layout_entries(self):
        from .layout import ACTIONS

        keys = {}
        for binding in KEYS:
            keys.setdefault(binding["command"], binding["key"])
        return [Entry(key, label, key, keys.get(key, ""), None,
                      getattr(self.layout_ctl, method))
                for key, (label, method) in ACTIONS.items()]

    def _workbench_entries(self):
        out = []
        try:
            workbenches = FreeCADGui.listWorkbenches()
        except Exception:
            return out
        for name, wb in sorted(workbenches.items()):
            if name == "NoneWorkbench":
                continue
            label = getattr(wb, "MenuText", "") or name.replace("Workbench", "")
            icon = None
            try:
                icon_path = wb.Icon
                if isinstance(icon_path, str) and os.path.isfile(icon_path):
                    icon = QtGui.QIcon(icon_path)
            except Exception:
                pass
            out.append(Entry("wb:" + name, "Workbench: " + label, name, "", icon,
                             lambda n=name: FreeCADGui.activateWorkbench(n)))
        return out

    def _command_entries(self):
        out = []
        show_inactive = SETTINGS["palette.showInactive"]
        try:
            names = FreeCADGui.listCommands()
        except Exception:
            return out
        get = getattr(getattr(FreeCADGui, "Command", None), "get", None)
        for name in names:
            label, shortcut, icon = "", "", None
            cmd = None
            if get is not None:
                try:
                    cmd = get(name)
                except Exception:
                    cmd = None
            if cmd is not None:
                if not show_inactive:
                    try:
                        if not cmd.isActive():
                            continue
                    except Exception:
                        pass
                try:
                    actions = cmd.getAction() or []
                except Exception:
                    actions = []
                if actions:
                    action = actions[0]
                    label = action.text()
                    shortcut = action.shortcut().toString(
                        QtGui.QKeySequence.NativeText)
                    if not action.icon().isNull():
                        icon = action.icon()
                if not label:
                    try:
                        info = cmd.getInfo()
                        label = info.get("menuText", "")
                        shortcut = shortcut or info.get("shortcut", "")
                    except Exception:
                        pass
            label = _clean(label)
            if not label:
                continue
            out.append(Entry(name, "%s: %s" % (_category(name), label), name,
                             shortcut, icon,
                             lambda n=name: FreeCADGui.runCommand(n)))
        return out

    def _macro_entries(self):
        out = []
        if not SETTINGS["palette.includeMacros"]:
            return out
        try:
            folder = FreeCAD.ParamGet(
                "User parameter:BaseApp/Preferences/Macro").GetString(
                "MacroPath", FreeCAD.getUserMacroDir(True))
        except Exception:
            return out
        if not folder or not os.path.isdir(folder):
            return out
        for fname in sorted(os.listdir(folder)):
            if fname.lower().endswith((".fcmacro", ".py")):
                path = os.path.join(folder, fname)
                out.append(Entry("macro:" + path,
                                 "Macro: " + os.path.splitext(fname)[0], path,
                                 "", None, lambda p=path: _run_macro(p)))
        return out

    def collect(self):
        self.entries = (self._layout_entries() + self._workbench_entries()
                        + self._command_entries() + self._macro_entries())

    # ───── recent ─────
    def _recent(self):
        raw = self.params.GetString("Recent", "")
        return [r for r in raw.split("\n") if r]

    def _push_recent(self, entry_id):
        recent = [r for r in self._recent() if r != entry_id]
        recent.insert(0, entry_id)
        del recent[SETTINGS["palette.recentCount"]:]
        self.params.SetString("Recent", "\n".join(recent))

    # ───── ui ─────
    def open(self):
        self.collect()
        self.input.blockSignals(True)
        self.input.clear()
        self.input.blockSignals(False)
        self.refresh("")
        self._place()
        self.show()
        self.raise_()
        self.activateWindow()
        self.input.setFocus(QtCore.Qt.PopupFocusReason)

    def _place(self):
        width = min(SETTINGS["palette.width"], int(self.mw.width() * 0.9))
        row = self.list.sizeHintForRow(0) if self.list.topLevelItemCount() else 22
        rows = min(SETTINGS["palette.maxRows"], max(1, self.list.topLevelItemCount()))
        self.list.setFixedHeight(rows * max(row, 18) + 4)
        self.setFixedWidth(width)
        self.adjustSize()
        top = self.mw.menuBar().height() if self.mw.menuBar().isVisible() else 0
        origin = self.mw.mapToGlobal(QtCore.QPoint(0, 0))
        x = origin.x() + (self.mw.width() - width) // 2
        y = origin.y() + top + 8
        self.move(x, y)

    def refresh(self, query=None):
        if query is None:
            query = self.input.text()
        query = query.strip()
        recent = self._recent()
        rank = {rid: i for i, rid in enumerate(recent)}

        if not query:
            by_id = {e.id: e for e in self.entries}
            head = [by_id[r] for r in recent if r in by_id]
            seen = set(e.id for e in head)
            rest = sorted((e for e in self.entries if e.id not in seen),
                          key=lambda e: e.label.lower())
            shown = [(e, e.id in rank) for e in head + rest]
        else:
            scored = []
            for e in self.entries:
                s = score(query, e.haystack())
                if s is None:
                    continue
                if e.id in rank:
                    s += 30 - rank[e.id]
                scored.append((-s, e.label.lower(), e))
            scored.sort(key=lambda t: (t[0], t[1]))
            shown = [(t[2], t[2].id in rank) for t in scored]

        self.list.clear()
        dim = QtGui.QBrush(QtGui.QColor("#8b8b8b"))
        for entry, is_recent in shown[:300]:
            item = QtGui.QTreeWidgetItem([entry.label, entry.shortcut or
                                          ("recently used" if is_recent else "")])
            item.setData(0, QtCore.Qt.UserRole, entry.id)
            item.setToolTip(0, entry.detail)
            item.setForeground(1, dim)
            item.setTextAlignment(1, QtCore.Qt.AlignRight | QtCore.Qt.AlignVCenter)
            if entry.icon is not None:
                item.setIcon(0, entry.icon)
            self.list.addTopLevelItem(item)
        if self.list.topLevelItemCount():
            self.list.setCurrentItem(self.list.topLevelItem(0))

    def eventFilter(self, obj, event):
        if obj is self.input and event.type() == QtCore.QEvent.KeyPress:
            key = event.key()
            count = self.list.topLevelItemCount()
            row = self.list.indexOfTopLevelItem(self.list.currentItem())
            page = SETTINGS["palette.maxRows"] - 1
            moves = {
                QtCore.Qt.Key_Down: 1, QtCore.Qt.Key_Up: -1,
                QtCore.Qt.Key_PageDown: page, QtCore.Qt.Key_PageUp: -page,
            }
            if key in moves and count:
                row = (row + moves[key]) % count if abs(moves[key]) == 1 \
                    else max(0, min(count - 1, row + moves[key]))
                self.list.setCurrentItem(self.list.topLevelItem(row))
                return True
            if key in (QtCore.Qt.Key_Return, QtCore.Qt.Key_Enter):
                self._run(self.list.currentItem())
                return True
            if key == QtCore.Qt.Key_Escape:
                self.hide()
                return True
        return super().eventFilter(obj, event)

    def _run(self, item):
        if item is None:
            return
        entry_id = item.data(0, QtCore.Qt.UserRole)
        entry = next((e for e in self.entries if e.id == entry_id), None)
        self.hide()
        if entry is None or entry.run is None:
            return
        self._push_recent(entry.id)
        # Let the popup close before commands that open dialogs.
        QtCore.QTimer.singleShot(0, lambda: _safe(entry.run, entry.label))


def _run_macro(path):
    with open(path) as fh:
        code = compile(fh.read(), path, "exec")
    exec(code, {"__name__": "__main__", "__file__": path})


def _safe(fn, label):
    try:
        fn()
    except Exception as exc:
        FreeCAD.Console.PrintError("Command palette: %s failed: %s\n" % (label, exc))
