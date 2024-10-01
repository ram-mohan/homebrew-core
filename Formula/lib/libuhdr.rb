class Libuhdr < Formula
  desc "Library for encoding and decoding ultrahdr images"
  homepage "https://developer.android.com/media/platform/hdr-image-format"
  url "https://github.com/google/libultrahdr/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "0db267135611d96ef5d33f32162e8c226a8c2ab6320002f185d903d3131623c8"
  license "Apache-2.0"
  head "https://github.com/google/libultrahdr.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :test
  depends_on "jpeg-turbo"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"uhdr_test.cpp").write <<~EOS
      #include <iostream>
      #include "ultrahdr_api.h"

      int main() {
        uhdr_codec_private_t* enc_handle = uhdr_create_encoder();
        if (!enc_handle) {
          return -1;
        }
        uhdr_release_encoder(enc_handle);
        std::cout << UHDR_LIB_VERSION_STR;
        return 0;
      }
    EOS
    uhdr_flags = shell_output("pkg-config --cflags --libs libuhdr").chomp.split
    system ENV.cxx, "uhdr_test.cpp", *uhdr_flags, "-o", "uhdr_test"
    output = shell_output("./uhdr_test").strip
    assert_equal("1.2.0", output)
  end
end
