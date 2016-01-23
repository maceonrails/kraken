class Synchronize < ActiveRecord::Base

	class << self
		def import_from_cloud(data)
			company = data['company']
			outlet = data['outlet']
			users = data['users']
			profiles = data['profiles']
			payments = data['payments']
			orders = data['orders']
			order_items = data['order_items']
			discounts = data['discounts']
			products = data['products']
			choices = data['choices']
			product_choices = data['product_choices']
			product_discounts = data['product_discounts']
			product_categories = data['product_categories']
			product_sub_categories = data['product_sub_categories']
			attendances = data['attendances']
			tables = data['tables']

			company_obj = Company.find_or_initialize_by(id: company['id'])
			company_obj.update_attributes(company)

			outlet_obj = Outlet.find_or_initialize_by(id: outlet['id'])
			outlet_obj.update_attributes(outlet)

			users.each do |user|
				user_obj = User.find_or_initialize_by(id: user['id'])
				user['password'] = '1234567890'
				user_obj.update_attributes(user)
				user_obj.update_attributes(encrypted_password: user['encrypted_password'])
			end

			profiles.each do |profile|
				profile_obj = Profile.find_or_initialize_by(id: profile['id'])
				profile_obj.update_attributes(profile)
			end

			tables.each do |table|
				table_obj = Table.find_or_initialize_by(id: table['id'])
				table_obj.update_attributes(table)
			end

			choices.each do |choice|
				choice_obj = Choice.find_or_initialize_by(id: choice['id'])
				choice_obj.update_attributes(choice)
			end

			attendances.each do |attendance|
				attendance_obj = Attendance.find_or_initialize_by(id: attendance['id'])
				attendance_obj.update_attributes(attendance)
			end

			product_categories.each do |cat|
				cat_obj = ProductCategory.find_or_initialize_by(id: cat['id'])
				cat_obj.update_attributes(cat)
			end

			product_sub_categories.each do |cat|
				cat_obj = ProductSubCategory.find_or_initialize_by(id: cat['id'])
				cat_obj.update_attributes(cat)
			end

			products.each do |product|
				product_obj = Product.find_or_initialize_by(id: product['id'])
				product_obj.update_attributes(product)
			end

			discounts.each do |discount|
				discount_obj = Discount.find_or_initialize_by(id: discount['id'])
				discount_obj.update_attributes(discount)
			end

			product_discounts.each do |product_discount|
				product_discount_obj = ProductDiscount.find_or_initialize_by(id: product_discount['id'])
				product_discount_obj.update_attributes(product_discount)
			end

			product_choices.each do |product_choice|
				product_choice_obj = ProductChoice.find_or_initialize_by(id: product_choice['id'])
				product_choice_obj.update_attributes(product_choice)
			end

			payments.each do |payment|
				payment_obj = Payment.find_or_initialize_by(id: payment['id'])
				payment_obj.update_attributes(payment)
			end

			orders.each do |order|
				order_obj = Order.find_or_initialize_by(id: order['id'])
				order_obj.update_attributes(order)
			end

			order_items.each do |order_item|
				order_item_obj = OrderItem.find_or_initialize_by(id: order_item['id'])
				order_item_obj.update_attributes(order_item)
			end
			return true
		end

		def import_from_local(data)
			
		end

		def export_from_local(start_date, last_date)
			params = {}
			params[:company] = Company.first
			params[:outlet] = Outlet.first
			params[:users] = User.all
			params[:profiles] = Profile.all
			params[:product_categories] = ProductCategory.where(updated_at: start_date...last_date)
			params[:product_sub_categories] = ProductSubCategory.where(updated_at: start_date...last_date)
			params[:products] = Product.where(updated_at: start_date...last_date)
			params[:discounts] = Discount.where(updated_at: start_date...last_date)
			params[:choices] = Choice.where(updated_at: start_date...last_date)
			params[:tables] = Table.where(updated_at: start_date...last_date)
			params[:product_choices] = ProductChoice.where(updated_at: start_date...last_date)
			params[:payments] = Payment.where(updated_at: start_date...last_date)
			params[:orders] = Order.where(updated_at: start_date...last_date)
			params[:order_items] = OrderItem.where(updated_at: start_date...last_date)
			params[:product_discounts] = ProductDiscount.where(updated_at: start_date...last_date)
			params[:attendances] = Attendance.where(updated_at: start_date...last_date)

			return params
		end

		def export_from_cloud(outlet_id)
			params = {}
			outlet = Outlet.find(outlet_id)
			params[:users] = User.where(updated_at: start_date...end_date, outlet_id: outlet_id)
			params[:product_categories] = ProductCategory.where(updated_at: start_date...end_date, outlet_id: outlet_id)
			params[:product_sub_categories] = ProductSubCategory.where(updated_at: start_date...end_date, outlet_id: outlet_id)
			params[:products] = Product.where(updated_at: start_date...end_date, outlet_id: outlet_id)
			params[:discounts] = Discount.where(updated_at: start_date...end_date, outlet_id: outlet_id)

			return params
		end
	end
end
