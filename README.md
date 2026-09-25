# ENACHE MARIUS OFFICIAL — SUBWAY SURFERS CITY ELITE UI DEMO

Standalone/local iOS UI demo.

## Included
- Black + neon blue ELITE interface
- Draggable menu panel
- Draggable EM bubble
- Hide/show panel
- Minimize/restore
- Green ON / red OFF state
- Live FPS counter using CADisplayLink
- Static status line:
  - `ScoreSystem.AddScore ×16 — ACTIVE`

## Important
This project is a standalone UI demo. It does not inject into Subway Surfers City
and does not connect to the game's online services.

## Build on macOS
Requires Xcode command line tools.

```bash
chmod +x build.sh
./build.sh
```

Output:

`build/SSC-ELITE-Demo-unsigned.ipa`

The IPA is unsigned and must be signed with your own valid signing method before installation.

## GitHub Actions
The included workflow can build the unsigned IPA on `macos-latest`.
