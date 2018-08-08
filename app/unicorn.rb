@dir = File.dirname(File.expand_path(__FILE__)) + '/'

worker_processes 2
working_directory @dir

timeout 300
listen 3000

pid "#{@dir}tmp/pids/unicorn.pid"

stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"