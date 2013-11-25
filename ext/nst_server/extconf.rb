#Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

# Give it a name
extension_name = 'nst_server'

boost_include = dir_config("boost")
#find_header("boost/shared_ptr.hpp", boost_include)

# The destination
dir_config(extension_name)


# Do the work
create_makefile(extension_name)
