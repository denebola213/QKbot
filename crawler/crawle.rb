require 'date'
require 'open-uri'
require_relative 'create'

module QKbot
  module DB

    def self.crawle(logger)
      #"DBPATH"がないとき、作成
      if Dir::glob(ENV['DBPATH']) == Array.new then
        Dir::mkdir(ENV['DBDIR']) unless Dir::exist?(ENV['DBDIR'])
        QKbot::DB.create
      end

      #DB open
      db = SQLite3::Database.new(ENV['DBPATH'])
      #DB保存用コマンド(insert)
      insert_class_info = <<-SQL
      insert into class_info(
        type,
        class_date,
        begin_period,
        end_period,
        grade,
        department,
        class_num,
        before_name,
        before_place,
        before_teacher,
        after_name,
        after_place,
        after_teacher)
      values(
        :type,
        :class_date,
        :begin_period,
        :end_period,
        :grade,
        :department,
        :class_num,
        :before_name,
        :before_place,
        :before_teacher,
        :after_name,
        :after_place,
        :after_teacher)
      SQL
      insert_info_of_day = <<-SQL
      insert into info_of_day(
        date,
        event,
        url,
        last_update)
      values(
        :date,
        :event,
        :url,
        :last_update)
      SQL

      #DB保存用コマンド(delete)
      delete_class_info = <<-SQL
      delete from class_info where class_date == ?
      SQL
      delete_info_of_day = <<-SQL
      delete from info_of_day where date == ?
      SQL


      #html読み込み
      url = 'http://www.ibaraki-ct.ac.jp/?cat=13'
      charset = nil
      begin
        html = open(url) do |f|
          charset = f.charset
          f.read
        end
      rescue OpenURI::HTTPError => ex
        # ibaraki-ct.ac.jpが落ちてたりしたら、クロールせず終わる
        logger.warn("[" + ex.class + "] " + ex.message)
        return
      end
      #parse
      doc = Nokogiri::HTML.parse(html, nil, charset)

      flag_update = false

      #情報が入ってるタグを回す
      doc.xpath('//*[@id="sub-contents"]/div/div/div/div[1]/div[1]/div').each do |nodeset|

        #情報更新日を取得
        update = Date.new
        tupdate = nodeset.xpath("strong").text
        tupdate.match(/(\d{4})年(\d{1,2})月(\d{1,2})日/u) do |md|
          update = Date.new(md[1].to_i, md[2].to_i, md[3].to_i)
        end

        #休講情報じゃなかったら飛ばす
        link_title = nodeset.xpath("a/h3").text
        if link_title !~ /休講情報/u then
          next
        end
        
        #情報の最初の日付
        first_date = Date.new
        tfirst_date = Unicode::nfkc(nodeset.xpath("div/p[2]/span[1]").text)
        tfirst_date.match(/(\d+)\/(\d+)/) do |md|
          first_date = Date.new(update.year, md[1].to_i, md[2].to_i)
        end
        
        #first_dateからDBの更新日を検索
        db_update = Date.new
        db.execute("select last_update from info_of_day where date == ?", first_date.strftime("%Y-%m-%d")) do |ud|
          ud[0].match(/(\d+)-(\d+)-(\d+)/) do |md|
            db_update = Date.new(md[1].to_i, md[2].to_i, md[3].to_i)
          end
        end

        #情報更新日がdb上の更新日より過去だったら飛ばす
        if update <= db_update
          next
        end

        flag_update = true

        #一週間個別のURLを取得
        week_url = nodeset.css('a')[0][:href]
        
        #各日付の情報を週単位で取得
        day_info = String.new
        nodeset.xpath("div[@class='p-3']/p").each do |day_doc|
          str_buff = day_doc.text
          if str_buff == "（●：休講、☆：授業・教室変更、◎：補講）"
            next
          end
          day_info << str_buff
        end

        #整形
        day_info = Unicode::nfkc(day_info)
        day_info = day_info.gsub(/《/, "<<")
        day_info = day_info.gsub(/》/, ">>")
        day_info = day_info.gsub(/・/, ",")
        day_info = day_info.gsub(/●/, "@")  #休講
        day_info = day_info.gsub(/☆/, "@@@@") #変更
        day_info = day_info.gsub(/◎/, "@@") #補講 ->後でbit fieldへ
        day_info = day_info.gsub(/<\/?\w+>/, " ")
        day_info = day_info.gsub(/\s+/, " ")
        
        loop do
          #日付のところで分解
          s = day_info.rpartition(/\b\d+[月\/]/u)
          result = s[1] + s[2]
          day_info = s[0]

          date = nil
          #日付をDateクラスへ
          judge = result.match(/\b(\d+)[月\/]\s*(\d+)/u) do |md|
            #更新が年末で情報が年始のとき
            if (update.month - md[1].to_i) > 6 then
              date = Date.new(update.year + 1, md[1].to_i, md[2].to_i)
            else
              date = Date.new(update.year, md[1].to_i, md[2].to_i)
            end
          end

          if judge == nil then
            break
          end

          #<<なんか>>のとき、なんかをeventに格納
          event = String.new
          result.scan(/<<([^<>]+)>>/u).flatten.each do |match|
            event << match
            event << ","
          end
          event.chop!

          #DB(info_of_day table)に保存
          #更新するデータは事前に消しておく
          db.transaction do
            db.execute(delete_info_of_day, date.strftime("%Y-%m-%d"))
            db.execute(delete_class_info, date.strftime("%Y-%m-%d"))
            db.execute(
              insert_info_of_day,
              date: date.strftime("%Y-%m-%d"),
              event: event,
              url: week_url,
              last_update: update.strftime("%Y-%m-%d"))
          end

          loop do
            #@(情報の種類)で区切る
            r = result.rpartition(/[^@](@)/u)
            a_info = r[1] + r[2]
            result = r[0]

            #分解できなくなったら終わり
            if result == ""
              break
            end

            #情報の種類をBitFieldで
            type = a_info.count('@')
            #授業時間
            period = a_info.scan(/(\d)[,~限]/u).flatten.collect do |md|
              md.to_i
            end
            begin_period = period.first
            end_period = period.last
            #学年学科クラス
            gdc = a_info.match(/@+(専*\S+年*)/u)[1]
            if (grade = gdc.match(/(\d)A/u)) then #専攻科
              grade = grade[1].to_i + 5
            elsif (grade = gdc.match(/^(\d)[^A]/u)) then  #本科
              grade = grade[1].to_i
            end
            department = gdc.scan(/[\d\/,]([MSEDCAI]{1,2})/u).flatten #Array
            if (class_num = gdc.match(/-(\d)/u)) then
              class_num = class_num[1].to_i
            else
              class_num = 0
            end
            #学科をBitFieldへ
            d_buf = 0
            department.each do |d|
              case d
              when "M" then
                d_buf += 0b0000000010
              when "S" then
                d_buf += 0b0000000100
              when "E" then
                d_buf += 0b0000001000
              when "D" then
                d_buf += 0b0000010000
              when "C" then
                d_buf += 0b0000100000
              when "AM" then
                d_buf += 0b0001000000
              when "AE" then
                d_buf += 0b0010000000
              when "AI" then
                d_buf += 0b0100000000
              when "AC" then
                d_buf += 0b1000000000
              end
            end
            department = d_buf
            #授業名
            name = a_info.scan(/(\S+)\(/u).flatten
            before_name = name.first
            after_name = name.last
            #教員名
            teacher = a_info.scan(/\((\S+)\)/u).flatten
            before_teacher = teacher.first
            after_teacher = teacher.last
            #教室変更
            after_place = String.new
            day_info.match(/【教室変更】(.+)$/) do |md|
              after_place = md[1]
            end

            #DB(class_info table)へ保存
            db.execute(
              insert_class_info,
              type: type,
              class_date: date.strftime("%Y-%m-%d"),
              begin_period: begin_period,
              end_period: end_period,
              grade: grade,
              department: department,
              class_num: class_num,
              before_name: before_name,
              before_place: nil,
              before_teacher: before_teacher,
              after_name: after_name,
              after_place: after_place,
              after_teacher: after_teacher)
            
          end
        end
      end
      
      # DB更新したら(flag_update == ture)
      logger.info("insert Kyuko infomation in database") if flag_update

      db.close
    end
  end
end

