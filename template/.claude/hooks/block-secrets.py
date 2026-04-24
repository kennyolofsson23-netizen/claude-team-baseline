"""PreToolUse hook for Write/Edit — blocks writing to secret/binary files.

Allows .env/.env.local (dev config), blocks actual credential files.
"""
import sys
import json
import os

data = json.load(sys.stdin)
tool_input = data.get("tool_input", {})
file_path = tool_input.get("file_path", "")

basename = os.path.basename(file_path).lower()
ext = os.path.splitext(file_path)[1].lower()

# Allow dev env files — these are just config, not secrets
ALLOWED_ENV = {".env", ".env.local", ".env.development", ".env.test", ".env.example"}

# Block actual credential/key files
BLOCKED_FILES = {
    ".env.production", ".env.staging",
    "credentials.json", "secrets.json", "serviceaccount.json",
    "id_rsa", "id_ed25519", ".npmrc", ".pypirc",
}

if basename in BLOCKED_FILES:
    print(
        f"BLOCKED: Cannot write to '{basename}'. "
        f"Production secrets and credential files must be edited manually.",
        file=sys.stderr,
    )
    sys.exit(2)

# Block image/binary files — but allow in standard asset directories
# where logos, favicons, and product images legitimately live.
BLOCKED_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".webp", ".avif"}
IMAGE_ALLOW_PREFIXES = (
    "public/", "static/", "assets/",
    "src/static/", "src/assets/", "src/templates/static/",
)

if ext in BLOCKED_EXTENSIONS:
    path_lower_img = file_path.replace("\\", "/").lower()
    allowed = any(f"/{p}" in "/" + path_lower_img or path_lower_img.startswith(p)
                  for p in IMAGE_ALLOW_PREFIXES)
    if not allowed:
        print(
            f"BLOCKED: Writing '{ext}' outside asset directories. "
            f"Image files belong in: {', '.join(IMAGE_ALLOW_PREFIXES)}",
            file=sys.stderr,
        )
        sys.exit(2)

# Block if path contains common secret directories
SECRET_DIRS = {"/.ssh/", "/secrets/", "/private/"}
path_lower = file_path.replace("\\", "/").lower()
for secret_dir in SECRET_DIRS:
    if secret_dir in path_lower:
        print(
            f"BLOCKED: Cannot write to path containing '{secret_dir}'. "
            f"This looks like a sensitive directory.",
            file=sys.stderr,
        )
        sys.exit(2)

sys.exit(0)
