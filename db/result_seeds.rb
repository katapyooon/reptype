# Create Result records for all 16 combinations of H/L for 4 categories (A,B,C,D)
codes = [ 'H', 'L' ].repeated_permutation(4).map(&:join)

# 既存の Type を取得（16個あると仮定）
types = Type.order(:id).limit(16).to_a

if types.count < 16
  puts "Error: Need at least 16 Type records. Found: #{types.count}"
  exit
end

codes.each_with_index do |code, index|
  Result.find_or_create_by!(code: code) do |r|
    r.type = types[index]
  end
end

puts "Seeded #{Result.count} results with type mappings"
