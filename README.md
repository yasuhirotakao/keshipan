# keshipan
## プログラム本体
plugin/filter_keshipan.rb
 -> /etc/td-agent/plugin/filter_keshipan.rb

##サンプル設定
 td-agent.conf
 -> /etc/td-agent


##個人情報ファイル
 配置場所 /etc/td-agent/plugin/
### クレジットカード番号のBINレンジ毎に編集が必要
keshipan_bin.dat

### マルチバイト　苗字(上位2000) 漢字、ひらがな、かたかな
keshipan_multi_byte.dat

### 苗字(上位2000) ローマ字 ただし４文字以下は除外
keshipan_single_byte.dat
