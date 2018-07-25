class Date
  def wday_jp
    result = String.new
    case self.wday
    when 0 then
      result = "日"
    when 1 then
      result = "月"
    when 2 then
      result = "火"
    when 3 then
      result = "水"
    when 4 then
      result = "木"
    when 5 then
      result = "金"
    when 6 then
      result = "土"
    end

    result
  end
end
