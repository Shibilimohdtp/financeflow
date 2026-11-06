"""Before/after screenshot sheets for a design-system slice.

Runs a capture test (tool/screenshots/*_test.dart) at the working tree and
at a base commit (in a temporary git worktree), then pastes the pairs side
by side, light and dark, into docs/design-system/screenshots/<slice>/.

    python tool/screenshots/compare.py <slice> <capture_test.dart> <name> [<name> ...] [--base HEAD]

<name> is the golden prefix without _light/_dark, e.g. sheet_loan.
Needs Pillow. The capture test must use only APIs that exist at both commits.
"""
import os
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw


def run(cmd, cwd):
    result = subprocess.run(
        cmd,
        cwd=cwd,
        shell=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    stdout = result.stdout or ""
    stderr = result.stderr or ""
    tail = (stdout + stderr).strip().splitlines()[-1:] or [""]
    print(f"[{os.path.basename(cwd)}] {cmd.split()[0]} ... {tail[0]}")
    return result.returncode


def compose(before_dir, after_dir, names, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    for name in names:
        tiles = []
        for mode in ("light", "dark"):
            for label, folder in (("before", before_dir), ("after", after_dir)):
                img = Image.open(os.path.join(folder, f"{name}_{mode}.png")).convert("RGB")
                tiles.append((f"{mode} · {label}", img))
        w, h = tiles[0][1].size
        pad, head = 12, 28
        sheet = Image.new("RGB", (4 * w + 5 * pad, h + head + 2 * pad), (40, 40, 40))
        draw = ImageDraw.Draw(sheet)
        for i, (label, img) in enumerate(tiles):
            x = pad + i * (w + pad)
            draw.text((x, pad), label, fill=(235, 235, 235))
            sheet.paste(img, (x, pad + head))
        target = os.path.join(out_dir, f"{name}.png")
        sheet.save(target, optimize=True)
        print("wrote", target)


def main():
    args = sys.argv[1:]
    base = "HEAD"
    if "--base" in args:
        i = args.index("--base")
        base = args[i + 1]
        del args[i:i + 2]
    slice_name, test_file, names = args[0], args[1], args[2:]
    repo = os.getcwd()
    golden_dir = os.path.join(repo, "tool", "screenshots", "goldens")

    if run(f"flutter test {test_file} --update-goldens", repo) != 0:
        sys.exit("capture failed on the working tree")

    tmp = tempfile.mkdtemp(prefix="ff_shots_")
    worktree = os.path.join(tmp, "base")
    try:
        if run(f'git worktree add --detach "{worktree}" {base}', repo) != 0:
            sys.exit("could not create worktree")
        os.makedirs(os.path.join(worktree, "tool", "screenshots"), exist_ok=True)
        shutil.copy(os.path.join(repo, test_file), os.path.join(worktree, test_file))
        # The font helper may have improved since the base commit.
        shutil.copy(os.path.join(repo, "test", "helpers", "app_fonts.dart"),
                    os.path.join(worktree, "test", "helpers", "app_fonts.dart"))
        run("flutter pub get --offline", worktree)
        if run(f"flutter test {test_file} --update-goldens", worktree) != 0:
            sys.exit("capture failed at the base commit")
        compose(os.path.join(worktree, "tool", "screenshots", "goldens"), golden_dir, names,
                os.path.join(repo, "docs", "design-system", "screenshots", slice_name))
    finally:
        subprocess.run(f'git worktree remove --force "{worktree}"', cwd=repo, shell=True)
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
