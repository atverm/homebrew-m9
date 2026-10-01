# M9 (Modula-9) for macOS, from the release tarball, with gcc as the
# compiler m9c drives -- the one arrangement every other platform has:
# Homebrew's gcc is what <prefix>/gcc/bin/gcc runs, so a cell, a
# program or the compiler itself never meets Apple's clang, which
# takes neither gcc's --param nor a nested function.  OpenSSL, blosc
# and netCDF are the libraries the runtime's shims and the tutorial's
# chapters link; the formula names them so a program that opens an
# https URL, reads a zarr chunk or writes a netCDF file links on the
# first try.
#
# THIS FILE IS THE SOURCE of github.com/atverm/homebrew-m9's
# Formula/m9.rb: tools/release/mac/mactap.sh fills the version and the
# tarball's sha256 from the release tarball and writes the copy the
# tap gets, with a receipt.  runtime/test/mactap.sh holds the tree to
# the recipe below, step for step.
class M9 < Formula
  desc "Modula-9: a Wirth-family language for code an AI agent writes and a person audits"
  homepage "https://github.com/atverm/m9c"
  url "https://github.com/atverm/m9c/releases/download/v0.13.0/m9-0.13.0.tar.gz"
  sha256 "065de5b35734cfaffb3c094f4814fe43689f691a6449ef6d93b4d640787747e9"
  license "GPL-3.0-or-later"
  # the public mirror follows the private main; --HEAD builds what the
  # next release will carry
  head "https://github.com/atverm/m9c.git", branch: "main"

  depends_on "gcc"
  depends_on "openssl@3"
  depends_on "c-blosc"
  depends_on "netcdf"

  def install
    gcc = Formula["gcc"]
    # build.sh honours CC, CFLAGS, CPPFLAGS and LDFLAGS; the C standard
    # and the warnings are its own.  gcc by its versioned name, the
    # one Homebrew installs; the unversioned `gcc` on a Mac is clang.
    ENV["CC"] = (gcc.opt_bin/"gcc-#{gcc.version.major}").to_s
    ENV["CPPFLAGS"] = "-I#{Formula["openssl@3"].opt_include}"
    ENV["LDFLAGS"] = "-L#{Formula["openssl@3"].opt_lib}"
    # DESTDIR layout is <dest>/usr/{bin,lib,include,share}; the keg is
    # that usr, so m9c finds its library at <prefix>/lib/m9 by its own
    # rule (the directory above the executable's) and nothing needs a
    # variable set
    system "./build.sh", buildpath/"stage"
    prefix.install Dir[buildpath/"stage/usr/*"]

    # THE gcc SLOT m9c looks in on macOS: two scripts that run
    # Homebrew's gcc at whatever major version is installed today.  A
    # symlink to gcc-16 would go stale at the upgrade to 17 and m9c
    # would fall back to cc without a word.
    (prefix/"gcc/bin").mkpath
    {
      "gcc"    => "gcc",
      "gcc-ar" => "gcc-ar",
    }.each do |name, tool|
      script = prefix/"gcc/bin"/name
      script.write <<~EOS
        #!/bin/sh
        # m9c's #{tool} on macOS: Homebrew's, whatever its major version
        for g in #{HOMEBREW_PREFIX}/opt/gcc/bin/#{tool}-[0-9]*; do
          [ -x "$g" ] && exec "$g" "$@"
        done
        echo "m9c: no Homebrew gcc found -- brew install gcc" >&2
        exit 127
      EOS
      script.chmod 0755
    end
  end

  def caveats
    <<~EOS
      m9c drives Homebrew's gcc (#{opt_prefix}/gcc/bin/gcc) and links
      OpenSSL, blosc and netCDF from Homebrew when a program needs them.

      The VS Code extension is at #{opt_share}/m9/vscode-m9; link it once:
        ln -s #{opt_share}/m9/vscode-m9 ~/.vscode/extensions/atverm.m9-lang-0.2.0

      macOS support is experimental: the compiler and its gates are
      verified on Apple silicon; Intel Macs are untested.
    EOS
  end

  test do
    (testpath/"Hello.m9").write <<~EOS
      MODULE Hello ;
      IMPORT Io ;
      BEGIN
        Io.WriteLine ('hello from m9 on macOS')
      EXCEPT
      | ValueRange : Io.Halt (1)
      END Hello.
    EOS
    system bin/"m9c", "--make", "-o", "hello", "Hello.m9"
    assert_equal "hello from m9 on macOS\n", shell_output("./hello")
    assert_match "m9c ", shell_output("#{bin}/m9c --version")
  end
end
