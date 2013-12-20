# -*- coding: utf-8 -*-
#!/home/Atom/.rbenv/shims/ruby ruby
 
require "fileutils"
include FileUtils
 
print "create Makefile..."
MAKE_FILE = File.expand_path("../Makefile")
cp(MAKE_FILE, "Makefile")
src = []
headers = []
 
Dir.glob("*.c").each do |file|
  src << file.to_s
end
 
Dir.glob("*.h").each do |file|
  headers << file.to_s
end
 
buffer = File.open("Makefile","r").read()
buffer.gsub!("##SRCS" , "SRCS = #{src.join(" ")}");
buffer.gsub!("##HEADERS" , "HEADERS = #{headers.join(" ")}");
f = File.open("Makefile","w")
f.write(buffer)
f.close()
puts "DONE"
 
print "make..."
`make`
puts "DONE"
 
CURRENT_DIR = File.expand_path(".")
CURRENT_DIR_NAME = File.basename(Dir.getwd)
DATA_DIR = File.expand_path("../data_set")
cd DATA_DIR
cp(File.join(CURRENT_DIR, "token-list.exe"), ".")
if File.exist?(File.join(DATA_DIR, "#{CURRENT_DIR_NAME}.txt"))
  puts "delete old data...DONE"
  `rm #{CURRENT_DIR_NAME}.txt`
end
 
print "testing..."
Dir.glob("*.mpl").each do |file|
  `echo ------------------------------------ >> #{CURRENT_DIR_NAME}.txt`
  `echo #{file} ---------------------------- >> #{CURRENT_DIR_NAME}.txt`
  `./token-list.exe #{file} >> #{CURRENT_DIR_NAME}.txt`
  `echo ------------------------------------ >> #{CURRENT_DIR_NAME}.txt`
end
puts "DONE"
