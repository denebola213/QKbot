unless ARGV.length == 0 then
  ARGV.each do |arg|
    File.open(Dir[arg + '.pid'], 'r') do |file|
      Process.kill(2, file.gets.to_i)
    end
    File.delete(Dir[arg + '.pid'])
  end
  
else
  Dir["*.pid"].each do |dir|
    File.open(dir, 'r') do |file|
      Process.kill(2, file.gets.to_i)
    end
    File.delete(dir)
  end
end