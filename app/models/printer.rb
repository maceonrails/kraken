class Printer < ActiveRecord::Base
  after_create :update_default

  private
    def update_default
      if self.default
        Printer.where.not(id: self.id).update_all(default: false)
      end
    end
end
