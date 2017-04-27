class Module

  def pretty_ancestors type = :print
    case type
    when :raw
      root_ancestors = ancestors

      recur = ->(mods, map, level) do
        return [[], map] if mods.empty?
        origin_map = map.dup
        init, *tail = mods

        if map[init]
          if map[init] < level
            return false, map
          else
            return recur.(tail, map, level + 1)
          end
        end
        prepended = init.ancestors.take_while{|x| x != init} & root_ancestors
        included = init.ancestors.drop_while{|x| x != init}.drop(1).select{|x| x.instance_of? Module} & root_ancestors

        (in_front, map) = recur.(prepended, map.merge(init => level), level + 1)
        (behind, map) = recur.(included, map, level + 1)

        return [false, map] unless in_front && behind

        (result, map) = recur.(tail, map, level + 1)
        if result
          [[[in_front, init, behind]].concat(result), map]
        else
          recur.(tail, origin_map, level)
        end
      end

      if self.instance_of? Module
        recur.([self], {}, 0)[0][0]
      elsif self.instance_of? Class
        ancestors.select{|x| x.instance_of? Class}.reverse.reduce([[], {}]) do |(arr, map), x|
          (result, map) = recur.([x], map, 0)
          arr << result[0]
          [arr, map.keys.map{|k| [k, Float::INFINITY]}.to_h]
        end[0].reverse
      end
    when :simplified
      traverse = ->((included, mod, prepended)) do
        if included.empty? && prepended.empty?
          mod
        else
          [included.map{|x| traverse.(x)}, mod, prepended.map{|x| traverse.(x)}]
        end
      end

      if self.instance_of? Module
        traverse.(pretty_ancestors(:raw))
      elsif self.instance_of? Class
        pretty_ancestors(:raw).map{|x| traverse.(x)}
      end
    when :print

      if self.instance_of? Module

      elsif self.instance_of? Class

      end
    end

  end
end

