Gem::Specification.new do |s|
  s.name        = 'net-storage-trading'
  s.version     = '0.0.0'
  s.date        = '2013-09-11'
  s.summary     = "Allow storage over the network with encryption."
  s.description = "This project aims at providing a free solution for data backup. Local storage is valuated with a few criteria such as bandwith or availability and can be trade for a decentralized storage."
  s.authors     = ["Lionel Perrin"]
  s.email       = 'lionel_perrin@hotmail.com'
  s.files       = Dir['lib/*.rb']+Dir['lib/C_adler32']+Dir['spec/*.rb'] 
  s.homepage    ='https://github.com/duhlin/net-storage-trading'
  s.license     = 'LGPL v3'
  s.extensions = "ext/adler32/adler32conf.rb"
end

