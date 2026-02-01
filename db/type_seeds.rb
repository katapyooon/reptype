Type.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('types')

types = [
  { code: "HHHH", name: "フトアゴヒゲトカゲ", description: "がっつり爬虫類ガチ勢タイプ" },
  { code: "HHHL", name: "ヒョウモントカゲモドキ", description: "触れるけど落ち着きも欲しい" },
  { code: "HHLH", name: "クレステッドゲッコー", description: "アクティブで個性的" },
  { code: "HHLL", name: "ヒョウモントカゲモドキ", description: "触れ合い重視・飼いやすさ優先" },
  { code: "HLHH", name: "ミヤコヒキガエル", description: "触れるけど省スペース派" },
  { code: "HLHL", name: "ニシアフリカトカゲモドキ", description: "触れるが静かに楽しみたい" },
  { code: "HLLH", name: "クレステッドゲッコー", description: "触れるけどエサ制限あり" },
  { code: "HLLL", name: "ヒョウモントカゲモドキ", description: "初心者・触れ合い入門" },
  { code: "LHHH", name: "ニホンイシガメ", description: "設備必要だが観察が楽しい" },
  { code: "LHHL", name: "ヘルマンリクガメ", description: "落ち着いた大型志向" },
  { code: "LHLH", name: "アカメカブトトカゲ", description: "小型・個性派・観賞向き" },
  { code: "LHLL", name: "マレーキャットゲッコー", description: "癒し系・静かな鑑賞" },
  { code: "LLHH", name: "コーンスネーク", description: "省スペース・見た目インパクト" },
  { code: "LLHL", name: "アカメアマガエル", description: "とにかく静かに眺めたい" },
  { code: "LLLH", name: "ヤエヤマアオガエル", description: "低負荷だけど個性あり" },
  { code: "LLLL", name: "グリーンアノール", description: "完全観賞・癒し特化" }
]

Type.create!(types)

puts "✅ Type seeds created: #{Type.count} records"
