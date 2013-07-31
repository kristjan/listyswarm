require 'active_support/inflector'

require 'sprite'

class Sprite
  attr_accessor :row, :column

  def self.inherited(subclass)
    name = subclass.name.underscore
    define_method "#{name}?" do
      self.class.name.underscore == name
    end
  end

  def location
    [@row, @column] if @row && @column
  end

  def location=(coords)
    @row, @column = coords
  end

  def <=>(other)
    return 1 if other.nil?
    self.display_priority <=> other.display_priority
  end

  def display_priority
    0
  end

  def to_s
    "<##{self.class} @ #{[row,column]}>"
  end
end
