require 'openssl'
require 'yaml'
PassFile = '.keys'

def GenPassFile
  cipher = OpenSSL::Cipher::AES.new(128, :CBC)
  cipher.encrypt
  d = { 'key' => cipher.random_key, 'iv' => cipher.random_iv }
  File.open(PassFile, 'w') do |file|
    file.write( YAML::dump(d) )
  end
  d
end

def ReadPassFile
  File.open(PassFile, 'r') do |file|
    YAML::load( file.read() )
  end
end

def GetKeys
  if not File.exists? PassFile
    GenPassFile()
  else
    ReadPassFile()
  end
end

print GetKeys()


