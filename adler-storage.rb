module AdlerDB

  FILENAME = 'store/adlerdb.rb'

  def self.load
    require_relative FILENAME
    ADLER_DB
  end


  def self.save(db)
    File.open(FILENAME, 'w') do |file|
      #file.write "module AdlerDB\nADLER_DB=" + db.to_s + "\nend\n"
      file.write 'ADLER_DB=' + db.to_s
    end
  end

end

#test = { 'a' => '1', 'b' => '2', 'c' => '3' }
#AdlerDB::save test
#puts AdlerDB::load
