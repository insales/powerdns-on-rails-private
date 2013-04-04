require 'simpleidn'

class String
  def to_punicode
    SimpleIDN.to_ascii self
  end

  def from_punicode
    SimpleIDN.to_unicode self
  end
end