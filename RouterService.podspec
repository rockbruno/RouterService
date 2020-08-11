Pod::Spec.new do |s|
  s.name = 'RouterService'
  s.module_name = 'RouterService'
  s.version = '1.0.0'
  s.license = { type: 'MIT', file: 'LICENSE' }
  s.summary = 'Route based dependency injection SDK for iOS.'
  s.homepage = 'https://github.com/rockbruno/RouterService'
  s.author = { 'Bruno Rocha' => 'brunorochaesilva@gmail.com' }
  s.social_media_url = 'https://twitter.com/rockbruno_'
  s.swift_version = '5.1'

  s.source           = { :git => 'https://github.com/rockbruno/RouterService.git', :branch => "master", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/RouterService/**/*'

  s.dependency 'RouterServiceInterface', s.version.to_s

end