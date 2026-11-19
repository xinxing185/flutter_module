Pod::Spec.new do |s|
  s.name = 'CudyFlutter'
  s.version = '0.1.0'
  s.summary = 'CloudApp Flutter page integration and mock network plugins.'
  s.homepage = 'https://www.cudy.com'
  s.author = 'Cudy'
  s.source = { :path => '.' }
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'flutter_boost'
end
