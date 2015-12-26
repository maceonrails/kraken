class Synchronize < ActiveRecord::Base

	class << self
		def import_from_cloud(data)
			users = data[:users]
			payments = data[:payments]
			orders = data[:orders]
			order_items = data[:order_items]
			discounts = data[:discounts]
			products = data[:products]
			product_categories = data[:product_categories]
			product_sub_categories = data[:product_sub_categories]
			outlet = data[:outlet]

			outlet_obj = Outlet.find_or_create_by(id: outlet[:id])
			outlet_obj.update_attributes(outlet)

			users.each do |user|
				user_obj = User.find_or_create_by(id: user[:id])
				user_obj.update_attributes(user)
			end

			product_catagories.each do |cat|
				cat_obj = ProductCategory.find_or_create_by(id: cat[:id])
				cat_obj.update_attributes(cat)
			end

			product_sub_catagories.each do |cat|
				cat_obj = ProductSubCategory.find_or_create_by(id: cat[:id])
				cat_obj.update_attributes(cat)
			end

			products.each do |product|
				product_obj = Product.find_or_create_by(id: product[:id])
				product_obj.update_attributes(product)
			end

			discounts.each do |discount|
				discount_obj = Discount.find_or_create_by(id: discount[:id])
				discount_obj.update_attributes(discount)
			end

			payments.each do |payment|
				payment_obj = Payment.find_or_create_by(id: payment[:id])
				payment_obj.update_attributes(payment)
			end

			orders.each do |order|
				order_obj = Order.find_or_create_by(id: order[:id])
				order_obj.update_attributes(order)
			end

			order_items.each do |order_item|
				order_item_obj = OrderItem.find_or_create_by(id: order_item[:id])
				order_item_obj.update_attributes(order_item)
			end

		end

		def import_from_local(data)
			
		end

		def export_from_local(start_date, end_date)
			params = {}
			params[:outlet] = Outlet.first
			params[:users] = User.where(updated_at: start_date...end_date)
			params[:product_categories] = ProductCategory.where(updated_at: start_date...end_date)
			params[:product_sub_categories] = ProductSubCategory.where(updated_at: start_date...end_date)
			params[:products] = Product.where(updated_at: start_date...end_date)
			params[:discounts] = Discount.where(updated_at: start_date...end_date)
			params[:payments] = Payment.where(updated_at: start_date...end_date)
			params[:orders] = Order.where(updated_at: start_date...end_date)
			params[:order_items] = OrderItem.where(updated_at: start_date...end_date)

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
