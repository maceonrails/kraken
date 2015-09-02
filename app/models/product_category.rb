# == Schema Information
#
# Table name: product_categories
#
#  id         :uuid             not null, primary key
#  company_id :uuid
#  name       :string
#  valid      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductCategory < ActiveRecord::Base
	has_many :product_sub_categories

  def self.sync(products)
    self.delete_all

    keys   = products.first.keys

    keys.delete('product_sub_categories')
    keys   = keys.join(',')
    values = []

    products.each do |product|
      val = product.values.map { |s| "'#{s}'" }
      val.pop
      val = val.join(',')
      values << "( #{val} )"
    end

    sql = "INSERT INTO product_categories (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql


    ProductSubCategory.delete_all

    products.each do |product|
      # product sub categories
      sub_keys   = product[:product_sub_categories].first.keys
      sub_keys.delete('is_valid')
      sub_keys   = sub_keys.join(',')
      sub_values = []

      product[:product_sub_categories].each do |sub|
        val = sub.values.map { |s| "'#{s}'" }
        val.delete_at(3)
        val = val.join(',')
        sub_values << "( #{val} )"
      end

      sql = "INSERT INTO product_sub_categories (#{sub_keys} ) VALUES #{sub_values.join(", ")}"
      self.connection.execute sql
    end
  end
end
