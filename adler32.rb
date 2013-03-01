MOD_ADLER = 65521

class Adler32
  def initialize(size=nil)
    @buffer = []
    @size = size
    @A = 1
    @B = 0
  end

  def new_byte(added)
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

  def update(content)
    if content.respond_to? :each_byte  
      content.each_byte {|byte| new_byte(byte)}
      #print "\n"
    else
      new_byte(content)
    end
    nil
  end

  def <<(content)
    update(content)
  end

  def digest
    @B * 65536 + @A
  end

  def hexdigest
    digest().to_s(16)
  end
end


