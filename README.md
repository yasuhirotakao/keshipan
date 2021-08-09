# fluentd のプライグイン個人情報削除keshipan


## プログラム本体
plugin/filter_keshipan.rb
 -> /etc/td-agent/plugin/filter_keshipan.rb

* filterの機能で個人情報が検知された場合は、マスクする。
* /var/log/messageにエラー(マスクされたメッセージを付加して)として出力する。
* チェックする内容
 - メールアドレス （正規表現）
 - クレジットカード番号 (BINレンジ指定) イシュアシステム内の場合、存在しうるカード番号は、BINレンジが固定されるため誤マッチングを防ぐ
 - 氏名（漢字、かな、カタカナ ローマ字）上位2000
 - 住所(漢字、主要な地名)
     主要地名
     ■各都道府県において表示される基準地・重要地･主要地一覧表
     https://www.mlit.go.jp/road/sign/sign/annai/6-hyou-timei.htm

## サンプル設定
 td-agent.conf
 -> /etc/td-agent

## 個人情報ファイル
 配置場所 /etc/td-agent/plugin/
### クレジットカード番号のBINレンジ毎に編集が必要
keshipan_bin.dat

### マルチバイト　苗字(上位2000) 漢字、ひらがな、かたかな
keshipan_multi_byte.dat

### 苗字(上位2000) ローマ字 ただし４文字以下は除外
keshipan_single_byte.dat
