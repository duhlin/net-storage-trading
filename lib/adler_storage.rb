require 'set'

module AdlerDB

  FILENAME = 'store/adlerdb.rb'

  def self.load
    begin
      require_relative FILENAME
      ADLER_DB
    rescue LoadError
      Hash.new
    end
  end


  def self.save(db)
    File.open(FILENAME, 'w') do |file|
      #file.write "module AdlerDB\nADLER_DB=" + db.to_s + "\nend\n"
      #file.write 'ADLER_DB=' + db.to_s
      file.write 'ADLER_DB={'
      db.each_pair {|key, value| file.write "'" + key + "'=>" + 'Set.new(' + value.to_a.to_s + '),'}
      file.write '}'
    end
  end

end

#test = { 'a' => '1', 'b' => '2', 'c' => '3' }
#AdlerDB::save test
#puts AdlerDB::load
