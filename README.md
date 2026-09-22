# V8 – no Chromium

This repository is meant to build Google's [V8] JavaScript engine as a static
library (monolith). Its purpose is to provide a common place to maintain
a non-Chromium-based build pipeline of V8.

It still uses [GN] and [Ninja] but patches are applied based on the version
number when required. This is mostly meant to support Windows. As of [September
2024], Google dropped support for MSVC compiler / MSVC STL.

<!-- Links -->
[V8]: https://v8.dev/docs
[GN]: https://gn.googlesource.com/gn
[Ninja]: https://ninja-build.org/
[September 2024]: https://groups.google.com/g/v8-users/c/J8Q6VrX9e4M/m/DVJYVq8MAwAJ

## Usage

1. Download a [release].
2. Extract in the desired location (e.g. `vendors\v8\`).
3. See an example of a command line by OS below.
4. Build your project.

<!-- Links -->
[release]: https://github.com/poirierlouis/v8-nocr/releases

#### Windows
```
cl.exe /std:c++20 /Zc:__cplusplus /EHsc /O2 ^
     /DV8_CPPGC_MICROTASK_QUEUE ^
     /DV8_COMPRESS_POINTERS ^
     /DV8_ENABLE_WEBASSEMBLY ^
     /Ivendors\v8\include ^
     example.cpp ^
     /link ^
     /LIBPATH:vendors\v8\lib\ v8_monolith.lib ^
     dbghelp.lib winmm.lib ws2_32.lib userenv.lib ntdll.lib synchronization.lib ^
     /Fe:example.exe
```

#### Linux
```
/usr/lib/llvm-23/bin/clang++ -std=c++20 \
                             -fuse-ld=lld \
                             -O3 \
                             -DV8_CPPGC_MICROTASK_QUEUE \
                             -DV8_COMPRESS_POINTERS \
                             -DV8_ENABLE_WEBASSEMBLY \
                             -I./vendors/v8/include \
                             example.cpp \
                             -L./vendors/v8/lib -lv8_monolith \
                             -lrt -ldl -pthread -latomic \
                             -o example
```

> [!NOTE]
> `V8_CPPGC_MICROTASK_QUEUE` is required since **v15.4**.

## Guarantees

There are no guarantees regarding the quality of the build. It is provided
as-is. It currently lacks a workflow to run tests provided in V8's repository.

## Releases

Archives are compressed using [LZMA] algorithm. You'll need [7-Zip] to extract
them on your system.

| Version     |                                 Windows                                  |                                  Linux                                   |
|-------------|:------------------------------------------------------------------------:|:------------------------------------------------------------------------:|
| 15.4.80.11  | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.4.80.11)  | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.4.80.11)  |
| 15.3.76.16  | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.3.76.16)  | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.3.76.16)  |
| 15.2.124.33 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.2.124.33) | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.2.124.33) |
| 15.1.206.21 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.1.206.21) | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.1.206.21) |
| 15.0.245.23 | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.0.245.23) | [x64](https://github.com/poirierlouis/v8-nocr/releases/tag/v15.0.245.23) |

<!-- Links -->
[LZMA]: https://wikipedia.org/wiki/LZMA
[7-Zip]: https://www.7-zip.org

## Features

| Version     | Intl[^1] | WebAssembly[^2] | Pointer Compression[^3] | Sandbox[^4] | Temporal[^5] |
|-------------|:--------:|:---------------:|:-----------------------:|:-----------:|:------------:|
| 15.4.80.11  |    ✅    |       ✅        |           ✅            |     ❌      |      ✅      |
| 15.3.76.16  |    ✅    |       ✅        |           ✅            |     ❌      |      ✅      |
| 15.2.124.33 |    ✅    |       ✅        |           ✅            |     ❌      |      ❌      |
| 15.1.206.21 |    ✅    |       ✅        |           ✅            |     ❌      |      ❌      |
| 15.0.245.23 |    ✅    |       ✅        |           ✅            |     ❌      |      ❌      |

[^1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl
[^2]: https://developer.mozilla.org/en-US/docs/WebAssembly
[^3]: https://v8.dev/blog/pointer-compression
[^4]: https://v8.dev/blog/sandbox
[^5]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Temporal