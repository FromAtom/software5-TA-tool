# -*- coding: utf-8 -*-

require "optparse"
require "fileutils"
include FileUtils

class MakefileGenerater
  def initialize(target_dir_path, makefile_path)
    @target_dir_path = File.expand_path(target_dir_path)
    @makefile_path = File.expand_path(makefile_path)

  end

  def generate
    copy_makefile()

    target = File.basename(@target_dir_path)

    src = []
    Dir.glob("#{@target_dir_path}/*.c").each do |file|
      src << file.to_s
    end

    headers = []
    Dir.glob("*.h").each do |file|
      headers << file.to_s
    end

    target_makefile_path = "#{@target_dir_path}/Makefile"
    buffer = File.open(target_makefile_path, "r").read()
    buffer.gsub!("##TARGET", "TARGET = #{target}");
    buffer.gsub!("##SRCS", "SRCS = #{src.join(" ")}");
    buffer.gsub!("##HEADERS", "HEADERS = #{headers.join(" ")}");

    f = File.open(target_makefile_path, "w")
    f.write(buffer)
    f.close()
  end

  private
  def copy_makefile
    cp(@makefile_path, File.join(@target_dir_path, "Makefile"))
  end
end

config = {
  :arg3 => 'value3',
}

# 必須オプションを設定する
required = [:arg1]

OptionParser.new do |opts|
  begin
    # オプション情報を設定する
    opts = OptionParser.new
    opts.on('-t ARG1', '--target ARG1', "[MUST] Path to target dir") { |v| config[:arg1] = v }
    opts.on('-m ARG3', '--makefile ARG3', "[任意]ＺＺＺを指定する（デフォルト値：#{config[:arg3]}）") { |v| config[:arg3] = v }
    opts.parse!(ARGV)

    # 必須オプションをチェックする
    for field in required
      raise ArgumentError.new("必須オプション（#{field}）が不足しています。") if config[field].nil?
    end
  rescue => e
    puts opts.help
    puts
    puts e.message
    exit 1
  end
end

makefile_generater = MakefileGenerater.new(config[:arg1], "./Makefile")
makefile_generater.generate
#
#URRENT_DIR = File.expand_path(".")
#URRENT_DIR_NAME = File.basename(Dir.getwd)
#ATA_DIR = File.expand_path("../data_set")
#d DATA_DIR
#p(File.join(CURRENT_DIR, "token-list.exe"), ".")
#f File.exist?(File.join(DATA_DIR, "#{CURRENT_DIR_NAME}.txt"))
# puts "delete old data...DONE"
# `rm #{CURRENT_DIR_NAME}.txt`
#nd
#
#rint "testing..."
#ir.glob("*.mpl").each do |file|
# `echo ------------------------------------ >> #{CURRENT_DIR_NAME}.txt`
# `echo #{file} ---------------------------- >> #{CURRENT_DIR_NAME}.txt`
# `./token-list.exe #{file} >> #{CURRENT_DIR_NAME}.txt`
# `echo ------------------------------------ >> #{CURRENT_DIR_NAME}.txt`
#nd
#uts "DONE"
