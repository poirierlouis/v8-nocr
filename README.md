# V8 – no Chromium

This repository is meant to build Google's [V8] JavaScript engine as a static
library (monolith). Its purpose is to provide a common place to maintain
a non-Chromium-based build pipeline of V8.

It still uses [GN] and [Ninja] but patches are applied based on the version
number when required. This is mostly meant to support Windows. As of [September
2024], Google dropped support for MSVC compiler / MSVC STL headers.

<!-- Links -->
[V8]: https://v8.dev/docs
[GN]: https://gn.googlesource.com/gn
[Ninja]: https://ninja-build.org/
[September 2024]: https://groups.google.com/g/v8-users/c/J8Q6VrX9e4M/m/DVJYVq8MAwAJ

## Usage

1. Download a [release].
2. Extract in the desired location (e.g. `vendors\v8\`).
3. Include headers (e.g. `vendors\v8\include`).
4. Link with the static library (e.g. `vendors\v8\lib\v8_monolith.lib`).
5. Enable features:
```
/DV8_COMPRESS_POINTERS
/DV8_ENABLE_WEBASSEMBLY
```
6. Build your project

<!-- Links -->
[release]: https://github.com/poirierlouis/v8-nocr/releases

## Guarantees

There are no guarantees regarding the quality of the build. It is provided
as-is. It currently lacks a workflow to run tests provided in V8's repository.

## Releases

Archives are compressed using the [LZMA] algorithm, thanks to 7-Zip. You'll
need [7-Zip] to extract them on your system.

| Version     |                                 Windows                                  |                                  Linux                                   |
|-------------|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|
| 14.9.207.29 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v14.9.207.29) | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v14.9.207.29) |
| 14.8.178.28 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v14.8.178.28) |                                    -                                     |
| 14.7.173.22 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v14.7.173.22) |                                    -                                     |
| 14.6.202.34 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v14.6.202.34) |                                    -                                     |

<!-- Links -->
[LZMA]: https://wikipedia.org/wiki/LZMA
[7-Zip]: https://www.7-zip.org

## Features

|     Version | i18n[^1] | WebAssembly[^2] | Pointer Compression[^3] | Sandbox[^4] | Temporal[^5] |
|------------:|:--------:|:---------------:|:-----------------------:|:-----------:|:------------:|
| 14.9.207.29 |    ✅     |        ✅        |            ✅            |      ❌      |      ❌       |
| 14.8.178.28 |    ✅     |        ✅        |            ✅            |      ❌      |      ❌       |
| 14.7.173.22 |    ✅     |        ✅        |            ✅            |      ❌      |      ❌       |
| 14.6.202.34 |    ✅     |        ✅        |            ✅            |      ✅      |      ❌       |

[^1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl
[^2]: https://developer.mozilla.org/en-US/docs/WebAssembly
[^3]: https://v8.dev/blog/pointer-compression
[^4]: https://v8.dev/blog/sandbox
[^5]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Temporal