# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ans-email_receiver/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["sakai shunsuke"]
  gem.email         = ["sakai@ans-web.co.jp"]
  gem.description   = %q{メール受信のためのクラス、モジュール}
  gem.summary       = %q{メール受信用}
  gem.homepage      = "https://github.com/answer/ans-email_receiver"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ans-email_receiver"
  gem.require_paths = ["lib"]
  gem.version       = Ans::EmailReceiver::VERSION

  gem.add_development_dependency "shoulda-matchers"
  gem.add_development_dependency "ans-matchers"
end
