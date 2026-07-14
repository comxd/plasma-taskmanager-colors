/*
    SPDX-FileCopyrightText: 2026 ComExpertise
    SPDX-License-Identifier: GPL-2.0-or-later
*/

function hasNyan(color) {
    return (color || "").endsWith(":nyan");
}

function stripNyan(color) {
    return (color || "").replace(/:nyan$/, "");
}

function withNyan(base) {
    return (base || "") + ":nyan";
}

function colorToHex(c) {
    var r = Math.round(c.r * 255);
    var g = Math.round(c.g * 255);
    var b = Math.round(c.b * 255);
    return "#" + ((1 << 24) | (r << 16) | (g << 8) | b).toString(16).slice(1);
}

// RGB (0-1) → HSL (0-1)
function rgbToHsl(r, g, b) {
    var max = Math.max(r, g, b);
    var min = Math.min(r, g, b);
    var h = 0, s = 0, l = (max + min) / 2;

    if (max !== min) {
        var d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        if (max === r) {
            h = (g - b) / d + (g < b ? 6 : 0);
        } else if (max === g) {
            h = (b - r) / d + 2;
        } else {
            h = (r - g) / d + 4;
        }
        h /= 6;
    }

    return {h: h, s: s, l: l};
}

// HSL (0-1) → RGB (0-1)
function hslToRgb(h, s, l) {
    if (s === 0) {
        return {r: l, g: l, b: l};
    }

    function hue2rgb(p, q, t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
    }

    var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    var p = 2 * l - q;

    return {
        r: hue2rgb(p, q, h + 1/3),
        g: hue2rgb(p, q, h),
        b: hue2rgb(p, q, h - 1/3)
    };
}

// Partial desaturation: factor 0-1 (0.3 = keep 30% saturation), slight lightness reduction
function desaturatePartial(color, factor) {
    var hsl = rgbToHsl(color.r, color.g, color.b);
    hsl.s *= factor;
    hsl.l *= 0.85;
    var rgb = hslToRgb(hsl.h, hsl.s, hsl.l);
    return Qt.rgba(rgb.r, rgb.g, rgb.b, color.a);
}

// Linear interpolation between two colors, preserves original alpha
function tintWithAlpha(color, tintColor, factor) {
    var inv = 1 - factor;
    var r = color.r * inv + tintColor.r * factor;
    var g = color.g * inv + tintColor.g * factor;
    var b = color.b * inv + tintColor.b * factor;
    return Qt.rgba(r, g, b, color.a);
}
