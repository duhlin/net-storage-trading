MOD_ADLER = 65521

class Adler32
  def initialize(size=nil)
    @buffer = []
    @size = size
    @A = 1
    @B = 0
  end

  def update(content)
    content.each_byte do |added|
      removed = nil
      @buffer.push added
      if @size && @buffer.size > @size
        removed = @buffer.pop
      end
      #print "added=", added
      #print ", removed=", removed
      #print ", @A=", @A
      #print ", @B=", @B
      @A += added
      @A -= removed if removed
      @B += @A
      @B -= 1 + @size * removed if removed
      @A %= MOD_ADLER
      @B %= MOD_ADLER
      #print ", @A=", @A
      #print ", @B=", @B
      #print "\n"
    end
    #print "\n"
    nil
  end

  def digest
    @B * 65536 + @A
  end

  def hexdigest
    digest().to_s(16)
  end
end


