#
# Makefile
#

# 最終目的のファイル
TARGET = test

# ソースファイル(*.c)の一覧
SRCS = 

# オブジェクトファイルの(*.o)の一覧
OBJS = ${SRCS:.c=.o}

# ヘッダファイルの一覧
HEADERS = 

#コンパイラ・リンカの指定
#数学関数 → -lm
MYLIBDIR=
CC = gcc
CCFLAGS = -Wall -I/usr/include/malloc
LD = gcc
LDFLAGS = -Wall
LIBS =


#OBJSからTARGETを作る方法
$(TARGET) : $(OBJS)
	 $(LD) $(OBJS) $(LDFLAGS) -o $(TARGET) $(LIBS)

# *.c から*.oを作る方法
.c.o :
	 $(CC) $(CCFLAGS) -c $<

# *.o はHEADERSとMakefileに依存(これらが書き換わったときにも*.oを再構築)
$(OBJS) : $(HEADERS) Makefile

# make clean としたときに実行されるコマンド
clean :
	 rm -f $(TARGET) $(OBJS) core *~
