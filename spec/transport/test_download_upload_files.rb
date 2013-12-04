require 'test/unit'
require 'fileutils'

def assert_folder_equal(left, right)
	left_e  = Dir.entries(left).sort 
	right_e = Dir.entries(right).sort
	assert_equal( left_e, right_e )
	left_e.each do |f|
		next if f == '.' or f == '..'
		left_f = File.join(left, f)
		right_f = File.join(right, f)
		assert( FileUtils.compare_file( left_f, right_f ), "Difference detected: #{left_f}:#{right_f}" ) if File.file? left_f
		assert_folder_equal( left_f, right_f ) if File.directory? left_f
	end
end



class Test_download_upload_files < Test::Unit::TestCase

	#upload files is expected to send on STDOUT the file content of each files received on STDIN
	#download files is expected to write on disk the file content received on STDIN
	def test_download_upload
		src_dir = "spec/transport/fixtures"
		dst_dir = "spec/transport/copy_fixtures"
		system "lib/transport/list_repository.rb #{src_dir} | lib/transport/upload_files.rb #{src_dir} | lib/transport/download_files.rb #{dst_dir}"
		assert_folder_equal( src_dir, dst_dir )
		FileUtils.rm_rf dst_dir
	end

end

