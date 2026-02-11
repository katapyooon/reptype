Type.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('types')

types = [
  { code: "HHHH", name: "フトアゴヒゲトカゲ", description: "がっつり爬虫類ガチ勢タイプ", image_path: "type/beardedDragon.png" },
  { code: "HHHL", name: "ヒョウモントカゲモドキ", description: "触れるけど落ち着きも欲しい", image_path: "type/leopardGecko.png" },
  { code: "HHLH", name: "クレステッドゲッコー", description: "アクティブで個性的", image_path: "type/crestedGecko.png" },
  { code: "HHLL", name: "ヒョウモントカゲモドキ", description: "触れ合い重視・飼いやすさ優先", image_path: "type/leopardGecko.png" },

  { code: "HLHH", name: "ミヤコヒキガエル", description: "触れるけど省スペース派", image_path: "type/miyakoToad.png" },
  { code: "HLHL", name: "ニシアフリカトカゲモドキ", description: "触れるが静かに楽しみたい", image_path: "type/fat-tailedGecko.png" },
  { code: "HLLH", name: "クレステッドゲッコー", description: "触れるけどエサ制限あり", image_path: "type/crestedGecko.png" },
  { code: "HLLL", name: "ヒョウモントカゲモドキ", description: "初心者・触れ合い入門", image_path: "type/leopardGecko.png" },

  { code: "LHHH", name: "ニホンイシガメ", description: "設備必要だが観察が楽しい", image_path: "type/japanesePondTurtle.png" },
  { code: "LHHL", name: "ヘルマンリクガメ", description: "落ち着いた大型志向", image_path: "type/hermann'sTortoise.png" },
  { code: "LHLH", name: "アカメカブトトカゲ", description: "小型・個性派・観賞向き", image_path: "type/red-eyedCrocodileSkink.png" },
  { code: "LHLL", name: "マレーキャットゲッコー", description: "癒し系・静かな鑑賞", image_path: "type/malaysianCatGecko.png" },

  { code: "LLHH", name: "コーンスネーク", description: "省スペース・見た目インパクト", image_path: "type/cornSnake.png" },
  { code: "LLHL", name: "アカメアマガエル", description: "とにかく静かに眺めたい", image_path: "type/red-eyedTreeFrog.png" },
  { code: "LLLH", name: "ヤエヤマアオガエル", description: "低負荷だけど個性あり", image_path: "type/yaeyamaGreenTreeFrog.png" },
  { code: "LLLL", name: "ヒナタヨロイトカゲ", description: "完全観賞・癒し特化", image_path: "type/tropicalGirdledLizard.png" }
]

Type.create!(types)

puts "✅ Type seeds created: #{Type.count} records"