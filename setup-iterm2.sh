#!/usr/bin/env zsh
# iTerm2 configuration: fonts, Cursor Dark color scheme, AI settings
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo "${GREEN}==>${NC} $*"; }
warn()    { echo "${YELLOW}==> WARN:${NC} $*"; }
success() { echo "${GREEN}==> DONE:${NC} $*"; }

# ── Check iTerm2 is installed ───────────────────────────────────────────────
if [[ ! -d "/Applications/iTerm.app" && ! -d "$HOME/Applications/iTerm.app" ]]; then
  warn "iTerm2 not found — install it first (brew install --cask iterm2)"
  exit 1
fi

# ── Quit iTerm2 so plist changes aren't overwritten on exit ─────────────────
info "Closing iTerm2 (required to safely write preferences)..."
osascript -e 'tell application "iTerm2" to quit' 2>/dev/null || true
sleep 1

# ── Apply preferences via Python plistlib ───────────────────────────────────
info "Applying iTerm2 preferences..."
python3 << 'PYEOF'
import plistlib, subprocess, sys

def color(r, g, b, a=1.0):
    return {'Red Component': r, 'Green Component': g,
            'Blue Component': b, 'Alpha Component': a, 'Color Space': 'sRGB'}

# ── Cursor Dark palette ──────────────────────────────────────────────────────
cursor_dark = {
    'Ansi 0 Color':  color(0.165, 0.165, 0.165),   # Black
    'Ansi 1 Color':  color(0.749, 0.380, 0.416),   # Red
    'Ansi 2 Color':  color(0.639, 0.745, 0.549),   # Green
    'Ansi 3 Color':  color(0.922, 0.796, 0.545),   # Yellow
    'Ansi 4 Color':  color(0.506, 0.631, 0.757),   # Blue
    'Ansi 5 Color':  color(0.706, 0.557, 0.678),   # Magenta
    'Ansi 6 Color':  color(0.533, 0.753, 0.816),   # Cyan
    'Ansi 15 Color': color(1.0,   1.0,   1.0),     # White
}

bg_dark = color(0.078, 0.078, 0.078)

# ── Load current prefs ───────────────────────────────────────────────────────
result = subprocess.run(
    ['defaults', 'export', 'com.googlecode.iterm2', '-'],
    capture_output=True, check=True
)
prefs = plistlib.loads(result.stdout)

# ── Custom Color Presets ─────────────────────────────────────────────────────
if 'Custom Color Presets' not in prefs:
    prefs['Custom Color Presets'] = {}
prefs['Custom Color Presets']['Cursor Dark'] = cursor_dark
print("  [ok] Added 'Cursor Dark' color preset")

# ── Profile settings ─────────────────────────────────────────────────────────
profiles = prefs.get('New Bookmarks', [])
if not profiles:
    print("  [warn] No profiles found — skipping profile settings")
else:
    p = profiles[0]

    # Font
    p['Normal Font'] = 'CaskaydiaMonoNF-Regular 13'
    p['Non Ascii Font'] = 'Monaco 12'
    p['ASCII Anti Aliased'] = True
    p['Non-ASCII Anti Aliased'] = True
    print("  [ok] Font set to CaskaydiaMonoNF-Regular 13 / Monaco 12")

    # Background color — update dark variant and base
    p['Background Color (Dark)'] = bg_dark
    p['Background Color'] = bg_dark
    print("  [ok] Background color set to (0.078, 0.078, 0.078)")

    # Apply Cursor Dark ANSI colors (base + Dark variant)
    for key, val in cursor_dark.items():
        p[key] = val
        p[key.replace(' Color', ' Color (Dark)')] = val
    print("  [ok] Cursor Dark ANSI colors applied to profile")

    prefs['New Bookmarks'] = profiles

# ── AI settings ──────────────────────────────────────────────────────────────
prefs['AiModel'] = 'gpt-4.1'
prefs['AiMaxTokens'] = 1_000_000
prefs['AiResponseMaxTokens'] = 1_000_000
prefs['AIFeatureFunctionCalling'] = True
prefs['AIFeatureHostedWebSearch'] = True
prefs['AIFeatureHostedCodeInterpeter'] = True
prefs['AIFeatureStreamingResponses'] = True
print("  [ok] AI: gpt-4.1, max tokens 1,000,000, all features enabled")

# ── Write back ───────────────────────────────────────────────────────────────
xml = plistlib.dumps(prefs, fmt=plistlib.FMT_XML)
with open('/tmp/iterm2_prefs_update.plist', 'wb') as f:
    f.write(xml)

subprocess.run(
    ['defaults', 'import', 'com.googlecode.iterm2', '/tmp/iterm2_prefs_update.plist'],
    check=True
)
print("  [ok] Preferences imported")
PYEOF

success "iTerm2 preferences applied"
echo ""
echo "Next steps:"
echo "  1. Reopen iTerm2"
echo "  2. Go to Preferences → Profiles → Colors → Color Presets → 'Cursor Dark'"
echo "     (the preset is installed; select it to activate it on the profile)"
echo "  3. Verify font: Preferences → Profiles → Text → Font"
echo "     Should show CaskaydiaMonoNF-Regular 13"
echo "     (install font first if missing: brew install --cask font-caskaydia-mono-nerd-font)"
