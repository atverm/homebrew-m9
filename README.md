# M9 for macOS — the Homebrew tap

**Experimental.**  M9 (Modula-9) is a Wirth-family language for code
an AI agent writes and a person audits; the compiler, runtime and
standard library are at [github.com/atverm/m9c](https://github.com/atverm/m9c),
the tutorial at [tutorial.modula9.net](https://tutorial.modula9.net).

    brew tap atverm/m9
    brew install m9

builds the release tarball on your Mac with Homebrew's gcc and
installs it, with OpenSSL, blosc and netCDF from Homebrew beside it.
The gcc is the point: Apple's `cc` is clang, which takes neither
gcc's inliner budget nor a nested function, so `m9c` on a Mac drives
Homebrew's gcc through `$(brew --prefix m9)/gcc/bin/gcc`.

The formula installs the current release from the
[release page](https://github.com/atverm/m9c/releases) (0.12.0 is the
first with the macOS port); `brew install --HEAD atverm/m9/m9` builds
the public repository's `main` instead, which carries what the next
release will.

The formula's source is `tools/release/mac/m9.rb` in the private
development tree; the copy here is written per release by its
`mactap.sh`, with a receipt on the release page recording the Mac it
was installed and smoke-tested on.  Verified on one Apple-silicon Mac
(macOS 26); Intel Macs are untested.  Report what breaks -- that is
what the label is for.
