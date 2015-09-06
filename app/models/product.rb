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
  has_one :discount

  accepts_nested_attributes_for :product_choices
  accepts_nested_attributes_for :choices

  def self.sync(products)
    self.unscoped.delete_all
    Choice.delete_all
    ProductChoice.delete_all

    keys   = products.first.keys

    keys.delete('choices')
    keys   = keys.join(',')
    values = []

    products.each do |product|
        holder  = product[:picture].split('/')

        #save picture
        filename = product[:picture].split('uploads').last
        path     = File.join(Rails.public_path, 'uploads', filename)
        folder   = path.split('/')
        folder.pop
        folder   = folder.join('/')

        unless File.directory?(folder)
          FileUtils.mkdir_p(folder)
        end
        require 'open-uri'
        path.gsub!('%2B', '')
        open(path, 'wb') do |file|
          file << open(product[:picture]).read
        end

        filename.gsub!('%2B', '')
        product[:picture] = '/uploads'+filename

        val = product.values.map { |s| "'#{s}'" }
        val.pop
        val = val.join(',')

        values << "( #{val} )"

        # create choices
        product['choices'].each do |choice|
          Choice.find_or_create_by(id: choice['id'], name: choice['name'])
          ProductChoice.find_or_create_by(product_id: product['id'], choice_id: choice['id'])
        end unless product['choices'].nil?
    end

    sql = "INSERT INTO products (#{keys} ) VALUES #{values.join(", ")}"
    self.connection.execute sql
  end

  def self.create_from_seed()

  end
end
