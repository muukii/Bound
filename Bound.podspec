Pod::Spec.new do |s|

  s.name         = "Bound"
  s.version      = "0.0.1"
  s.summary      = "A kit for transitioning view controller"
  s.description  = <<-DESC
                    A kit for transitioning view controller
                   DESC

  s.homepage     = "https://github.com/muukii/Bound"

  s.license      = "MIT"
  s.author             = { "Muukii" => "muukii.app@gmail.com" }

  s.platform     = :ios, "9.0"
  s.source = { :git => 'https://github.com/muukii/Bound.git', :tag => s.version.to_s }

  s.source_files  = "Bound", "Bound/**/*.{swift}"

end
