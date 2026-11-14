# FreeCAD "Minimal" settings: the freecad equivalent of vscode/settings.json
# and vscode/keys.json. Edit, then restart FreeCAD.

SETTINGS = {
    # ───── Window ─────
    "window.menuBar": False,          # hidden; menu shortcuts keep working
    "window.toolBars": False,         # hidden, also after workbench switches
    "window.statusBar": True,
    "window.statusBarColor": "#3f0e8d",
    # ───── Panels ─────
    # Side panel = Combo View / Model / Tasks / Property docks (vscode sideBar)
    "sidePanel.visible": False,
    # Show the side panel while a task dialog is open (Pad, Sketch edit, ...)
    # and hide it again when the dialog closes.
    "sidePanel.autoShowForTasks": True,
    # Bottom panel = Report view / Python console / Selection view
    "bottomPanel.visible": False,
    # ───── Command palette ─────
    "palette.width": 640,
    "palette.maxRows": 14,
    "palette.showInactive": False,    # hide commands that can't run right now
    "palette.recentCount": 10,
    "palette.fontFamily": "Roboto Mono",
    "palette.includeMacros": True,
}

# FreeCAD preferences (user.cfg) written on every start, so they live here
# instead of drifting in the Preferences dialog.
# (group under "User parameter:", key, value); type comes from the value.
PREFERENCES = [
    # vscode: workbench.startupEditor = none
    ("BaseApp/Preferences/Mod/Start", "ShowOnStartup", False),
    ("BaseApp/Preferences/General", "AutoloadModule", "PartDesignWorkbench"),
    # vscode: editor.minimap.enabled = false
    ("BaseApp/Preferences/View", "ShowNaviCube", False),
    ("BaseApp/Preferences/View", "CornerCoordSystem", False),
    # dark theme (takes effect on the next start)
    ("BaseApp/Preferences/MainWindow", "StyleSheet", "FreeCAD Dark.qss"),
]

# Keybindings. "command" is a minimal.* action (see layout.ACTIONS) or any
# FreeCAD command name (find them in the palette: the dim text on each row).
KEYS = [
    {"key": "Ctrl+Space", "command": "minimal.commandPalette"},
    {"key": "Ctrl+B", "command": "minimal.toggleSidePanel"},
    {"key": "Ctrl+J", "command": "minimal.toggleBottomPanel"},
    {"key": "Alt+T", "command": "minimal.focusConsole"},
    {"key": "Ctrl+Shift+M", "command": "minimal.toggleMenuBar"},
]
