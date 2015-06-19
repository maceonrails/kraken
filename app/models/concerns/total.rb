module Total
	def total
		self.class.name.classify.constantize.all.count
	end
end