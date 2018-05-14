unless ARGV.length == 0 then
  ARGV.each do |arg|
    File.open(arg + '.pid', 'r') do |file|
      Process.kill(2, file.gets.to_i)
    end
    File.delete(arg + '.pid')
  end
  
else
  Dir["*.pid"].each do |dir|
    File.open(dir, 'r') do |file|
      Process.kill(2, file.gets.to_i)
    end
    File.delete(dir)
  end
end