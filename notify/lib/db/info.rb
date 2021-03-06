require 'date'

module QKbot
  module DB
    class Info
      attr_reader :id, :type, :date, :period, :grade, :department, :num, :name, :teacher
  
      #id -> Fixnum
      #type -> Array : 情報の種類を表す文字列の配列 'no','change','extra'
      #date -> Date
      #period -> Range
      #grade -> Fixnum
      #department -> Array : 学科略称の文字列の配列
      #num -> Fixnum
      #name -> String | Hash : 変更の場合は:beforeと:afterをkeyに持つhash
      #teacher -> String | Hash : 変更の場合は:beforeと:afterをkeyに持つhash
      def initialize(id = nil)
        db = SQLite3::Database.new DBPATH
        db.results_as_hash = true
        db.execute("select * from class_info where id == ?", id) do |row|
          #ID
          @id = row['id']
  
          #情報の種類
          @type = Array.new
          if row['type'].to_i & 0b001 != 0 then
            @type << '休講'
          end
          if row['type'].to_i & 0b010 != 0 then
            @type << '補講'
          end
          if row['type'].to_i & 0b100 != 0 then
            @type << '変更'
          end
  
          #日にち
          row['class_date'].match(/(\d+)-(\d+)-(\d+)/) do |md|
            @date = Date.new(md[1].to_i, md[2].to_i, md[3].to_i)
          end
  
          #何限目
          @period = Range.new(row['begin_period'].to_i, row['end_period'].to_i)
  
          #学年
          @grade = row['grade'].to_i
  
          #学科
          dep_buf = row['department'].to_i
          @department = Array.new
          if dep_buf & 0b0000000010 != 0 then
            @department << 'M'
          end
          if dep_buf & 0b0000000100 != 0 then
            @department << 'S'
          end
          if dep_buf & 0b0000001000 != 0 then
            @department << 'E'
          end
          if dep_buf & 0b0000010000 != 0 then
            @department << 'D'
          end
          if dep_buf & 0b0000100000 != 0 then
            @department << 'C'
          end
          if dep_buf & 0b0001000000 != 0 then
            @department << 'AM'
          end
          if dep_buf & 0b0010000000 != 0 then
            @department << 'AE'
          end
          if dep_buf & 0b0100000000 != 0 then
            @department << 'AI'
          end
          if dep_buf & 0b1000000000 != 0 then
            @department << 'AC'
          end
  
          #組
          @num = row['class_num'].to_i
          
          #教科名
          if row['before_name'] == row['after_name'] then
            @name = row['before_name']
          else
            @name = {before: row['before_name'], after: row['after_name']}
          end
  
          #担当教員名
          if row['before_teacher'] == row['after_teacher'] then
            @teacher = row['before_teacher']
          else
            @teacher = {before: row['before_teacher'], after: row['after_teacher']}
          end
        end
        db.close
      end
  
      def no?
        @type.include?('休講')
      end
  
      def change?
        @type.include?('変更')
      end
  
      def extra?
        @type.include?('補講')
      end
  
      def to_s
  
        #情報の種類
        message = "【" + @type.join(', ') + "】"
        #学年
        if @grade <= 5 then
          message << @grade.to_s
        elsif @grade == 6 then
          message << "専1"
        elsif @grade == 7 then
          message << "専2"
        end
        #学科
        if @department != Array[] then
          message << @department.join(',')
        else
          #学科がなかったら"年"を入れて
          message << "年"
        end
        #組
        if @num != 0 then
          #組があったら"年"を消す
          message.chop!
          message << "-" + @num.to_s
        end
        #授業時間
        if @period.first == @period.last then
          message << " " + @period.first.to_s + "限"
        else
          message << " " + @period.to_s.tr_s(".","～") + "限"
        end
        #教科名
        if @name.is_a?(String) then
          message << " " + @name
        elsif @name != nil
          message << " " + @name[:before] + " => " + @name[:after]
        end
  
        return message
      end
  
    end
  
    class Day
      attr_reader :date, :info, :url, :event
  
      def initialize(date)
        @date = date
        @info = Array.new
        ids = Array.new
        SQLite3::Database.new DBPATH do |db|
          ids = db.execute("select id from class_info where class_date == ?", @date.strftime("%Y-%m-%d"))
  
          db.execute("select event, url from info_of_day where date == ?", @date.strftime("%Y-%m-%d")) do |row|
            @event = row[0]
            @url = row[1]
          end
        end
        ids.each do |id|
          @info << Info.new(id[0].to_i)
        end
      end
  
      def to_s
        str = String.new
        @info.each do |info|
          str << info.to_s + "\n"
        end
        str
      end
  
      
    end
  
    class Week
      attr_reader :cweek, :cwyear, :monday, :tuesday, :wednesday, :thursday, :friday
      #cwy => 暦週における年をIntegerで
      #cw => 暦週をIntegerで
      def initialize(cwy, cw)
        @cweek = cw
        @cwyear = cwy
        date = Date.commercial(cwy, cw)
        5.times do |n|
          day_info = Day.new(date + n)
          case n
          when 0 then
            @monday = day_info
          when 1 then
            @tuesday = day_info
          when 2 then
            @wednesday = day_info
          when 3 then
            @thursday = day_info
          when 4 then
            @friday = day_info
          end
        end
      end
    end
  end
end