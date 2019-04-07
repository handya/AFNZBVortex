Pod::Spec.new do |s|
  s.name          = "AFNZBVortex"
  s.version       = "0.0.1"
  s.license       = 'MIT'
  s.summary       = "API Wrapper for NZBVortex"
  s.description   = "API Wrapper for NZBVortex"
  s.homepage      = "https://github.com/handya/AFNZBVortex"
  s.author        = { "Andrew Farquharson" => "handya+pod@gmail.com" }
  s.source        = { :git => "https://github.com/handya/AFNZBVortex.git", :tag => "#{s.version}" }
  s.public_header_files = 'AFNZBVortex/AFNZBVortex/*.h'
  s.source_files = 'AFNZBVortex/AFNZBVortex/*.{h,m}'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 3.0'
end
