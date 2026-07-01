#!/usr/bin/env python3
"""Gera o ícone do app "Meu Dinheiro": um cofrinho branco sobre fundo verde.

Desenha em alta resolução (supersampling) e reduz para 1024x1024 com LANCZOS,
garantindo bordas suaves. Sem transparência/cantos arredondados — o iOS aplica
a máscara automaticamente.
"""

from PIL import Image, ImageDraw

FINAL = 1024
S = 4                      # fator de supersampling
SIZE = FINAL * S

WHITE = (255, 255, 255)
# Verde de destaque do app (AccentColor ~ 0.16, 0.55, 0.42)
GREEN_TOP = (63, 178, 138)
GREEN_BOTTOM = (24, 116, 88)
GREEN_DETAIL = (30, 120, 92)   # detalhes verdes sobre o branco (narinas, olho, anel)


def s(v: float) -> int:
    """Escala uma coordenada do espaço 1024 para o espaço supersampled."""
    return int(round(v * S))


def rounded_ellipse(draw, box, fill):
    draw.ellipse([s(box[0]), s(box[1]), s(box[2]), s(box[3])], fill=fill)


def make_background(img):
    """Degradê vertical do verde claro (topo) ao verde escuro (base)."""
    top = Image.new("RGB", (1, FINAL), 0)
    px = top.load()
    for y in range(FINAL):
        t = y / (FINAL - 1)
        r = round(GREEN_TOP[0] + (GREEN_BOTTOM[0] - GREEN_TOP[0]) * t)
        g = round(GREEN_TOP[1] + (GREEN_BOTTOM[1] - GREEN_TOP[1]) * t)
        b = round(GREEN_TOP[2] + (GREEN_BOTTOM[2] - GREEN_TOP[2]) * t)
        px[0, y] = (r, g, b)
    grad = top.resize((SIZE, SIZE))
    img.paste(grad, (0, 0))


def draw_piggy(draw):
    # --- Patinhas (atrás do corpo) ---
    for lx in (360, 560):
        draw.rounded_rectangle(
            [s(lx), s(690), s(lx + 90), s(788)],
            radius=s(30), fill=WHITE,
        )

    # --- Orelha ---
    draw.polygon(
        [(s(610), s(360)), (s(700), s(330)), (s(690), s(430))],
        fill=WHITE,
    )

    # --- Fenda de moedas (verde, no topo do corpo) ---
    draw.rounded_rectangle(
        [s(470), s(360), s(600), s(392)],
        radius=s(16), fill=GREEN_DETAIL,
    )

    # --- Corpo ---
    rounded_ellipse(draw, (250, 360, 774, 730), WHITE)

    # --- Focinho ---
    rounded_ellipse(draw, (170, 500, 360, 650), WHITE)
    # Narinas
    rounded_ellipse(draw, (222, 555, 250, 600), GREEN_DETAIL)
    rounded_ellipse(draw, (280, 555, 308, 600), GREEN_DETAIL)

    # --- Olho ---
    rounded_ellipse(draw, (352, 452, 392, 492), GREEN_DETAIL)

    # --- Rabinho (arco à direita) ---
    draw.arc(
        [s(740), s(470), s(830), s(560)],
        start=120, end=380, fill=WHITE, width=s(22),
    )


def draw_coin(draw):
    """Moeda branca genérica (clean), caindo na fenda."""
    cx, cy, r = 560, 250, 92
    # Disco externo
    draw.ellipse(
        [s(cx - r), s(cy - r), s(cx + r), s(cy + r)],
        fill=WHITE,
    )
    # Anel interno sutil para dar cara de moeda
    ri = r - 26
    draw.ellipse(
        [s(cx - ri), s(cy - ri), s(cx + ri), s(cy + ri)],
        outline=GREEN_DETAIL, width=s(9),
    )


def main():
    img = Image.new("RGB", (SIZE, SIZE))
    make_background(img)
    draw = ImageDraw.Draw(img)
    draw_piggy(draw)
    draw_coin(draw)

    icon = img.resize((FINAL, FINAL), Image.LANCZOS)
    out = "MoneyManager/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
    icon.save(out)
    print("Ícone salvo em", out)


if __name__ == "__main__":
    main()
