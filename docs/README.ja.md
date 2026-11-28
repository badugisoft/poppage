[English](../README.md) | [한국어](README.ko.md) | [简体中文](README.zh-Hans.md) | 日本語 | [Español](README.es.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [tlhIngan Hol](README.tlh.md)

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#動作要件)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#動作要件)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

よく使うウェブサイトを macOS のメニューバーに固定し、ポップオーバーで素早く開閉できる軽量な Swift 製メニューバーアプリです。

[公式サイト](https://badugisoft.github.io/poppage/) · [最新版をダウンロード](https://github.com/badugisoft/poppage/releases/latest) · [スクリーンショット](#スクリーンショット) · [主な機能](#主な機能) · [ショートカット](#キーボードショートカット) · [変更履歴](../CHANGELOG.md)

## PopPage を作った理由

**MenubarX**、**FloatBrowser**、**MenuBox** など、同様の macOS メニューバー向けブラウザアプリや、さらに多機能なアプリはすでに数多く存在します。PopPage は、余計な機能を増やさず本当に必要な機能（ページごとのアイコン設定、遷移ポリシー、カスタム HTTP ヘッダー、設定の書き出し/読み込みなど）だけを備えた、**完全無料**で**軽量**なネイティブアプリを求めて作られました。

このアプリは **100% Antigravity で開発**されています。

## スクリーンショット

| ポップオーバーウインドウ | ページ設定 | アプリ設定 |
| :---: | :---: | :---: |
| ![ポップオーバーウインドウ](images/screenshot-popover.png) | ![ページ設定](images/screenshot-page-settings.png) | ![アプリ設定](images/screenshot-app-settings.png) |

## ダウンロードとインストール

1. [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest) から署名・公証済みの最新 `.dmg` または `.zip`（Apple Silicon）をダウンロードします。
2. `.dmg` を開く（または `.zip` を展開する）し、**PopPage.app** を `/Applications` へドラッグします。
3. アプリケーションフォルダまたは Spotlight から **PopPage** を起動します。

> Intel（`x86_64`）Mac 向けのビルド済みバイナリは配布していないため、必要な場合は[ソースからビルド](#ソースからビルド)してください。

## 主な機能

- **ページ管理**: 管理ウインドウからウェブサイトの追加、編集、削除、並び替え、有効/無効の切り替えが可能
- **メニューバーアイコンのカスタマイズ**: ウェブサイトのファビコンを自動取得するほか、任意のテキストやカスタム画像（テンプレートモード対応）を設定可能
- **ポップオーバーの開閉とフォーカス動作**: メニューバーアイコンのクリックで開閉し、フォーカスが外れたときに自動で閉じるかどうかを設定可能
- **開閉アニメーション**: ページごとにポップオーバーアニメーションのオン/オフを設定可能
- **新規ウインドウとページ遷移ポリシー**:
  - `target="_blank"` などの新規ウインドウリンクをデフォルトの外部ブラウザで開く設定
  - ページ内の遷移挙動（`移動しない` / `外部ブラウザで開く` / `ポップオーバー内で移動`）を選択可能
- **カスタム HTTP ヘッダー**: ページごとに HTTP/HTTPS リクエストヘッダー（`User-Agent` を含む）を追加、有効/無効切り替え、削除可能
- **Web サイトデータ管理**: ページごと（ドメイン単位）または設定から全ページの Cookie、ストレージ、キャッシュを選択して消去可能
- **ポップオーバーサイズとリサイズ**: デフォルトの幅・高さを設定し、右下のグリップをドラッグしてサイズ変更および変更サイズの記憶が可能
- **拡大率コントロール**: ページごとのデフォルト拡大率と、変更後の拡大率を記憶する設定に対応
- **キーボードショートカット**: ページごとに有効/無効を切り替えられるショートカットと、トグル横の情報ボタンから開けるショートカット一覧ポップオーバーを提供
- **下部ツールバーとオーバーレイ**: 戻る/進む、再読み込み、拡大/縮小ボタンの表示切り替え、およびツールバーをウェブページ上に重ねて背景不透明度を調整する設定が可能
- **ツールバー背景色の自動同期**: ウェブページの背景色に合わせて下部ツールバーの配色を自動調整
- **アプリ設定**: 管理ウインドウ左下の「設定」タブから、ログイン時自動起動、アプリ内言語（`システムデフォルト` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`）、設定の JSON 書き出し/読み込み（ページ、カスタムアイコン、言語設定を含む）が可能
- **多言語対応**: 英語（デフォルト）、韓国語、簡体字中国語、日本語、スペイン語、ドイツ語、フランス語、クリンゴン語に対応

## キーボードショートカット

ページ設定で**キーボードショートカットを有効にする**がオンのとき、ポップオーバー内で利用できます：

| ショートカット | 動作 |
| :---: | :--- |
| `⌘ +` | 拡大 |
| `⌘ -` | 縮小 |
| `⌘ 0` | リセット |
| `⌘ [` | 戻る |
| `⌘ ]` | 進む |
| `⌘ R` | 再読み込み |

## 動作要件

- macOS 14.0 以降
- Xcode / Swift 6 ツールチェーン（ソースからビルドする場合）

## ソースからビルド

```bash
# 利用可能なターゲット一覧を表示
make help

# デバッグ / リリースビルド
make build
make release

# .app バンドルを作成 (build/PopPage.app)
make app

# ビルドして起動
make run

# /Applications へインストール（または INSTALL_DIR=/任意のパス make install）
make install
make uninstall

# AppIcon.icns の再生成および plist/strings の構文チェック
make icon
make lint

# ビルド成果物を削除
make clean
```

## データ保存場所

- ページ設定: `~/Library/Application Support/PopPage/pages.json`
- キャッシュ済みファビコンとカスタム画像: `~/Library/Application Support/PopPage/icons/`
- アプリ言語設定: `~/Library/Preferences/com.badugisoft.poppage.plist`
