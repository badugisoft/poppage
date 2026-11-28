[English](../README.md) | [한국어](README.ko.md) | [简体中文](README.zh-Hans.md) | [日本語](README.ja.md) | [Español](README.es.md) | [Deutsch](README.de.md) | Français | [tlhIngan Hol](README.tlh.md)

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#prérequis)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#prérequis)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

Une application macOS légère de barre des menus écrite en Swift pour épingler des sites web et les ouvrir rapidement dans un popover.

[Site web](https://badugisoft.github.io/poppage/) · [Télécharger la dernière version](https://github.com/badugisoft/poppage/releases/latest) · [Captures d'écran](#captures-décran) · [Fonctionnalités](#fonctionnalités) · [Raccourcis](#raccourcis-clavier) · [Changelog](../CHANGELOG.md)

## Pourquoi PopPage ?

Il existe déjà de nombreuses applications similaires de navigateur dans la barre des menus macOS — parfois bien plus riches en fonctionnalités — comme **MenubarX**, **FloatBrowser** et **MenuBox**. PopPage a été créée pour répondre au besoin d'une application native **entièrement gratuite** et **légère**, concentrée uniquement sur les fonctionnalités essentielles (personnalisation d'icône par page, règles de navigation, en-têtes HTTP personnalisés et export/import des réglages), sans superflu.

Cette application a été **conçue à 100 % avec Antigravity**.

## Captures d'écran

| Fenêtre Popover | Réglages de page | Réglages de l'application |
| :---: | :---: | :---: |
| ![Fenêtre Popover](images/screenshot-popover.png) | ![Réglages de page](images/screenshot-page-settings.png) | ![Réglages de l'application](images/screenshot-app-settings.png) |

## Téléchargement et installation

1. Téléchargez la dernière archive `.dmg` ou `.zip` (Apple Silicon, signée et notariée) depuis [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest).
2. Ouvrez le `.dmg` (ou extrayez le `.zip`) et glissez **PopPage.app** dans `/Applications`.
3. Lancez **PopPage** depuis Applications ou Spotlight.

> Les binaires précompilés n'incluent pas Intel (`x86_64`) ; veuillez [compiler depuis les sources](#compiler-depuis-les-sources) si nécessaire.

## Fonctionnalités

- **Gestion des pages** : Ajoutez, modifiez, supprimez, réorganisez et activez/désactivez des sites web depuis la fenêtre de gestion
- **Personnalisation de l'icône** : Récupération automatique des favicons, texte personnalisé ou image personnalisée (avec mode modèle)
- **Ouverture et perte de focus** : Cliquez sur l'icône de la barre des menus pour ouvrir/fermer le popover, avec fermeture automatique optionnelle à la perte de focus
- **Animation d'ouverture/fermeture** : Option par page pour activer ou désactiver l'animation
- **Politiques de nouvelles fenêtres et de navigation** :
  - Ouvrir les liens de nouvelle fenêtre (`target="_blank"`, etc.) dans le navigateur externe par défaut
  - Configurer la navigation de page (`Ne pas naviguer` / `Ouvrir dans un navigateur externe` / `Naviguer dans le popover`)
- **En-têtes HTTP personnalisés** : Ajoutez, activez/désactivez et supprimez des en-têtes HTTP/HTTPS par page (y compris `User-Agent`)
- **Gestion des données de site web** : Effacez sélectivement les cookies, le stockage ou le cache par page (par domaine) ou pour toutes les pages depuis les Réglages
- **Taille et redimensionnement** : Définissez la largeur/hauteur par défaut, redimensionnez via la poignée en bas à droite et mémorisez éventuellement la taille modifiée
- **Contrôle du zoom** : Définissez un niveau de zoom par défaut par page et mémorisez éventuellement le zoom modifié
- **Raccourcis clavier** : Raccourcis activables par page avec un popover de référence compact à côté de l'interrupteur
- **Barre inférieure et superposition** : Affichez ou masquez les boutons Précédent/Suivant, Recharger et Zoom, ou superposez la barre sur la page web avec opacité réglable
- **Arrière-plan adaptatif** : Adapte automatiquement la couleur de la barre inférieure à celle de la page web
- **Réglages de l'application** : Configurez le lancement à l'ouverture de session, la langue (`Système par défaut` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`) et exportez/importez les réglages (pages, icônes personnalisées et langue) au format JSON depuis l'onglet Réglages
- **Localisation** : Prend en charge l'anglais (par défaut), le coréen, le chinois simplifié, le japonais, l'espagnol, l'allemand, le français et le klingon

## Raccourcis clavier

Disponibles dans le popover lorsque **Activer les raccourcis clavier** est activé pour la page :

| Raccourci | Action |
| :---: | :--- |
| `⌘ +` | Zoom avant |
| `⌘ -` | Zoom arrière |
| `⌘ 0` | Réinitialiser le zoom |
| `⌘ [` | Précédent |
| `⌘ ]` | Suivant |
| `⌘ R` | Recharger |

## Prérequis

- macOS 14.0 ou ultérieur
- Xcode / chaîne d'outils Swift 6 (pour compiler depuis les sources)

## Compiler depuis les sources

```bash
# Afficher toutes les cibles disponibles
make help

# Compilation debug / release
make build
make release

# Créer le bundle .app (build/PopPage.app)
make app

# Compiler et lancer
make run

# Installer dans /Applications (ou INSTALL_DIR=/chemin make install)
make install
make uninstall

# Régénérer AppIcon.icns ou valider plist/strings
make icon
make lint

# Nettoyer les fichiers de compilation
make clean
```

## Stockage des données

- Configuration des pages : `~/Library/Application Support/PopPage/pages.json`
- Favicons en cache et images personnalisées : `~/Library/Application Support/PopPage/icons/`
- Préférence de langue : `~/Library/Preferences/com.badugisoft.poppage.plist`
