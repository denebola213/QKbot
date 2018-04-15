module QKbot
  module Twitter
    class TweetString < String
      
      def size
        str = self.to_s
        
        unless str.encoding == Encoding.find("utf-8") || str.encoding == Encoding.find("US-ASCII") || str.encoding == Encoding.find("ASCII-8BIT")
          raise EncodingError, "It only supports UTF-8 or ASCII"
        end
    
        size = 0
        #URLを検出
        loop do
          if str.slice!(/http[s]?:\/\/[^\P{ascii}\s]+/) then
            size = size + 12
          else
            break
          end
        end
    
        str.chars do |char|
          if char.bytesize == 1 then
            size = size + 0.5
          elsif char.bytesize == 3 then
            size = size + 1
          else
            raise Encoding::InvalidByteSequenceError
          end
        end
        
        
        size.to_i
      end
      alias :length :size
  
      def parse
        tweet_array = Array.new
        tweet = TweetString.new
  
        self.lines do |line|
          tweet_line = TweetString.new(line)
          
          if (tweet.size + tweet_line.size) > 134 then
            tweet << "\nつづく..."
            tweet_array << tweet
            tweet = TweetString.new
          end
          tweet << tweet_line
        end
        tweet_array << tweet
      end
    end
  end
end
