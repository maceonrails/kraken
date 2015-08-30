class ProductImage < ActiveRecord::Base
	mount_uploader :file, PictureUploader
end
