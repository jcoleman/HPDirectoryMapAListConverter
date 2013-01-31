require 'csv'

Record = Struct.new(:household, :primary, :secondary, :address)

states = [:scanning_for_next_record, :reading_primary, :reading_secondary, :reading_address]
current_state = :scanning_for_next_record
current_record = nil
records = []
i = 0
CSV.foreach(ARGV[0], :headers => false, :encoding => 'windows-1251:utf-8') do |row|
  i += 1
  unless current_record
    current_record = Record.new
  end

  begin
    parse = lambda do
      case current_state
      when :scanning_for_next_record
        unless row[1].nil? || row[1].to_s.strip.empty?
          current_record.household = row[1]
          current_state = :reading_primary
        end
      when :reading_primary
        current_record.primary = row[0]
        current_state = :reading_secondary
      when :reading_secondary
        if row[0].nil? || row[0].to_s.strip.empty?
          current_state = :reading_address
          parse.call
        else
          current_record.secondary = row[0]
        end
      when :reading_address
        if row[1].nil? || row[1].to_s.strip.empty?
          current_record.address = current_record.address.join(', ')
          records << current_record
          current_record = nil
          current_state = :scanning_for_next_record
        else
          current_record.address ||= []
          current_record.address << row[1]
        end
      end
    end

    parse.call
  rescue => e
    puts "Format error near row #{i} (may cause additional rows to report errors until fixed.)"
  end
end

csv_rows = [['Household', 'Primary', 'Secondary', 'Address']]
records.each do |r|
  csv_rows << [r.household, r.primary, r.secondary, r.address]
end

csv_string = CSV.generate do |csv|
  csv_rows.each do |row|
    csv << row
  end
end

puts csv_string
