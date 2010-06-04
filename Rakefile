require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.name              = "chatchart"
    s.version           = "1.0.0"
    s.author            = "Christopher Abad"
    s.email             = "aempirei@gmail.com"
    s.homepage          = "http://www.twentygoto10.com/"
    s.date              = "2009-11-22"
    s.summary           = "ASCII drawing and graph layout"
    s.description       = "This is a package of various crappy ruby code which generally revolves around ASCII drawing and graph layout."
    s.platform          = Gem::Platform::RUBY
    s.files             = FileList['{demos,lib}/*.rb', 'README','LICENSE',].to_a
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end
