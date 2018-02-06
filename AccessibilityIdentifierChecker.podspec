Pod::Spec.new do |s|

  s.name         = "AccessibilityIdentifierChecker"
  s.version      = "0.0.1"
  s.summary      = "Missing accessibility identifiers checker"
  s.description  = "A small library that warns you about missing accessibility identifiers"
  s.homepage     = "https://www.miquido.com/"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author       = { "Rafal Gawel" => "rafal.gawel@miquido.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/miquido/accessibility-identifier-checker.git", :tag => "#{s.version}" }
  s.source_files = "Sources/*.swift"
  s.frameworks   = "UIKit"

end
