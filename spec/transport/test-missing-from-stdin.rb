require 'test/unit'

class Test_missing_from_stdin < Test::Unit::TestCase
  def setup
    @stdin_sha = [1043,1234,1743,7456,9853]
    local_sha = [1043,4864,5623,7456]
    local = open("index.bin", "w") {|f| f << local_sha.join("\n")+"\n"}
  end

  #missing from stdin is supposed to compare the content of the file given as argument with input given on stdin
  def test_missing
    p = IO.popen(["lib/transport/missing-from-stdin.rb", "index.bin"], "r+") 
    diff_sha = []
    p.write @stdin_sha.join("\n")+"\n"
    p.close_write
    diff_sha << p.readlines
    assert_equal([4864,5623].join("\n")+"\n", diff_sha.join)
  end

end

