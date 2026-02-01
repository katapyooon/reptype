# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create Result records for all 16 combinations of H/L for 4 categories (A,B,C,D)
codes = ['H', 'L'].repeated_permutation(4).map(&:join)

codes.each do |code|
	Result.find_or_create_by!(code: code) do |r|
		r.type = default_type
		r.summary = "Summary for #{code}"
		r.explanation = "Explanation for #{code}"
	end
end

puts "Seeded #{Result.count} results (codes: #{Result.pluck(:code).uniq.size}) and default type: #{default_type.name}"
