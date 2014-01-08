class Data::FilzColumn

  def self.get_headers(data)
    headings = data.shift
    stats = []
    headings.size.times do |i|
      stat = {}
      stat["col"] = headings[i]
      data.each do |row|
        type = Data::FilzColumn.tell_datatype(row[i])
        stat[type] = stat.has_key?(type) ? (stat[type] + 1) : 1
      end
      stats.push(stat)
    end
    headers = []
    stats.each do |s|
      if s["col"].present?
          name = s["col"]
          name = (name.include? ":") ? name.split(":")[0] : name
          s.delete("col")
          type = s.sort.last.first
          headers.push "#{name}:#{type}"
      end
    end
    return headers.join(",")    
  end
    
  private

  def self.tell_datatype(v)
    return "number" unless v.to_s.match(/^[\d]+(\.[\d]+){0,1}$/) == nil
    return "string"
  end

end
