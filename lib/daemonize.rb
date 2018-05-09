module QKbot
  class Daemon
    attr_reader :flag_int
    attr_writer :stop_handler
    # === WARNING ===
    # If this daemon include loop process, you have to write the termination process using "self.flag_int"
    def initialize(pid_file, log = Logger.new(STDOUT), loop_process = false, &handler)
      # Interrupt flag
      @flag_int = false
      # logger object
      @log = log
      # Daemon handler
      @execute_handler = handler

      # pid file path
      @pid_file_path = pid_file

      # if include loop process
      @loop_process = loop_process

    end

    def run
      begin
        # start message
        @log.info("Start!")

        daemonize()
        set_trap()
        execute()

        @log.info("Stop")
      rescue => exception
        @log.error(exception.backtrace.to_s.tr(",", "\n").tr("`", "^") + "\n" + exception.message)
        exit 1
      end
    end

    private

    def daemonize
      begin
        Process.daemon(true, true)
        # put pid
        File.open(@pid_file_path, 'w') do |f|
          f << Process.pid
        end
      rescue => exception
        @log.error(exception.backtrace.to_s.tr(",", "\n").tr("`", "^") + "\n" + exception.message)
        exit 1
      end
    end

    def set_trap
      begin
        Signal.trap(:INT) do @flag_int = true end  # SIGINT 
        Signal.trap(:TERM) do @flag_int = true end  # SIGTERM
      rescue => exception
        @log.error(exception.backtrace.to_s.tr(",", "\n").tr("`", "^") + "\n" + exception.message)
        exit 1
      end
    end

    def execute
      begin
        if @loop_process then
          @execute_handler.call
        else
          @execute_handler.call
          # interrupt process
          loop do
            if @flag_int
              break
            end
            sleep 1
          end
        end
      rescue => exception
        @log.error(exception.backtrace.to_s.tr(",", "\n").tr("`", "^") + "\n" + exception.message)
        exit 1
      end
    end
  end
end