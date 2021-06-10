ActiveSupport.on_load(:active_record) do

  # в 6.1 задепрекейтили, но эта штука используется из-за responders
  class ActiveModel::Errors
    def to_xml(options={})
      self.full_messages.to_xml(options.merge(root: :errors))
    end
  end
end
