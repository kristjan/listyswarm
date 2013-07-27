module GameHelper
  def cell_class(object)
    case object
    when 'x' then 'team-a'
    when 'X' then 'team-a block'
    when 'o' then 'team-b'
    when 'O' then 'team-b block'
    when 'b' then 'block'
    end
  end

  def cell_content(object)
    case object
    when 'b', 'X', 'O' then ''
    end
  end
end
