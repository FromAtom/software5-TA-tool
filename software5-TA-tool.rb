# -*- coding: utf-8 -*-

require "find"
require "optparse"
require "fileutils"
include FileUtils

# 標準出力時に色をつけるためのクラス
class TermColor
  class << self
    # 色を解除
    def reset   ; c 0 ; end

    # 各色
    def red     ; c 31; end
    def green   ; c 32; end
    def yellow  ; c 33; end
    def blue    ; c 34; end
    def magenta ; c 35; end
    def cyan    ; c 36; end
    def white   ; c 37; end

    # カラーシーケンスを出力する
    def c(num)
      print "\e[#{num.to_s}m"
    end
  end
end

def print_blue_arrow
  TermColor.blue
  print "==> "
  TermColor.reset
end

def print_green_arrow
  TermColor.green
  print "--> "
  TermColor.reset
end

# ディレクトリ内を解析してMakefileを生成するクラス
class MakefileGenerater
  def initialize(target_dir_path, makefile_path)
    @target_name = File.basename(target_dir_path).gsub("/","")
    @target_dir_path = File.expand_path(target_dir_path)
    @makefile_path = File.expand_path(makefile_path)
    copy_makefile
    @target_makefile_path = "#{@target_dir_path}/Makefile"
    @buffer = File.open(@target_makefile_path, "r").read
  end

  def generate
    generate_TARGET
    generate_SRCS
    generate_HEADERS

    f = File.open(@target_makefile_path, "w")
    f.write(@buffer)
    f.close
  end

  private
  def generate_TARGET
    @buffer.gsub!("##TARGET", "TARGET = #{@target_name}")
  end

  private
  def generate_SRCS
    src = []
    Dir.glob("#{@target_dir_path}/*.c").each do |file|
      src << File.basename(file)
    end
    @buffer.gsub!("##SRCS", "SRCS = #{src.join(" ")}")
  end

  private
  def generate_HEADERS
    headers = []
    Dir.glob("#{@target_dir_path}/*.h").each do |file|
      headers << File.basename(file)
    end
    @buffer.gsub!("##HEADERS", "HEADERS = #{headers.join(" ")}")
  end

  private
  def copy_makefile
    cp(@makefile_path, File.join(@target_dir_path, "Makefile"))
  end
end

class Manager
  def initialize(target_dir_path, path_to_mpl, path_to_makefile_template)
    print_green_arrow
    print "setup Makefile generater..."
    STDOUT.flush
    @target_dir_path = target_dir_path
    @path_to_mpl = path_to_mpl
    @makefile_generater = MakefileGenerater.new(target_dir_path, path_to_makefile_template)
    puts "DONE"
  end

  def generate_makefile
    print_green_arrow
    print "generate Makefile..."
    STDOUT.flush
    @makefile_generater.generate
    puts "DONE"
  end

  def do_make
    current_dir = File.expand_path(".")
    cd File.expand_path(@target_dir_path)
    print_green_arrow
    puts "make..."
    STDOUT.flush
    puts `make`
    puts "DONE"
    cd current_dir
  end

  def do_make_clean
    current_dir = File.expand_path(".")
    cd File.expand_path(@target_dir_path)
    print_green_arrow
    print "make clean..."
    STDOUT.flush
    puts `make clean`
    puts "DONE"
    cd current_dir
  end

  def compile_mpl
    path_to_exe = File.join(@target_dir_path, File.basename(@target_dir_path))
    result_file = "#{File.basename(path_to_exe)}.txt"

    if File.exist?(result_file)
      print_green_arrow
      print "remove old result_file.txt..."
      STDOUT.flush
      rm result_file
      puts "DONE"
    end

    print_green_arrow
    print "compile sample MPL (result -> #{File.expand_path(result_file)})..."
    STDOUT.flush

    Dir.glob("#{@path_to_mpl}/*.mpl").each do |file|
      `echo ++++++++++++++++++++++++++++++++++ >> #{result_file}`
      `echo === #{file} === >> #{result_file}`
      `#{path_to_exe} #{file} >> #{result_file}`
      `echo ++++++++++++++++++++++++++++++++++ >> #{result_file}`
    end
    puts "DONE"
  end
end

# オプション
config = {
  :arg2 => "./sample_data",
  :arg3 => "./Makefile",
}

# 必須オプションを設定する
required = [:arg1]

OptionParser.new do |opts|
  begin
    # オプション情報を設定する
    opts = OptionParser.new
    opts.on('-t path/to/dir', '--target path/to/dir', "[MUST] Path to target dir") { |v| config[:arg1] = v }
    opts.on('-s path/to/mpl_dir', '--sample path/to/mpl_dir', "default : #{config[:arg2]}") { |v| config[:arg2] = v }
    opts.on('-m path/to/Makefile_template', '--makefile path/to/Makefile_template', "default : #{config[:arg3]}") { |v| config[:arg3] = v }
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

target_dir_path = config[:arg1]
path_to_mpl = config[:arg2]
path_to_makefile_template = config[:arg3]

Dir.glob("*").each do |dir|
  if FileTest::directory?(dir) && /#{target_dir_path}/ =~ File.basename(dir)
    exe_name = File.basename(dir)
    print_blue_arrow
    puts "target: #{exe_name}"
    manager = Manager.new(dir, path_to_mpl, path_to_makefile_template)
    manager.generate_makefile
    manager.do_make
    manager.compile_mpl
  end
end
