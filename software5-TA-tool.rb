# -*- coding: utf-8 -*-

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
  end

  def generate
    copy_makefile()

    src = []
    Dir.glob("#{@target_dir_path}/*.c").each do |file|
      src << File.basename(file)
    end

    headers = []
    Dir.glob("#{@target_dir_path}/*.h").each do |file|
      headers << File.basename(file)
    end

    target_makefile_path = "#{@target_dir_path}/Makefile"
    buffer = File.open(target_makefile_path, "r").read()
    buffer.gsub!("##TARGET", "TARGET = #{@target_name}");
    buffer.gsub!("##SRCS", "SRCS = #{src.join(" ")}");
    buffer.gsub!("##HEADERS", "HEADERS = #{headers.join(" ")}");

    f = File.open(target_makefile_path, "w")
    f.write(buffer)
    f.close()
  end

  def get_target_name
    return @target_name
  end

  private
  def copy_makefile
    cp(@makefile_path, File.join(@target_dir_path, "Makefile"))
  end
end

# makeを実行するメソッド
def do_make(target_dir_path)
  current_dir = File.expand_path(".")
  cd File.expand_path(target_dir_path)
  print_green_arrow
  print "make..."
  STDOUT.flush
  puts `make`
  puts "DONE"
  cd current_dir
end

def do_make_clean(target_dir_path)
  current_dir = File.expand_path(".")
  cd File.expand_path(target_dir_path)
  print_green_arrow
  print "make clean..."
  STDOUT.flush

  puts `make clean`
  puts "DONE"
  cd current_dir
end

def compile_mpl(path_to_mpls, path_to_exe)
  result_file = "#{File.basename(path_to_exe)}.txt"
  print_green_arrow
  print "compile sample MPL (result file : #{result_file})..."
  STDOUT.flush

  Dir.glob("#{path_to_mpls}/*.mpl").each do |file|
    `echo ------------------------------------ >> #{result_file}`
    `echo #{file} ---------------------------- >> #{result_file}`
    `#{path_to_exe} #{file} >> #{result_file}`
    `echo ------------------------------------ >> #{result_file}`
  end
  puts "DONE"
end

# オプション
config = {
  :arg2 => "./sample_data",
}

# 必須オプションを設定する
required = [:arg1]

OptionParser.new do |opts|
  begin
    # オプション情報を設定する
    opts = OptionParser.new
    opts.on('-t path/to/dir', '--target path/to/dir', "[MUST] Path to target dir") { |v| config[:arg1] = v }
    opts.on('-m path/to/mpls_dir', '--target path/to/mpls_dir', "default : #{config[:arg2]}") { |v| config[:arg2] = v }
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

print_blue_arrow
puts "target: #{config[:arg1]}"

print_green_arrow
print "setup Makefile generater..."
STDOUT.flush
makefile_generater = MakefileGenerater.new(target_dir_path, "./Makefile")
puts "DONE"

print_green_arrow
print "generate Makefile..."
STDOUT.flush
makefile_generater.generate
puts "DONE"

do_make(target_dir_path)
compile_mpl(config[:arg2], File.join(File.expand_path(target_dir_path), makefile_generater.get_target_name))
