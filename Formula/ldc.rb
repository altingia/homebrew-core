class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"

  stable do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.6.0/ldc-1.6.0-src.tar.gz"
    sha256 "bec1821b170e4b3f0b071f3fea357172ad90c7a45d64f7542f7843ac4de6a763"

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc/releases/download/v0.17.5/ldc-0.17.5-src.tar.gz"
      sha256 "7aa540a135f9fa1ee9722cad73100a8f3600a07f9a11d199d8be68887cc90008"
    end
  end

  bottle do
    sha256 "b282682e7002a5ca1cc69e195ac49b746aafe06d120c0e64e0daefcd5171574e" => :high_sierra
    sha256 "73dda487ecba87af435727755d477d8170f61fd5c9b60658b121948aa9b79b6f" => :sierra
    sha256 "775e20c82003b21ab01401cce815c6e19155d9cc594db10f8835530bffc7a81d" => :el_capitan
    sha256 "b42d1a882e86bf8eb8d54098e00a4c015f09924779a8f1de04cba0b210a535e8" => :x86_64_linux
  end

  devel do
    url "https://github.com/ldc-developers/ldc/releases/download/v1.6.0-beta1/ldc-1.6.0-beta1-src.tar.gz"
    sha256 "4216b32b7fdcc65a410a7c0724af6cd4f3ae02b14749b3c073f1e55de8fd6028"

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc/releases/download/v0.17.5/ldc-0.17.5-src.tar.gz"
      sha256 "7aa540a135f9fa1ee9722cad73100a8f3600a07f9a11d199d8be68887cc90008"
    end
  end

  head do
    url "https://github.com/ldc-developers/ldc.git", :shallow => false

    resource "ldc-lts" do
      url "https://github.com/ldc-developers/ldc.git", :shallow => false, :branch => "ltsmaster"
    end
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm"

  def install
    # Fix the error:
    # CMakeFiles/LDCShared.dir/build.make:68: recipe for target 'dmd2/id.h' failed
    ENV.deparallelize if OS.linux?

    ENV.cxx11
    (buildpath/"ldc-lts").install resource("ldc-lts")

    cd "ldc-lts" do
      mkdir "build" do
        args = std_cmake_args + %W[
          -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        ]
        system "cmake", "..", *args
        system "make"
      end
    end
    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-lts/build/bin/ldmd2
        -DLDC_WITH_LLD=OFF
        -DRT_ARCHIVE_WITH_LDC=OFF
      ]
      # LDC_WITH_LLD see https://github.com/ldc-developers/ldc/releases/tag/v1.4.0 Known issues
      # RT_ARCHIVE_WITH_LDC see https://github.com/ldc-developers/ldc/issues/2350

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=thin", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldc2", "-flto=full", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
