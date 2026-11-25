[English](../README.md) | [한국어](README.ko.md) | [简体中文](README.zh-Hans.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | tlhIngan Hol

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#poqlubogh)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#poqlubogh)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

Swift lo'bogh macOS HIDjolev jan 'oH PopPage'e', web Daqmey HIDjolevDaq polmeH 'ej Popover QorwaghDaq nom poSmoHmeH.

[Web Daq](https://badugisoft.github.io/poppage/) · [chu' QIn qem](https://github.com/badugisoft/poppage/releases/latest) · [nagh beQ](#nagh-beq) · [laHmey](#lahmey) · [leQ tIn](#leq-tin) · [Changelog](../CHANGELOG.md)

## qatlh PopPage?

macOS HIDjolev navwI'mey law' tu'lu' — latlh laHmey law' ghajbogh — chovnatlh: **MenubarX**, **FloatBrowser**, **MenuBox** je. 'ach **DIlbe'**, **tIS** jan wIpoQmo' PopPage wIchenmoHta', laH poQlu'bogh neH ngaSbogh (ghItlh Degh, vIH SeH, HTTP Headers, SeHlaw ngeH/qem je).

janvam **100% Antigravity lo'ta'bogh chenmoHlu'**.

## nagh beQ

| Popover Qorwagh | ghItlh SeHlaw | jan SeHlaw |
| :---: | :---: | :---: |
| ![Popover Qorwagh](images/screenshot-popover.png) | ![ghItlh SeHlaw](images/screenshot-page-settings.png) | ![jan SeHlaw](images/screenshot-app-settings.png) |

## qem & lan

1. [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest)vo' `.dmg` pagh `.zip` teywI' qem.
2. `.dmg` poSmoH 'ej `/Applications`Daq **PopPage.app** lan.
3. **PopPage** tagh.

## laHmey

- **ghItlh SeH**: SeH QorwaghDaq web Daq chel, choH, qIl, mIw choH, 'ej chu'/chu'Ha'
- **HIDjolev Degh choH**: Favicon qem, ghItlh lo', pagh nagh beQ wIv (Template mIw qap)
- **Popover poS/SoQ & buSHa'**: HIDjolev Degh 'uyDI' Popover poS/SoQ, 'ej buSHa'chugh SoQmoHlaH
- **poS/SoQ vIH**: Hoch ghItlhDaq vIH chu'/chu'Ha'
- **Qorwagh chu' & vIH SeH**:
  - Qorwagh chu' rarwI' (`target="_blank"`, etc.) Hur motlh navwI'Daq poSmoH
  - ghItlh vIH mIw wIv (`vIHQo'` / `Hur navwI'Daq poSmoH` / `naDev vIH`)
- **HTTP Headers**: Hoch ghItlhDaq HTTP/HTTPS Headers (`User-Agent` ngaSbogh) chel, chu'/chu'Ha', teq
- **Popover tIn & choH**: motlh juch/'ab cher, bIng nIHDaq tIn choH, 'ej choHta'bogh tIn qaw
- **tIn mIw SeH**: Hoch ghItlhDaq motlh tIn mIw cher, 'ej choHta'bogh tIn mIw qaw
- **leQ tIn**: Hoch ghItlhDaq lo'laH 'ej `i` leQ 'uyDI' De' mach 'ang
- **bIng jan SeHlaw**: DoH/ghoS, chenqa'moH, tIn/mach leQ 'ang/So', pagh ghItlh DungDaq lan 'ej 'em Hurgh choH
- **SeHlaw nguv choH**: ghItlh nguv rurmeH bIng jan SeHlaw nguv choH
- **SeHlaw**: bIng poSDaq SeHlawDaq taghDI' tagh, Hol (`pat motlh` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`), JSON SeHlaw ngeH/qem je SeH
- **Holmey**: English (motlh), 한국어, 简体中文, 日本語, Español, Deutsch, Français, tlhIngan Hol qap

## leQ tIn

| leQ | vIH |
| :---: | :--- |
| `⌘ +` | tInmoH |
| `⌘ -` | machmoH |
| `⌘ 0` | cherqa' |
| `⌘ [` | DoH |
| `⌘ ]` | ghoS |
| `⌘ R` | chenqa'moH |

## poQlu'bogh

- macOS 14.0 pagh chu'
- Xcode / Swift 6

## chenmoH, lan & tagh

```bash
# Hoch targets 'ang
make help

# Debug / Release chenmoH
make build
make release

# .app chenmoH (build/PopPage.app)
make app

# chenmoH 'ej tagh
make run

# /ApplicationsDaq lan (pagh INSTALL_DIR=/path make install)
make install
make uninstall

# AppIcon.icns chenmoHqa' pagh plist/strings ol
make icon
make lint

# chenmoHta'bogh teywI' qIl
make clean
```

## De' polbogh Daq

- ghItlh SeHlaw: `~/Library/Application Support/PopPage/pages.json`
- Favicon nagh beQ je: `~/Library/Application Support/PopPage/icons/`
- Hol SeHlaw: `~/Library/Preferences/com.badugisoft.poppage.plist`
