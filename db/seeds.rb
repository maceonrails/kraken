puts "create S'avenue company"

company = Company.create( name: "Kaki Lima Square")
outlet = company.outlets.create( name: "KaLi Square Manunggal", taxs: {ppn: 10, service: 5})

puts "create printer"
3.times do |i|
  Printer.create(
    name: "Printer #{i+1}",
    printer: "/dev/usb/lp#{i}",
    default: true,
  )
  puts "create printer #{i+1}"
end

puts "create user"

8.times do |i|
	user = User.create role: :owner, password: '12345678', email: "owner#{i+1}@xsquare.com", company_id: company.id
	user.create_profile(
		name: "Owner #{i+1}", 
		address: Faker::Address.street_address, 
		phone: Faker::PhoneNumber.cell_phone, 
	)
	puts "create owner #{i+1}"
end

3.times do |i|
	user = User.create role: :captain, password: '12345678', email: "captain#{i+1}@xsquare.com", outlet_id: outlet.id
	user.create_profile(
		name: "Captain #{i+1}", 
		address: Faker::Address.street_address, 
		phone: Faker::PhoneNumber.cell_phone, 
	)
	puts "create captain #{i+1}"
end

3.times do |i|
	user = User.create role: :manager, password: '12345678', email: "manager#{i+1}@xsquare.com", outlet_id: outlet.id
	user.create_profile(
		name: "Manager #{i+1}", 
		address: Faker::Address.street_address, 
		phone: Faker::PhoneNumber.cell_phone, 
		join_at: Faker::Time.between(1.year.ago, DateTime.now), 
		contract_until: Faker::Time.between(DateTime.now, 2.year.from_now)
	)
	puts "create manager #{i+1}"
end

5.times do |i|
	user = User.create role: :cashier, password: '12345678', email: "cashier#{i+1}@xsquare.com", outlet_id: outlet.id
	user.create_profile(
		name: "Cashier #{i+1}", 
		address: Faker::Address.street_address, 
		phone: Faker::PhoneNumber.cell_phone, 
		join_at: Faker::Time.between(1.year.ago, DateTime.now), 
		contract_until: Faker::Time.between(DateTime.now, 2.year.from_now)
	)
	puts "create cashier #{i+1}"
end

20.times do |i|
	user = User.create role: :tenant, password: '12345678', email: "tenant#{i+1}@xsquare.com", outlet_id: outlet.id
	user.create_profile(
		name: "Tenant #{i+1}", 
		address: Faker::Address.street_address, 
		phone: Faker::PhoneNumber.cell_phone, 
		join_at: Faker::Time.between(1.year.ago, DateTime.now), 
		contract_until: Faker::Time.between(DateTime.now, 2.year.from_now)
	)
	puts "create tenant #{i+1}"
end

# choices
puts "create choice"
hot = Choice.create name: "HOT"
cold = Choice.create name: "COLD"
bebas = Choice.create name: "BEBAS"
paha = Choice.create name: "PAHA"
dada = Choice.create name: "DADA"

# Drinks Menu
TEA = [
	{
		name: 'BANANA GREEN TEA',
		price: 20900,
		choices: [hot, cold]
	},
	{
		name: 'TEH TAWAR',
		price: 5900,
		choices: [hot, cold]
	},
	{
		name: 'MINT TEA',
		price: 11900,
		choices: [hot, cold]
	},
	{
		name: 'MINT TEA',
		price: 11900,
		choices: [hot, cold]
	},
	{
		name: 'LYCHEE TEA',
		price: 11900
	},
	{
		name: 'GIANT LEMON TEA',
		price: 22900
	},
	{
		name: 'SWEET TEA',
		price: 8900,
		choices: [hot, cold]
	},
	{
		name: 'LEMON TEA',
		price: 11900,
		choices: [hot, cold]
	},
	{
		name: 'GIANT SWEET TEA',
		price: 8900
	},
	{
		name: 'GREEN TEA LATTE',
		price: 20900,
		choices: [hot, cold]
	},
	{
		name: 'THAI TEA',
		price: 16900
	}
]

COFFEE = [
	{
		name: 'BANANA COFFEE LATTE',
		price: 19900,
		choices: [hot, cold]
	},
	{
		name: 'KOPI TUBRUK',
		price: 11500
	},
	{
		name: 'BOBER CAPPUCCINO',
		price: 19900,
		choices: [hot, cold]
	},
	{
		name: 'VANILLA COFFEE CREAMY',
		price: 18900,
		choices: [hot, cold]
	},
	{
		name: 'ESPRESSO',
		price: 13500,
		choices: [hot, cold]
	},
	{
		name: 'BOBER OREO',
		price: 20900
	},
	{
		name: 'MOCCA CARAMEL',
		price: 19900
	},
	{
		name: 'WHITE CAPPUCCINO',
		price: 18900,
		choices: [hot, cold]
	},
	{
		name: 'BOBER DE CREAMY',
		price: 19900,
		choices: [hot, cold]
	},
	{
		name: 'COFFEE LATTE',
		price: 16500,
		choices: [hot, cold]
	},
	{
		name: 'CAPPUCCINO CARAMEL',
		price: 20900,
		choices: [hot, cold]
	},
	{
		name: 'FRAPE CAPPUCCINO ORANGE',
		price: 22900
	},
	{
		name: 'GREEN TEA CAPPUCCINO',
		price: 19900,
		choices: [hot, cold]
	}
]

SHAKE_IT_GOOD = [
	{
		name: "MOJITO",
		price: 15900
	},
	{
		name: "LOVE STORY",
		price: 22900
	},
	{
		name: "LEMON SQUASH",
		price: 18900
	},
	{
		name: "YOGHURT MESIR",
		price: 22900
	},
	{
		name: "STRAWBERRY BLIND",
		price: 22900
	},
	{
		name: "BLACKSPOT VANILLA",
		price: 19900
	},
	{
		name: "LYCHEE SQUASH",
		price: 17900
	},
	{
		name: "BOBER TARO SMOOTHIES",
		price: 19900
	},
	{
		name: "BOBER YOGHURT GREEN TEA",
		price: 19900
	},
	{
		name: "BOBER YOGHURT ORANGE",
		price: 19900
	}
]

FRESH_MILKSHAKE = [
	{
		name: "VANILLA MILKSHAKE",
		price: 18900
	},
	{
		name: "STRAWBERRY MILKSHAKE",
		price: 18900
	},
	{
		name: "CHOCOLATE MILKSHAKE",
		price: 18900
	}
]

DRINK_IN_THE_BOTTLE = [
	{
		name: "AMIDIS 330 ml",
		price: 5000
	},
	{
		name: "COCA COLA",
		price: 7000
	},
	{
		name: "FANTA",
		price: 7000
	},
	{
		name: "TEH BOTOL SOSRO",
		price: 7000
	},
	{
		name: "YOGHURT JONGMAN LYCHEE",
		price: 10000
	},
	{
		name: "YOGHURT JONGMAN STRAWBERRY",
		price: 10000
	},
]

JUICE_IN_BOBER = [
	{
		name: "STRAWBERRY JUICE",
		price: 16900
	},
	{
		name: "ORANGE JUICE",
		price: 14900,
		choices: [hot, cold]
	},
	{
		name: "MELON JUICE",
		price: 14900
	},
	{
		name: "MANGO JUICE",
		price: 16900
	},
	{
		name: "GUAVA JUICE",
		price: 14900
	},
	{
		name: "SOURSOP JUICE",
		price: 14900
	},
]

FLOAT = [
	{
		name: "COFFEE FLOAT",
		price: 16900
	},
	{
		name: "CHOCOLATE FLOAT",
		price: 16900
	},
	{
		name: "COLA FLOAT",
		price: 16900
	},
	{
		name: "FANTA FLOAT",
		price: 16900
	},
]

SHEESHA_SMOKING = [
	{
		name: "SHEESHA SINGLE",
		price: 30900
	},
	{
		name: "SHEESHA DOUBLE",
		price: 40900
	},
	{
		name: "SHEESHA TRIPLE",
		price: 45900
	},
]

OTHERS = [
	{
		name: "SUSU JAHE",
		price: 15900
	},
	# {
	# 	name: "ALL ABOUT THAT FRESH",
	# 	price: 16900
	# },
	# {
	# 	name: "RED KISS",
	# 	price: 21900
	# },
]

MILK_AND_CHOCOLATE = [
	{
		name: "BANANA MILK",
		price: 19900,
		choices: [hot, cold]
	},
	{
		name: "MILK TEA",
		price: 12500,
		choices: [hot, cold]
	},
	{
		name: "VANILLA MILK",
		price: 15900,
		choices: [hot, cold]
	},
	{
		name: "CHOCOLATE MILK",
		price: 16900,
		choices: [hot, cold]
	},
	{
		name: "MILK COLA",
		price: 13500
	},
	{
		name: "MILK FANTA",
		price: 13500
	},
	{
		name: "MILK SODA",
		price: 13500
	},
	{
		name: "CHOCOLATE CARAMEL",
		price: 22900,
		choices: [hot, cold]
	},
	{
		name: "CHOCOLATE CREAMY",
		price: 17900,
		choices: [hot, cold]
	},
]

# Foods Menu
SOUP_AND_SALAD = [
	# {
	# 	name: "CREAM SOUP + FRENCH BREAD",
	# 	price: 17900
	# },
	{
		name: "CHICKEN GARDEN SALAD",
		price: 19900
	},
]

ASIA_CARRERA = [
	{
		name: "CHILI CHICKEN",
		price: 25900
	},
	{
		name: "CHICKEN KATSU",
		price: 26900
	},
	{
		name: "SNOWY CHICKEN",
		price: 26900
	},
	{
		name: "BEEF CURRY",
		price: 29900
	},
	{
		name: "CHICKEN CURRY",
		price: 25900
	},
	{
		name: "BLACK PEPPER BEEF",
		price: 29900
	},
	{
		name: "DRAGON BITE CHICKEN",
		price: 29900
	},
	{
		name: "CHICKEN HONEY LEMON",
		price: 26900
	},
	{
		name: "CHICKEN KUNGPAO PANDA",
		price: 26900
	},
]

EURO_TRIP = [
	{
		name: "SPAGHETTI BOLOGNAISE",
		price: 23900
	},
	{
		name: "SPAGHETTI AGLIO OLIO BOBER",
		price: 28900
	},
	{
		name: "FETTUCCINE CARBONARA",
		price: 26900
	},
	{
		name: "MIX STEAK WITH SAUSAGE",
		price: 49900
	},
	{
		name: "SIRLOIN STEAK",
		price: 47900
	},
	{
		name: "CHICKEN STEAK",
		price: 37900
	},
	{
		name: "BEEF CORDON BLEU",
		price: 47900
	},
	{
		name: "TENDERLOIN STEAK",
		price: 49900
	},
	{
		name: "CHICKEN CORDON BLEU",
		price: 39900
	},
	{
		name: "POTATO MOZARELLA",
		price: 30900
	},
	{
		name: "SPAGHETTI KAGET CENAT CENUT",
		price: 24900
	},
	{
		name: "FETTUCCINE PLECING SETAN",
		price: 24900
	},
]

SIGNATURE_DISH = [
	{
		name: "AYAM PLECING SETAN",
		price: 29900
	},
	{
		name: "AYAM SUWIR DISTORSI",
		price: 31900
	},
	{
		name: "ORIENTAL SPICY CHICKEN GRILL",
		price: 25900
	},
]

INDONESIA_UNITE = [
	{
	name: "AYAM KAGET CENAT CENUT",
	price: 27900
	},
	{
		name: "SOTO BETAWI",
		price: 29900
	},
	{
		name: "NASI RAWON",
		price: 29900
	},
	{
		name: "SOP BUNTUT BBQ",
		price: 49900
	},
	{
		name: "SOP BUNTUT KUAH",
		price: 49900
	},
	{
		name: "SOP IGA BAKAR BOBER",
		price: 49900
	},
	{
		name: "AYAM COBEK",
		price: 27900
	},
	{
		name: "AYAM RICA RICA",
		price: 28900
	},
	{
		name: "AYAM CAH JAMUR",
		price: 21900
	},
	{
		name: "AYAM KECAP MENTEGA",
		price: 28900
	},
]

# NEW_MENU = [
# 	{
# 		name: "CILOK BAPER SAUS KACANG",
# 		price: 15900
# 	},
# 	{
# 		name: "CILOK BAPER SPICY",
# 		price: 15900
# 	},
# 	{
# 		name: "PIZZA BOBER SUPREME",
# 		price: 36900
# 	},
# 	{
# 		name: "PIZZA BEEF LICIOUS",
# 		price: 36900
# 	},
# 	{
# 		name: "PIZZA CHEEZY SQUEZY",
# 		price: 36900
# 	}
# ]

FRIED_RICE = [
	{
		name: "NASI GORENG GILA",
		price: 25900
	},
	{
		name: "BEEF BUTTER RICE",
		price: 29900
	},
	{
		name: "NASI GORENG BOBER",
		price: 30900
	},
	{
		name: "NASI GORENG KAMBING",
		price: 29900
	},
	{
		name: "NASI GORENG SEAFOOD",
		price: 29900
	},
	{
		name: "NASI GORENG BASO SOSIS",
		price: 25900
	},
]

CEMAL_CEMIL_CIAMIK = [
	{
		name: "LUMPIA",
		price: 19900
	},
	{
		name: "CALAMARI",
		price: 25900
	},
	{
		name: "GIANT BOBER SAMPLER",
		price: 39900
	},
	{
		name: "TORTILLA CHIPS",
		price: 17900
	},
	{
		name: "SAUSAGE + FRENCH FRIES",
		price: 28900
	},
	{
		name: "AUTHENTIC CHICKEN + FRENCH FRIES",
		price: 23900
	},
	{
		name: "BOBER SAMPLER",
		price: 29900
	},
	{
		name: "GIANT FRENCH FRIES",
		price: 36900
	},
	{
		name: "CHICKEN WINGS",
		price: 28900
	},
	{
		name: "TEMPE MENDOAN",
		price: 14900
	},
	{
		name: "FRENCH FRIES",
		price: 19900
	},
	{
		name: "FRIED MUSHROOM",
		price: 23900
	},
	# {
	# 	name: "I CHEESE YOU",
	# 	price: 25900
	# },
	# {
	# 	name: "MANGO BINGGO",
	# 	price: 24900
	# },
	{
		name: "SEBLAK BLAKAN",
		price: 14900
	},
	{
		name: "WAFFLE POTATO",
		price: 22900
	},
]


DRINKS = [
	{
		name: "TEA",
		products: TEA
	},
	{
		name: "COFFEE",
		products: COFFEE
	},
	{
		name: "SHAKE IT GOOD",
		products: SHAKE_IT_GOOD
	},
	{
		name: "FRESH MILKSHAKE",
		products: FRESH_MILKSHAKE
	},
	{
		name: "DRINK IN THE BOTTLE",
		products: DRINK_IN_THE_BOTTLE
	},
	{
		name: "JUICE IN BOBER",
		products: JUICE_IN_BOBER
	},
	{
		name: "FLOAT",
		products: FLOAT
	},
	{
		name: "OTHERS",
		products: OTHERS
	},
	{
		name: "MILK AND CHOCOLATE",
		products: MILK_AND_CHOCOLATE
	},
]

FOODS = [
	{
		name: "SOUP AND SALAD",
		products: SOUP_AND_SALAD
	},
	{
		name: "ASIA CARRERA",
		products: ASIA_CARRERA
	},
	{
		name: "EURO TRIP",
		products: EURO_TRIP
	},
	{
		name: "SIGNATURE DISH",
		products: SIGNATURE_DISH
	},
	{
		name: "INDONESIA UNITE",
		products: INDONESIA_UNITE
	},
	# {
	# 	name: "NEW MENU",
	# 	products: NEW_MENU
	# },
	{
		name: "FRIED RICE",
		products: FRIED_RICE
	},
]

SHEESA_AND_SNACKS = [
	{
		name: "SHEESHA SMOKING",
		products: SHEESHA_SMOKING
	},
	{
		name: "CEMAL CEMIL CIAMIK",
		products: CEMAL_CEMIL_CIAMIK
	},
]

categories = [
	{
		name: "DRINKS",
		sub_categories: DRINKS
	},
	{
		name: "FOODS",
		sub_categories: FOODS
	},
	{
		name: "SHEESA AND SNACKS",
		sub_categories: SHEESA_AND_SNACKS
	},
]

puts "start create category"

categories.each do |cat|
	puts ""
	puts "create category #{cat[:name]}"
	puts "======================================"
	category = ProductCategory.create name: cat[:name]
	cat[:sub_categories].each do |sub_cat|
		puts ""
		puts "create sub category #{sub_cat[:name]}"
		puts "======================================"
		sub_category = category.product_sub_categories.create name: sub_cat[:name]
		sub_cat[:products].each do |menu|
			puts "create menu #{menu[:name]}"

			product = sub_category.products.build(menu)

			if product.save
				picture = ProductImage.new
				picture.file = File.open(File.join(Rails.root, "db/product_images/#{cat[:name].titleize}/#{sub_cat[:name].titleize}/#{menu[:name].titleize}.jpg"))
				picture.save!
				product.update!(
					picture: picture.file.url, 
					default_price: menu[:price], 
					tenant: User.tenant.order("RANDOM()").first
				)
			end
		end
	end
end

puts "start create table"
200.times do |i|
	Table.create name: "#{i + 1}", location: 'savenue', outlet: outlet
	puts "create table #{i + 1}"
end

200.times do |i|
  discount = Discount.create(
    name: Faker::Lorem.sentence,
    updated_by: User.manager.order("RANDOM()").first,
    start_date: Faker::Time.between(DateTime.now - 1, DateTime.now),
    end_date: Faker::Time.between(DateTime.now - 1, DateTime.now),
    start_time: "#{Array(1..12).sample}:58".to_time,                     
    end_time: "#{Array(12..23).sample}:59".to_time,                            
    days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"].sort_by{rand}[0..(Array(0..6).sample)]
  )
  if i.odd?
  	discount.update_attribute :amount, [5000, 10000, 15000, 20000].sample
  else   
    discount.update_attribute :percentage, Array(1..100).sample
  end

  puts "create discount #{i}"
end

300.times do |i|
  ProductDiscount.create(
    product: Product.order("RANDOM()").first,
    discount: Discount.order("RANDOM()").first,
  )
  puts "create product discount #{i}"
end

500.times do |i|
  Payment.create(
    cashier: User.cashier.order("RANDOM()").first,
    created_at: Faker::Time.between(1.year.ago, DateTime.now)
  )
  puts "create payment #{i}"
end

1000.times do |i|
  Order.create(
    name: Faker::Name.name,
    table: Table.order("RANDOM()").first,
    waiting: false,                                   
    discount_by: User.manager.order("RANDOM()").first,
    person: Array(1..10).sample,
    cashier: User.cashier.order("RANDOM()").first,
    created: true,                            
    payment: Payment.order("RANDOM()").first,
    created_at: Faker::Time.between(1.year.ago, DateTime.now)
  )
  puts "create order #{i}"
end

4000.times do |i|
	product = Product.order("RANDOM()").first
	order = Order.order("RANDOM()").first
  item = OrderItem.new(
    order: order,
    product: product,
    quantity: Array(1..10).sample,
    choice: product.choices.sample,
    note: Faker::Lorem.sentence,
    served: true,
    paid: true,
    discount: product.discounts.sample,
    created_at: order.created_at
  )

  item.paid_quantity = 0
	item.void_quantity = 0
	item.oc_quantity = 0

  while item.quantity != (item.void_quantity + item.oc_quantity + item.paid_quantity)
  	item.paid_quantity = Array(0..item.quantity).sample
  	item.void_quantity = Array(0..(item.quantity - item.paid_quantity)).sample
  	item.oc_quantity = item.quantity - (item.paid_quantity + item.void_quantity)
  end

  if item.void_quantity > 0
  	item.void_by = User.manager.order("RANDOM()").first
  	item.void_note = Faker::Lorem.sentence
  end
  if item.oc_quantity > 0
  	item.oc_by = User.manager.order("RANDOM()").first
  	item.oc_note = Faker::Lorem.sentence
  end

 	item.save!
 	puts "create order items #{i}"
end

Payment.all.each_with_index do |payment, i|

	if i % 5 == 0
		payment.discount_amount = payment.sub_total*rand()
		payment.discount_by = User.manager.order("RANDOM()").first
	elsif i % 3 == 0
		payment.discount_percent = rand(0..100)
		payment.discount_by = User.manager.order("RANDOM()").first
	end

	payment.debit_amount = rand(0..payment.total.to_i)
	payment.credit_amount = rand(0..(payment.total.to_i - payment.debit_amount.to_i))
	payment.cash_amount = payment.total - (payment.debit_amount.to_i + payment.credit_amount.to_i)

  if payment.debit_amount.to_f > 0
  	payment.debit_name = Faker::Business.credit_card_type
  	payment.debit_number = Faker::Business.credit_card_number
  end
  if payment.credit_amount.to_f > 0
  	payment.credit_name = Faker::Business.credit_card_type
  	payment.credit_number = Faker::Business.credit_card_number
  end

 	payment.save!
 	puts "create payment amount and discount #{i}"
end

Order.all.each do |order|
	order.destroy if order.order_items.blank?
end

Payment.all.each do |payment|
	payment.destroy if payment.orders.blank?
end




