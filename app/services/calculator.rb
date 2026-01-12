class Calculator
    # ここに計算ロジックを追加します
    # カテゴリごとの計算方法を実装します
    def self.calculate_by_category(category, answers)
        case category
        when "A"
            # カテゴリAの計算ロジック
            answers.sum { |answer| answer.value.to_i }
        when "B"
            # カテゴリBの計算ロジック
            answers.sum { |answer| answer.value.to_i }
        when "C"
            # カテゴリCの計算ロジック
            answers.sum { |answer| answer.value.to_i }
        when "D"
            # カテゴリDの計算ロジック
            answers.sum { |answer| answer.value.to_i }
        else
            0
        end

        # それぞれのcategoryでscoreの合計(sum)が13未満の場合はL、13以上の場合はHを返す
        score = answers.sum { |answer| answer.value.to_i }
        score < 13 ? "L" : "H" 

        # 4つのcategoryの結果を組み合わせて最終的な評価を返すロジックもここに追加(例：HHLH、LLHHなど)
        # 仮にcategoryA, B, C, Dの結果がそれぞれresultA, resultB, resultC, resultDとして得られたと仮定
        # 例: resultA = "H", resultB = "L", resultC = "H", resultD = "L"
        # 最終的な評価は "HLHL" となる
        # 実際には、各categoryの結果を結合して返すロジックを実装する
        # ここでは、カテゴリごとの結果を結合して返すロジックを追加
        category_results = []
        category_results << calculate_by_category("A", answers)
        category_results << calculate_by_category("B", answers)
        category_results << calculate_by_category("C", answers)
        category_results << calculate_by_category("D", answers)

        category_results.join("")

    end
end