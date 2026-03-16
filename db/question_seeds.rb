questions = [
  { category: "A", content: "手に乗せたり触ったりしたい", position: 1 },
  { category: "A", content: "人に慣れやすい性格が良い", position: 2 },
  { category: "A", content: "飼育中に噛まれるリスクはできるだけ避けたい", position: 3 },
  { category: "A", content: "こまめに世話や様子確認をするのは苦にならない", position: 4 },
  { category: "A", content: "基本は鑑賞メインでも問題ない", position: 5 },
  { category: "B", content: "温度・湿度管理を毎日チェックできる", position: 6 },
  { category: "B", content: "大きめのケージを置くスペースがある(横幅90cm以上)", position: 7 },
  { category: "B", content: "電気代や機材費をある程度許容できる", position: 8 },
  { category: "B", content: "日照や照明環境を整えられる", position: 9 },
  { category: "B", content: "10年以上飼い続けることを想定している", position: 10 },
  { category: "C", content: "虫(コオロギ・ゴキブリなど)は平気だ", position: 11 },
  { category: "C", content: "冷凍マウスの取り扱いに抵抗がない", position: 12 },
  { category: "C", content: "ワーム系は平気だ", position: 13 },
  { category: "C", content: "餌代にお金をかけることができる", position: 14 },
  { category: "C", content: "生きた餌を与えることに抵抗がない", position: 15 },
  { category: "D", content: "見た目の可愛さはとても重要", position: 16 },
  { category: "D", content: "野性味や迫力を重視したい", position: 17 },
  { category: "D", content: "見ていて癒される存在が良い", position: 18 },
  { category: "D", content: "よく動き回る生き物が好き", position: 19 },
  { category: "D", content: "色や模様のバリエーション(モルフ)を楽しみたい", position: 20 },
]

questions.each do |attrs|
  Question.find_or_create_by!(category: attrs[:category], position: attrs[:position]) do |q|
    q.content = attrs[:content]
  end
end

puts "Seeded #{Question.count} questions"
