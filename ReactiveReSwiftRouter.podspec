Pod::Spec.new do |s|
  s.name             = "ReactiveReSwiftRouter"
  s.version          = "1.0.0"
  s.summary          = "Declarative Routing for ReactiveReSwift"
  s.description      = <<-DESC
                          A declarative router for ReactiveReSwift. Allows developers to declare routes in a similar manner as
                          URLs are used on the web. Using ReSwiftRouter you can navigate your app by defining the target location
                          in the form of a URL-like sequence of identifiers.
                        DESC
  s.homepage         = "https://github.com/richy486/ReactiveReSwiftRouter"
  s.license          = { 
    :type => "MIT", 
    :file => "LICENSE.md" 
  }
  s.authors           = {
    "Benjamin Encz" => "me@benjamin-encz.de",
    "Richard Adem" => "richy486@gmail.com"
  }
  s.social_media_url = "http://twitter.com/benjaminencz"
  s.source           = { 
    :git => "https://github.com/richy486/ReactiveReSwiftRouter.git",
    :tag => s.version.to_s
  }
  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.source_files     = 'ReSwiftRouter/**/*.swift'
  s.dependency 'ReactiveReSwift', '~> 3.0.6'
end
