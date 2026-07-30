# ─────────── art ───────────
# clean audio metadata and rename files to track title
# usage: art [directory] [--no-feat|clean]

function art -d "clean audio metadata (flac/mp3)"
    set -l R (set_color red)
    set -l G (set_color green)
    set -l Y (set_color yellow)
    set -l P (set_color cba6f7)
    set -l D (set_color brblack)
    set -l N (set_color normal)

    set -l dir "$PWD"
    set -l clean_feat 0

    for arg in $argv
        switch "$arg"
            case --no-feat clean true 1
                set clean_feat 1
            case '*'
                if test -d "$arg"
                    set dir "$arg"
                end
        end
    end

    if not test -d "$dir"
        echo -s $R "󰅙 not a directory: $dir" $N
        return 1
    end

    if not command -v python3 >/dev/null 2>&1
        echo -s $R "󰅙 python3 not found" $N
        return 1
    end

    set -l env_args ART_DIR="$dir"
    if test $clean_feat -eq 1
        set -a env_args ART_CLEAN_FEAT=1
    end

    env $env_args python3 -c '
import os, re, sys, shutil, subprocess

try:
    from mutagen import File
except ImportError:
    print("mutagen not installed. run: sudo pacman -S python-mutagen")
    sys.exit(1)

def notify(msg, color="cba6f7", timeout=2000):
    if shutil.which("hyprctl"):
        subprocess.run(
            ["hyprctl", "notify", "-1", str(timeout), f"rgb({color})", msg],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )

def colored(color, text):
    return f"\033[38;2;{color[0]};{color[1]};{color[2]}m{text}\033[0m"

PURPLE = (203, 166, 247)
GREEN = (166, 227, 161)
YELLOW = (249, 226, 175)
RED = (243, 139, 186)
GRAY = (108, 112, 134)

dir_path = os.environ.get("ART_DIR", ".")
clean_feat = os.environ.get("ART_CLEAN_FEAT") == "1"
tags_to_remove = {
    "composer", "author", "studioproducer", "other instrument",
    "publisher", "isrc", "barcode", "copyright",
    "artists", "featuring", "main_artist",
}

feat_re = re.compile(
    r"\s*[\(\[]?(?:feat|ft|featuring)\.?\s*[\)\]]?.*$",
    re.IGNORECASE,
)

files = sorted(f for f in os.listdir(dir_path)
               if f.lower().endswith((".flac", ".mp3")))

total = len(files)
if total == 0:
    print(colored(GRAY, "no .flac/.mp3 files found"))
    notify("art: no audio files", color="f38ba8")
    sys.exit(0)

mode = " | no feat" if clean_feat else ""
print(colored(PURPLE, f"󰎆 art: {total} files{mode}"))
notify(f"art: {total} files{mode}", color="cba6f7")

ok = 0
skipped = 0
renamed = 0
errors = 0

for i, filename in enumerate(files, 1):
    filepath = os.path.join(dir_path, filename)
    try:
        audio = File(filepath, easy=True)
        if audio is None:
            print(colored(YELLOW, f"  [{i}/{total}] skip: {filename} (unsupported)"))
            skipped += 1
            continue
        if audio.tags is None:
            audio.add_tags()

        title = audio.tags.get("title", [None])[0]
        if not title:
            print(colored(YELLOW, f"  [{i}/{total}] skip: {filename} (no title)"))
            notify(f"art: skip {filename}", color="f9e2af")
            skipped += 1
            continue

        main = ""
        for key in ("albumartist", "artist"):
            val = audio.tags.get(key)
            if val:
                raw = val[0]
                # strip feat/ft/featuring from artist field
                raw = re.sub(r"\s*(?:feat\.?|ft\.?|featuring)\s+.*$", "", raw, flags=re.IGNORECASE)
                # split on /, &, ;, and \
                raw = re.sub(r"\s*[/&;]\s*", ", ", raw)
                main = raw.split(",")[0].strip()
                if main:
                    break
        if not main:
            print(colored(YELLOW, f"  [{i}/{total}] skip: {filename} (no artist)"))
            notify(f"art: skip {filename}", color="f9e2af")
            skipped += 1
            continue

        genre = audio.tags.get("genre")
        if genre:
            audio.tags["genre"] = genre[0].split("/")[0].strip()

        date = audio.tags.get("date")
        if date:
            audio.tags["date"] = re.sub(r"^(\d{4}).*", r"\1", date[0])

        audio.tags["artist"] = main
        audio.tags["albumartist"] = main

        for tag in list(audio.tags.keys()):
            if tag.lower() in tags_to_remove:
                del audio.tags[tag]

        original_title = title
        if clean_feat:
            title = feat_re.sub("", title).strip()
            if title != original_title:
                audio.tags["title"] = title

        audio.save()

        # sanitize characters invalid in filenames (keep metadata as-is)
        safe_title = re.sub(r"\s*/\s*", " - ", title).replace("\x00", "").strip()
        ext = os.path.splitext(filename)[1]
        new_name = f"{safe_title}{ext}"
        new_path = os.path.join(dir_path, new_name)
        if new_name == filename:
            print(colored(GREEN, f"  [{i}/{total}] 󰄬 {filename}"))
            notify(f"art: {title}", color="a6e3a1")
        elif os.path.exists(new_path):
            print(colored(RED, f"  [{i}/{total}] 󰅙 cannot rename: {new_name} already exists"))
            notify(f"art: rename conflict {title}", color="f38ba8")
            errors += 1
        else:
            os.rename(filepath, new_path)
            print(colored(PURPLE, f"  [{i}/{total}] 󰁔 {filename} -> {new_name}"))
            notify(f"art: {title}", color="cba6f7")
            renamed += 1
        ok += 1
    except Exception as e:
        print(colored(RED, f"  [{i}/{total}] 󰅙 error on {filename}: {e}"))
        notify(f"art: error {filename}", color="f38ba8")
        errors += 1

summary = f"art: {ok} ok, {renamed} renamed, {skipped} skipped, {errors} errors"
print(colored(GREEN, f"󰄬 {summary}"))
notify(summary, color="a6e3a1", timeout=3000)
' "$dir"

    return $status
end
