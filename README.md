# Software5-TA-tool
ソフトウェア演習VのTA業務を楽にするためのツールです。

# 使い方

##まずはクローン

```
$ git clone git@github.com:FromAtom/software5-TA-tool.git
```

##フォルダ構成
下記構成を想定してパスのデフォルト値を設定しています。`11111`とか`22222`には学籍番号を入れると評価が楽ですよ。

```
.
├── 11111
│   ├── piyopiyp.c
│   ├── hogehoge.c
│   └── fugafuga.h
├── 22222
│   ├── piyopiyp.c
│   ├── hogehoge.c
│   └── fugafuga.h
├── Makefile
├── README.md
├── sample_data
│   ├── sample11.mpl
│   ├── …
│   └── sample29p.mpl
└── software5-TA-tool.rb
```

## 基本コマンド

```
$ ruby software5-TA-tool.rb -t 11111
```
とやると、`11111/`内で

- Makefile生成
- make実行
- サンプルを利用して評価
- make clean実行

してくれます。ちなみにターゲット指定には正規表現が使えるので

```
$ ruby software5-TA-tool.rb -t ‘[0-9]+’
```

としてあげると、数字だけで構成されてるディレクトリ全てに対して評価を行います。便利！

## オプション
便利なオプションもつけておきました。

```
$ ruby software5-TA-tool.rb -h
```
でヘルプが見れます。

### [必須]評価対象のパス指定
```
-t, --target path/to/dir         [MUST] Path to target dir
```

### [任意]サンプルデータ（*.mpl）のパス指定

```
-s, --sample path/to/mpl_dir     default : ./sample_data
```

### [任意]Makefileテンプレートのパス指定

```
-m, --makefile path/to/Makefile_template,    default : ./Makefile
```

### 処理制御用オプション
「`make`はしたいけど、評価はしたくない」とか、「評価だけ行いたい」時に使います。4つありますが、組み合わせて利用することができます。

+ --no_generate	：Makefileを生成しない
+ --no_make 		：`make`を行わない
+ --no_test		：評価を行わない
+ --no_makeclean	：`make clean`を行わない
