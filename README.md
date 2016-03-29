# env_tabular

env_tabularは、SettingsLogicのsettings.ymlとかActiveRecordのdatabase.ymlみたいなものの
設定漏れをなんとかして減らそうと思って作った書き捨てのHTMLジェネレータです。

Settings.hoge.fuga みたいな値について、env(intとかstgとかprdとか)ごとに
「他と値が異なる場合には、違う背景色で表示」することで目grepを助けます。

## sample
![sample](https://raw.githubusercontent.com/takada-s/env_tabular/master/ss.png)

## usage
```
$ bundle
$ bundle exec ruby tabulate.rb target_yaml_file > some_file.html
```

### オプション
- `-i ignore_list`, `--ignore=ignore_list`: 対象から除外するenvをカンマ区切りで指定します。
- `-o filename`, `--output=filename`: 結果を標準出力ではなく指定されたファイルに書き出します。 

## FAQ
### うまく評価できない項目がある
`ENV[hoge]` や `Rails.root` についてはmethod_missingやconst_missingでハンドリングしています。
見よう見まねでなんとかしてみてください。わからない場合は、メタプログラミングRubyを読みましょう。

## ライセンス
MIT
