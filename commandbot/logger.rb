require 'uri'

module QKbot
  class Logger
    def initialize(url)
      @webhook_url = URI.parse(url) 
    end

    def debug(message)
      post_webhooks("<#{Time.now.to_s}> [DEBUG] : " + message)
    end
    
    def info(message)
      post_webhooks("<#{Time.now.to_s}> [INFO] : " + message)
    end

    def warn(message)
      post_webhooks("<#{Time.now.to_s}> [WARN] : " + message)
    end

    def error(message)
      post_webhooks("<#{Time.now.to_s}> [ERROR] : " + message)
    end

    def fatal(message)
      post_webhooks("<#{Time.now.to_s}> [FATAL] : " + message)
    end

    private

    def post_webhooks(message)
      Net::HTTP.post_form(@webhook_url, {'content' => message})
    end

  end
end