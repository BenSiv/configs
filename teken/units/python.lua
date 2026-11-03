-- The Python venv with software's requirements and Playwright's headless
-- Chromium (for screenshotting daat pages). Built into the image instead
-- of on first start, so a new container is ready at once.
return {
    sources = {
        software = {git = "https://github.com/celleste-bio/software.git"},
    },
    build = {
        {name = "pyenv", from = "software",
         cmd = "python3 -m venv \"$PWD/venv\""
            .. " && venv/bin/pip install --no-cache-dir --timeout 120 --retries 10 -r requirements.txt playwright"
            .. " && PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright venv/bin/playwright install --with-deps chromium",
         install = {["venv"] = "pyenv"}},
    },
    env = {PLAYWRIGHT_BROWSERS_PATH = "/opt/ms-playwright"},
    links = {
        {path = "/root/pyenv", target = "pyenv"},
    },
    verify = {"/root/pyenv/bin/python -c 'import pandas, sqlalchemy, playwright'"},
}
