"""Export MilieuAlert brand icons to web, assets, native, and GS catalog."""
from pathlib import Path

from PIL import Image

ROOT = Path(r"C:\Users\PC\OneDrive\Documenti\Desktop\MilieuAllert")
GS_ROOT = Path(r"C:\Users\PC\OneDrive\Documenti\Desktop\gestione semplificata")
SRC_DIR = Path(
    r"C:\Users\PC\.cursor\projects\c-Users-PC-OneDrive-Documenti-Desktop-MilieuAllert\assets"
)
LOCKUP = SRC_DIR / "milieualert-logo-512.png"
ICON_ONLY = SRC_DIR / "milieualert-icon-only.png"


def load(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", img.size, (255, 255, 255, 255))
    return Image.alpha_composite(bg, img).convert("RGB")


def save_resized(img: Image.Image, dest: Path, size: int) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.Resampling.LANCZOS)
    out.save(dest, "PNG", optimize=True)


def save_copy(img: Image.Image, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    img.save(dest, "PNG", optimize=True)


def make_maskable(img: Image.Image, size: int, scale: float = 0.72) -> Image.Image:
    canvas = Image.new("RGB", (size, size), (255, 255, 255))
    inner = max(1, int(size * scale))
    placed = img.resize((inner, inner), Image.Resampling.LANCZOS)
    offset = (size - inner) // 2
    canvas.paste(placed, (offset, offset))
    return canvas


def main() -> None:
    lockup = load(LOCKUP)
    icon = load(ICON_ONLY)

    # Master copies in Flutter assets
    save_copy(lockup, ROOT / "assets/icon/logo.png")
    save_resized(lockup, ROOT / "assets/icon/logo-1024.png", 1024)
    save_copy(icon, ROOT / "assets/icon/app_icon.png")
    save_resized(icon, ROOT / "assets/icon/app_icon-1024.png", 1024)
    save_copy(lockup, ROOT / "assets/splash/logo.png")

    # PWA / web
    save_resized(lockup, ROOT / "web/icons/Icon-512.png", 512)
    save_resized(icon, ROOT / "web/icons/Icon-192.png", 192)
    save_resized(icon, ROOT / "web/favicon.png", 48)
    make_maskable(icon, 192).save(ROOT / "web/icons/Icon-maskable-192.png", "PNG", optimize=True)
    make_maskable(icon, 512).save(ROOT / "web/icons/Icon-maskable-512.png", "PNG", optimize=True)

    # Android launcher
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    res = ROOT / "android/app/src/main/res"
    for folder, size in android_sizes.items():
        save_resized(icon, res / folder / "ic_launcher.png", size)

    # iOS AppIcon
    ios_dir = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for name, size in ios_sizes.items():
        save_resized(icon, ios_dir / name, size)

    # macOS AppIcon
    mac_dir = ROOT / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    for size in (16, 32, 64, 128, 256, 512, 1024):
        save_resized(icon, mac_dir / f"app_icon_{size}.png", size)

    # Gestione Semplificata catalog
    gs_logos = GS_ROOT / "backend/src/public/assets/logos"
    save_resized(icon, gs_logos / "milieualert-192.png", 192)
    save_resized(lockup, gs_logos / "milieualert-512.png", 512)
    save_copy(lockup, gs_logos / "milieualert-logo.png")

    print("Exported MilieuAlert brand icons.")


if __name__ == "__main__":
    main()
