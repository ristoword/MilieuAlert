"""Compose Google Play assets: 512 icon, 1024x500 feature, 1080x1920 screenshots."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(r"C:\Users\PC\OneDrive\Documenti\Desktop\MilieuAllert")
OUT = ROOT / "store" / "play"
LOGO = ROOT / "assets" / "icon" / "logo.png"
ICON512 = ROOT / "web" / "icons" / "Icon-512.png"
GEN_FEATURE = Path(
    r"C:\Users\PC\.cursor\projects\c-Users-PC-OneDrive-Documenti-Desktop-MilieuAllert\assets\feature-graphic.png"
)
FONT_REG = Path(r"C:\Windows\Fonts\segoeui.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\segoeuib.ttf")

NAVY = (10, 10, 26, 255)
CYAN = (0, 229, 255, 255)
WHITE = (255, 255, 255, 255)
INK = (28, 28, 30, 255)
MUTED = (110, 110, 115, 255)
BLUE = (0, 122, 255, 255)
ORANGE = (255, 159, 10, 255)
CARD = (255, 255, 255, 245)
DARK_CARD = (28, 28, 30, 235)


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size)


def rounded_rect(draw: ImageDraw.ImageDraw, xy, r, fill):
    draw.rounded_rectangle(xy, radius=r, fill=fill)


def paste_logo(canvas: Image.Image, size: int, xy) -> None:
    logo = Image.open(LOGO).convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
    canvas.alpha_composite(logo, xy)


def draw_street_map(w: int, h: int) -> Image.Image:
    img = Image.new("RGBA", (w, h), NAVY)
    draw = ImageDraw.Draw(img)
    for i in range(0, w, 90):
        draw.line([(i, 0), (i + 40, h)], fill=(30, 48, 72, 255), width=10)
    for j in range(0, h, 110):
        draw.line([(0, j), (w, j + 20)], fill=(24, 40, 62, 255), width=8)
    # LEZ overlay
    poly = [(80, 420), (980, 380), (1020, 1280), (40, 1420)]
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.polygon(poly, fill=(0, 196, 216, 55), outline=(0, 196, 216, 200))
    img = Image.alpha_composite(img, overlay)
    # Route
    d = ImageDraw.Draw(img)
    d.line([(180, 1700), (320, 1280), (540, 980), (620, 640), (900, 220)], fill=BLUE, width=18)
    d.line([(180, 1700), (320, 1280), (540, 980), (620, 640), (900, 220)], fill=WHITE, width=6)
    return img


def screenshot_map() -> Image.Image:
    img = draw_street_map(1080, 1920)
    paste_logo(img, 88, (40, 48))
    d = ImageDraw.Draw(img)
    d.text((148, 58), "MilieuAlert", font=font(FONT_BOLD, 42), fill=WHITE)
    d.text((148, 112), "milieuzone", font=font(FONT_REG, 26), fill=CYAN)
    # status chip
    rounded_rect(d, (820, 56, 1040, 128), 28, (0, 0, 0, 180))
    d.text((858, 74), "42 km/h", font=font(FONT_BOLD, 32), fill=CYAN)
    # bottom card
    rounded_rect(d, (40, 1420, 1040, 1860), 36, CARD)
    d.text((80, 1460), "Milieuzone Amsterdam", font=font(FONT_BOLD, 40), fill=INK)
    d.text((80, 1524), "Ingresso tra 400 m", font=font(FONT_REG, 30), fill=MUTED)
    d.text((80, 1600), "EcoEntry  ·  diesel Euro 4", font=font(FONT_BOLD, 32), fill=(0, 140, 90, 255))
    d.text((80, 1660), "Accesso consentito", font=font(FONT_REG, 30), fill=INK)
    d.text((80, 1740), "La tua auto, la tua zona, il tuo accesso", font=font(FONT_REG, 26), fill=MUTED)
    return img.convert("RGB")


def screenshot_report() -> Image.Image:
    img = draw_street_map(1080, 1920).filter(ImageFilter.GaussianBlur(6))
    d = ImageDraw.Draw(img)
    rounded_rect(d, (0, 720, 1080, 1920), 40, DARK_CARD)
    paste_logo(img, 72, (48, 760))
    d.text((140, 772), "Segnala", font=font(FONT_BOLD, 44), fill=WHITE)
    d.text((140, 830), "Autovelox e incidenti sul percorso", font=font(FONT_REG, 24), fill=(180, 220, 230, 255))
    items = [
        ("Autovelox fisso", "Telecamera della velocita sul tratto"),
        ("Autovelox mobile", "Flitser non sulla mappa ufficiale"),
        ("Coda", "Rallentamento segnalato dai conducenti"),
        ("Incidente", "Ostacolo o blocco di corsia"),
    ]
    y = 920
    for title, sub in items:
        rounded_rect(d, (48, y, 1032, y + 150), 24, (40, 40, 48, 255))
        d.ellipse((80, y + 42, 148, y + 110), outline=CYAN, width=4)
        d.text((180, y + 32), title, font=font(FONT_BOLD, 34), fill=WHITE)
        d.text((180, y + 84), sub, font=font(FONT_REG, 24), fill=(170, 170, 180, 255))
        y += 170
    return img.convert("RGB")


def screenshot_vehicle() -> Image.Image:
    img = Image.new("RGBA", (1080, 1920), NAVY)
    d = ImageDraw.Draw(img)
    paste_logo(img, 120, (480, 72))
    title = "Il tuo veicolo"
    tw = d.textlength(title, font=font(FONT_BOLD, 48))
    d.text(((1080 - tw) / 2, 220), title, font=font(FONT_BOLD, 48), fill=WHITE)
    sub = "EcoEntry confronta Euro e carburante con la zona"
    sw = d.textlength(sub, font=font(FONT_REG, 24))
    d.text(((1080 - sw) / 2, 286), sub, font=font(FONT_REG, 24), fill=CYAN)
    rows = [
        ("Carburante", "Diesel"),
        ("Classe Euro", "Euro 4"),
        ("Paese", "Paesi Bassi"),
        ("Targa (facoltativa)", "Non inserita"),
    ]
    y = 380
    for label, value in rows:
        rounded_rect(d, (64, y, 1016, y + 150), 28, (18, 18, 40, 255))
        d.text((96, y + 28), label, font=font(FONT_REG, 24), fill=(140, 170, 180, 255))
        d.text((96, y + 72), value, font=font(FONT_BOLD, 40), fill=WHITE)
        y += 176
    rounded_rect(d, (64, 1180, 1016, 1320), 28, CYAN)
    btn = "Salva EcoEntry"
    bw = d.textlength(btn, font=font(FONT_BOLD, 36))
    d.text(((1080 - bw) / 2, 1224), btn, font=font(FONT_BOLD, 36), fill=NAVY)
    motto = "La tua auto, la tua zona, il tuo accesso"
    mw = d.textlength(motto, font=font(FONT_REG, 26))
    d.text(((1080 - mw) / 2, 1400), motto, font=font(FONT_REG, 26), fill=WHITE)
    return img.convert("RGB")


def screenshot_nav() -> Image.Image:
    img = draw_street_map(1080, 1920)
    d = ImageDraw.Draw(img)
    rounded_rect(d, (40, 48, 1040, 280), 28, CARD)
    d.text((72, 72), "Fra 200 m", font=font(FONT_REG, 26), fill=MUTED)
    d.text((72, 112), "Svolta a destra", font=font(FONT_BOLD, 44), fill=INK)
    d.text((72, 180), "Nieuwezijds Voorburgwal", font=font(FONT_REG, 28), fill=INK)
    rounded_rect(d, (40, 320, 1040, 470), 24, (255, 159, 10, 240))
    d.text((72, 348), "Autovelox tra 350 m", font=font(FONT_BOLD, 36), fill=INK)
    d.text((72, 400), "Limite 50 km/h  ·  rallenta", font=font(FONT_REG, 28), fill=INK)
    rounded_rect(d, (40, 1680, 1040, 1860), 32, CARD)
    d.text((72, 1716), "12 min   ·   4,2 km", font=font(FONT_BOLD, 36), fill=INK)
    d.text((72, 1776), "MilieuAlert  ·  milieuzone", font=font(FONT_REG, 26), fill=MUTED)
    paste_logo(img, 72, (930, 1728))
    return img.convert("RGB")


def feature_graphic() -> Image.Image:
    out = Image.new("RGBA", (1024, 500), NAVY)
    plate = Image.new("RGBA", (400, 400), (255, 255, 255, 255))
    out.alpha_composite(plate, (40, 50))
    logo = Image.open(LOGO).convert("RGBA").resize((380, 380), Image.Resampling.LANCZOS)
    out.alpha_composite(logo, (50, 60))
    d = ImageDraw.Draw(out)
    d.text((470, 110), "MilieuAlert", font=font(FONT_BOLD, 68), fill=WHITE)
    d.text((470, 200), "milieuzone", font=font(FONT_BOLD, 42), fill=CYAN)
    d.text((470, 270), "ZTL  ·  LEZ  ·  EcoEntry", font=font(FONT_REG, 30), fill=(200, 230, 240, 255))
    d.text((470, 340), "La tua auto, la tua zona,", font=font(FONT_REG, 24), fill=(180, 200, 210, 255))
    d.text((470, 378), "il tuo accesso", font=font(FONT_REG, 24), fill=(180, 200, 210, 255))
    return out.convert("RGB")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    icon_src = ICON512 if ICON512.exists() else LOGO
    icon = Image.open(icon_src).convert("RGB").resize((512, 512), Image.Resampling.LANCZOS)
    icon.save(OUT / "icon-512.png", "PNG")
    feature_graphic().save(OUT / "feature-graphic.png", "PNG")
    screenshot_map().save(OUT / "screenshot-01-mappa.png", "PNG")
    screenshot_report().save(OUT / "screenshot-02-segnala.png", "PNG")
    screenshot_vehicle().save(OUT / "screenshot-03-veicolo.png", "PNG")
    screenshot_nav().save(OUT / "screenshot-04-navigazione.png", "PNG")
    for name in sorted(os.listdir(OUT)):
        p = OUT / name
        if p.suffix.lower() == ".png":
            im = Image.open(p)
            print(f"{name}: {im.size[0]}x{im.size[1]} {im.mode}")


if __name__ == "__main__":
    main()
