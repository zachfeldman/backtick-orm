class User

  def initialize(properties = {})
    properties.each do |prop|
      instance_variable_set("@" + prop[0].to_s, prop[1])
    end
  end

  def self.all
    command = `psql -d testtwo -c "SELECT * FROM users"`
    parser(command)
    results_arr = []
    parsed.each do |result|
      results_arr.push(User.new(result))
    end
    results_arr
  end

  def self.find(id)
    command = `psql -d testtwo -c "SELECT * FROM users WHERE id = #{id}"`
    parsed = parser(command)
    result = parsed[0] ? parsed[0] : nil
    User.new(result)
  end

  def self.where(options = {})
    final_query = []
    options.each do |option|
      final_query.push("#{option[0]} = '#{option[1]}'")
    end
    command = `psql -d testtwo -c "SELECT * FROM users WHERE #{final_query.join(",")}"`
    parsed = parser(command)
    
    results_arr = []
    parsed.each do |result|
      results_arr.push(User.new(result))
    end
    results_arr
  end

  def self.create(options = {})
    final_query = []
    options.each do |option|
      final_query.push("#{option[0]} = '#{option[1]}'")
    end
    command = `psql -d testtwo -c "INSERT INTO users (#{options.keys.map{|key| key.to_s}.join(",")}) VALUES (#{options.values.map{|v| "'#{v}'"}.join(",") })"`
    User.new(options)
  end

 


  def self.parser(results)
    split = results.split("\n").map do |a|
      a.split("|").map do |a|
        a.strip
      end
    end
    basic = {columns: split[0], results: split[2..-2]}
    final = []
    basic[:results].each do |result|
      hasher = {}
      result.each_with_index do |item, n|
        hasher[basic[:columns][n]] = item
      end
      final.push(hasher)
    end
    final
  end

end