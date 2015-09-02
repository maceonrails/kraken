# == Schema Information
#
# Table name: products
#
#  id                  :uuid             not null, primary key
#  company_id          :uuid
#  product_category_id :uuid
#  name                :string
#  picture             :string
#  active              :boolean          default(TRUE)
#  default_price       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Product < ActiveRecord::Base
  default_scope { where(active: true) }
  include Total

  belongs_to :product_sub_category
  has_many :product_choices
  has_many :choices, through: :product_choices

  def self.sync(products)
    self.unscoped.delete_all

    keys   = products.first.keys.join(',')
    values = []

    products.each do |product|
        holder  = product[:picture].split('/uploads/')
        product[:picture] = "/uploads/#{holder.last}"

        #save picture
        filename = product[:picture].split('/').last
        path     = File.join(Rails.public_path, 'uploads', filename)

        unless File.directory?(File.join(Rails.public_path, 'uploads'))
          FileUtils.mkdir_p(File.join(Rails.public_path, 'uploads'))
        end
        require 'open-uri'
        open(path, 'wb') do |file|
          file << open(holder.join('/uploads/')).read
        end

        values << "( #{product.values.map { |s| "'#{s}'" }.join(', ')} )"
    end

    sql = "INSERT INTO products (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql
  end

  def self.create_from_seed()

  end
end
