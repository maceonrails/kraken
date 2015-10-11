json.id          discount.id
json.name        discount.name
json.amount      discount.amount
json.product_id  discount.product_id
json.products    discount.products.map{|p| p.id} rescue []
json.percentage  discount.percentage
json.created_at  discount.created_at
json.updated_at  discount.updated_at
json.start_date  discount.start_date.strftime("%d/%m/%Y") rescue ''
json.end_date    discount.end_date.strftime("%d/%m/%Y") rescue ''
json.end_time    discount.end_time.strftime("%H:%M") rescue ''
json.start_time  discount.start_time.strftime("%H:%M") rescue ''
json.days        discount.days