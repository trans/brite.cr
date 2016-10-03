require "yaml"

struct YAML::Any

  def rarify
    case object = @raw
    when Nil
      as_nil
    when Array
      as_a
    when Hash
      as_h
    when String
      as_s
    else
      s = as_s
      if s.includes?('.')
        s.to_f64
      else
        s.to_i64  # go big or go home
      end
    end
  end

  #def maprarify
  #  case obj = concrte
  #  when Array
  #    obj.map{ |x| x.rarify }
  #  when Hash
  #    h = {}
  #    obj.each{ |x, y| h[k.rarify] = v.rarify }
  #    h
  #  else
  #    obj 
  #  end
  #end

end

