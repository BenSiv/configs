# FreeCAD runs this file at GUI startup for every directory in Mod/.
# Settings and keybindings: minimal_ui/settings.py
try:
    import minimal_ui

    minimal_ui.init()
except Exception as exc:  # never break FreeCAD startup
    import FreeCAD

    FreeCAD.Console.PrintError("Minimal UI failed to load: %s\n" % exc)
