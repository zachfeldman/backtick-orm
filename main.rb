class User

  PSQL_PREAMBLE = "psql -d testtwo -c "

  def initialize(properties = {})
    properties.each do |prop|
      instance_variable_set "@#{prop[0].to_s}", prop[1]
    end
  end


  def self.all
    command = `#{PSQL_PREAMBLE}"SELECT * FROM users"`
    object_array_returner sql_results_parser command
  end

  def self.where(options = {})
    final_query = []
    options.each do |option|
      final_query.push "#{option[0]} = '#{option[1]}'"
    end
    command = `#{PSQL_PREAMBLE}"SELECT * FROM users WHERE #{final_query.join(",")}"`
    object_array_returner sql_results_parser command
  end


  def self.find(id)
    command = `#{PSQL_PREAMBLE}"SELECT * FROM users WHERE id = #{id}"`
    parsed = sql_results_parser command
    parsed[0] ? User.new(parsed[0]) : nil
  end

  def self.last
    command = `#{PSQL_PREAMBLE}"SELECT * FROM users ORDER BY dateCreated DESC LIMIT 1"`
    parsed = sql_results_parser command
    parsed[0] ? User.new(parsed[0]) : nil
  end

  def self.first
    command = `#{PSQL_PREAMBLE}"SELECT * FROM users ORDER BY dateCreated ASC LIMIT 1"`
    parsed = sql_results_parser command
    parsed[0] ? User.new(parsed[0]) : nil
  end


  def self.create(options = {})
    final_query = []
    options.each do |option|
      final_query.push "#{option[0]} = '#{option[1]}'"
    end
    command = `#{PSQL_PREAMBLE}"INSERT INTO users (#{options.keys.map{|key| key.to_s}.join(",")}) VALUES (#{options.values.map{|v| "'#{v}'"}.join(",") })"`
    User.new(options)
  end

  def save
    attributes = {}
    instance_variables.each do |instance_variable|
      attributes[instance_variable[1..-1]] = instance_variable_get(instance_variable)
    end
    command = `#{PSQL_PREAMBLE}"INSERT INTO users (#{attributes.keys.map{|key| key.to_s}.join(",")}) VALUES (#{attributes.values.map{|v| "'#{v}'"}.join(",") })"`
    command2 = `#{PSQL_PREAMBLE}"SELECT * FROM users ORDER BY dateCreated DESC LIMIT 1"`
    User.new(self.class.sql_results_parser(command2)[0])
  end
 
  private

  def self.object_array_returner(results)
    results_arr = []
    results.each{ |result| results_arr.push( User.new(result) ) }
    results_arr
  end

  def self.sql_results_parser(results)
    initial_split = results.split("\n").map do |a|
      a.split("|").map do |a|
        a.strip
      end
    end
    columns_and_results_hash = {columns: initial_split[0], results: initial_split[2..-2]}
    results_array = []
    columns_and_results_hash[:results].each do |result|
      result_as_hash = {}
      result.each_with_index do |item, n|
        result_as_hash[columns_and_results_hash[:columns][n]] = item
      end
      results_array.push(result_as_hash)
    end
    results_array
  end

end