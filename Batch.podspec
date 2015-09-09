Pod::Spec.new do |s|
  s.name = "Batch"
  s.version = "0.0.1"
  s.summary = "Batch control flow for Objective-C"
  s.description  = <<-DESC
                   Control flow can be tough and GCD provides a great abstraction.
                   However, Batch aims to make this much easier through callback
                   blocks and delegate method patterns.

  DESC
  s.homepage = "https://github.com/littlstar/Batch"
  s.license = "MIT"
  s.author = {"Joseph Werle" => "werle@littlstar.com"}
  s.source = {:git => "git@github.com:littlstar/Batch.git", :tag => "0.0.1"}
  s.source_files = "src/*.m"
  s.public_header_files = "include/batch/*.h"
end
