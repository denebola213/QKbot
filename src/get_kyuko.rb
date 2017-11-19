require 'bundler'
require 'open-uri'
require 'date'
Bundler.require

#html読み込み
url = 'http://www.ibaraki-ct.ac.jp/?cat=13'
charset = nil
html = open(url) do |f|
  charset = f.charset
  f.read
end

#parse
doc = Nokogiri::HTML.parse(html, nil, charset)

info_urls = Array.new
#情報が入ってるタグを回す
doc.xpath("/html/body/div/div[@class='category_main']/p").each do |nodeset|
  #休講情報じゃなかったら飛ばす
  flag = nodeset.xpath("./a").text
  if flag !~ /休講情報/u
    next
  end

  #一週間分個別のURLを取得
  nodeset.css('a').each do |element|
    info_urls << element[:href]
  end
end

#各週のページから情報を取得
info_urls.reverse_each do |info_url|
  
  #html読み込み
  info_charset = nil
  info_html = open(info_url) do |f|
    info_charset = f.charset
    f.read
  end
  #parse
  str = String.new
  info_doc = Nokogiri::HTML.parse(info_html, nil, info_charset)
  info_doc.xpath("/html/body/div/div[@class='single_main']/p").each do |nodeset|
    if nodeset.text == "（●：休講、☆：授業・教室変更、◎：補講）"
      next
    end
    str << nodeset.text
  end

  #整える
  str = Unicode::nfkc(str)
  str = str.gsub(/《/, "<<")
  str = str.gsub(/》/, ">>")
  str = str.gsub(/・/, ",")
  str = str.gsub(/●/, "@")  #休講
  str = str.gsub(/☆/, "@@@@") #変更
  str = str.gsub(/◎/, "@@") #補講 ->後でbit fieldへ
  str = str.gsub(/<\/?\w+>/, " ")
  str = str.gsub(/\s+/, " ")


  loop do
    #日付のところで分解
    s = str.rpartition(/\b\d+[月\/]/u)
    result = s[1] + s[2]
    str = s[0]

    #分解できなくなったら終わり
    if str == ""
      break
    end

    date = nil
    #日付をDateクラスへ
    result.match(/\b(\d+)[月\/]\s*(\d+)/u) do |md|
      #現在が年末で情報が年始のとき
      if (Date.today.month - 6) > md[1].to_i then
        date = Date.new(Date.today.year + 1, md[1].to_i, md[2].to_i)
      #現在が年始で情報が年末のとき
      elsif Date.today.month > (md[1].to_i + 6) then
        date = Date.new(Date.today.year - 1, md[1].to_i, md[2].to_i)
      else
        date = Date.new(Date.today.year, md[1].to_i, md[2].to_i)
      end
    end

    #<<なんか>>のとき、なんかをeventに格納
    event = nil
    result.match(/<<([^<>]+)>>/u) do |md|
      event = md[1]
    end

    #debug
    p date
    p event

    loop do
      #@(情報の種類)で区切る
      r = result.rpartition(/\s@+/u)
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

      #debug_begin
      putstr = type.to_s + " " + begin_period.to_s + "~" + end_period.to_s + "限 " + grade.to_s + "年 " + department.to_s + " "
      if class_num
        putstr << class_num.to_s
      end
      puts putstr
      #debug_end
      


    end

    puts "----------"

  end

  
end

