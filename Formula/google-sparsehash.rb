class GoogleSparsehash < Formula
  desc "Extremely memory-efficient hash_map implementation"
  homepage "https://github.com/sparsehash/sparsehash"
  url "https://github.com/sparsehash/sparsehash/archive/sparsehash-2.0.3.tar.gz"
  sha256 "05e986a5c7327796dad742182b2d10805a8d4f511ad090da0490f146c1ff7a8c"

  bottle do
    cellar :any_skip_relocation
    sha256 "89dbaeb37bfaa056e8c1fd822e585f9ff04001778f646b1ec3f13c85a2ccaedc" => :high_sierra
    sha256 "a0bedeb9128c863130ee3330f65a6c4fe2fb8ca8aeb0aca7abd0ffc2c76691a1" => :sierra
    sha256 "8655e0c3b4f4c69e46d8823eef0d8ae2b1397cd2aa01bda3340eb3a84d647b89" => :el_capitan
    sha256 "b8e55b96aa3016ed2ab5a8d53a4bb39b44773885355ec75e80c9d9ef57c3e8b1" => :yosemite
    sha256 "570c4d250a4fe18d99f11167653a501a1d8a82ff74d2413336a85bc7fa8cbb81" => :mavericks
    sha256 "ed022642809ddcc995f6a46546d902d002b12c962fc47e0a33418347513885a6" => :x86_64_linux # glibc 2.19
  end

  option :cxx11
  option "without-test", "Skip build-time tests (not recommended)"

  deprecated_option "without-check" => "without-test"

  def install
    ENV.cxx11 if build.cxx11?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "check" if build.with? "test"
    system "make", "install"
  end
end
