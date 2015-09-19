json.id          discount.id
json.name        discount.name
json.amount      discount.amount
json.product_id  discount.product_id
json.product     discount.product.name
json.created_at  discount.created_at
json.updated_at  discount.updated_at
json.start_date  discount.start_date.strftime("%d/%m/%Y") rescue ''
json.end_date    discount.end_date.strftime("%d/%m/%Y") rescue ''