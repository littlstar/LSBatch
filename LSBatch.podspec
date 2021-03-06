Pod::Spec.new do |s|
  s.name = "LSBatch"
  s.version = "0.0.10"
  s.summary = "Batch control flow for Objective-C"
  s.description  = <<-DESC
                   Control flow can be tough and GCD provides a great abstraction.
                   However, Batch aims to make this much easier through callback
                   blocks and delegate method patterns.

  DESC
  s.homepage = "https://github.com/littlstar/LSBatch"
  s.license = "MIT"
  s.author = {"Joseph Werle" => "werle@littlstar.com"}
  s.requires_arc = true
  s.source = {:git => "https://github.com/littlstar/LSBatch.git", :tag => s.version.to_s}
  s.header_dir = "./include/"
  s.source_files = "src/*.m"
  s.public_header_files = "include/*/*.h"
  s.preserve_paths = "include/*"
end
