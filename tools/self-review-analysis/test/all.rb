Dir.glob(File.join(__dir__, 'test_*.rb')).sort.each { |path| require path }
