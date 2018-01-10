QuNotes - it is an iOS note taking application that is compatible with [Quiver's data format](https://github.com/HappenApps/Quiver/wiki/Quiver-Data-Format). Quiver's data format is a simple JSON files. Because of it you avoids vendor lock, you can write your own extensions and of course you can use tools like git to version control all your notes.

### Requirements

* iOS 11
* Swift 4
* Xcode 9

### Content

* [Overview](#overview)
* [Installation](#installation)
* [Roadmap](#roadmap)

## Overview <a name="overview"></a>
There a lot of note taking apps in the app store. But QuNotes is special. I am not kidding. Few reasons why this note taking app is special:

* App uses Quiver's data format. It means that all your notes are plain json files. And you can read and write to the same Quiver's library, that maybe already exists on your wonderful mac.
* App is open sourced. It means everyone can contribute.
* App is build with high quality code: logic is developed by using TDD, UI is developed in code by using playgrounds, there is accessability support, localizations and so on.
* App doesn't store any of data in private backend. It means all information is truly yours and we doesn't know your secrets.

### Overview for developers:

App logic is separated in Core framework. This separation for now is required to speed up tests and build time. In future we will be able to reuse all logic on different platforms(mac, app watch, ..).

App is not using storyboards or xibs. All UI is developed in code. UI is separated in UI framework. We have to do it because we want to preview and interact with UI in swift playgrounds. When developing something new for UI workflow looks like this:

1. Make changes in UI code
2. Build QuNotesUI framework
3. View and interact with UI in appropriate playground file
4. Repeat if something went wrong

Also I'm not using auto layout. Auto layout is slow and unpleasant, there is better alternatives. Just read this quote:
> "UIKit Auto Layout and InterfaceBuilder are not supported by Texture. It is worth noting that both of these technologies are not permitted in established and disciplined iOS development teams, such as at Facebook, Instagram, and Pinterest"
>
> -- <cite>[Pinterest/Facebook Texture's documentation](http://texturegroup.org/docs/faq.html#asyncdisplaykit-does-not-support-uikit-auto-layout-or-interfacebuilder)</cite>

I don't like mocks and stubs. But I like unit tests. To get rid of mock and stubs I'm separating decision making code from decision execution code. Core and UI logic is developed by using concept of functional core: in the codebase there's no mocks/stubs at all.

Sad news if you don't like functional programming: I'm trying to use it as much as I can, eg I'm using functional lenses for structs modification.


## Installation <a name="installation"></a>
TODO
## Roadmap <a name="roadmap"></a>

Project is not using waterfall model and therefore roadmap is a subject to change. But still it represents currently planned features:

- [ ] Accessability support
- [ ] Markdown editor & viewer
- [ ] LaTeX viewer
- [ ] Tags
- [ ] Nested notebooks
- [ ] Diagrams viewer
- [ ] iCloud integration
- [ ] LaTeX editor
- [ ] Global full-text search
- [ ] System app search integration
- [ ] Drag&Drop
- [ ] Safari integration
- [ ] Siri integration
- [ ] Enhanced iPad support
- [ ] Diagrams editor?
- [ ] Theme customization?
- [ ] Exporting(pdf, html and so on)?

## License
GNU General Public License v3.0
