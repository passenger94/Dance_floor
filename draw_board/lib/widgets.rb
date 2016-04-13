# encoding: UTF-8

class ColorWidget < Shoes::Widget
    attr_reader :color
    
    def initialize(options={})
        @c_width = options[:c_width] || 40
        @c_height = options[:c_height] || 20
        @width = options[:width] || 120
        @height = options[:height] || 20
        self.width = @width; self.height = @height
        self.margin = options[:margins] || [0,5,0,5]
        
        @color = options[:color] || black
        @text = options[:text] || ""
        
        @slt = flow width: @c_width, height: @c_height do
            background @color, curve: 3, left: 1, top: 1, width: @c_width-2, height: @c_height-2
            border rgb(158,158,158), curve: 3, width: @c_width-1, height: @c_height-1
            border rgb(88,88,88,0.5), curve: 3, left: 1, top: 1, width: @c_width-1, height: @c_height-1
            
            click { 
                color = ask_color ""
                if color
                    @slt.contents[0].fill = color
                    @color = color
                end
            }    
        end
        
        para @text, margin: 0
        
    end
    
    def color=(color)
        @slt.contents[0].fill = color
        @slt.refresh_slot
        @color = color
    end
    
end

class DimWidget < Shoes::Widget
    attr_reader :size, :text
    
    def initialize(options={})
        @width = options[:width] || 120
        self.width = @width
        self.margin = options[:margins] || [0,5,0,7]
        
        @el_width = options[:el_width] || 40
        @max = (options[:max] || 50.0).to_f
        @text = options[:text] || ""
        @size = options[:size] || 1
        @min = options[:min] || 1
        
        slt = stack width: @width, margin: 0 do
            flow margin: 0 do
                @label = para @text, width: 80, margin: [0,6,5,0], align: "right"
                @size_el = edit_line @size.to_s, width: @el_width, margin: 0, right: 2
                @size_el.finish = proc { |el| @slide.fraction = el.text.to_i/@max }
            end
            @slide = slider fraction: @size/@max, width: @width, margin: [0,0,2,0] do |sld|
                val = (fr = (sld.fraction*@max).to_i) < @min ? @min : fr
                @size_el.text = val.to_s
                @size = val
            end
        end
    end
    
    def size=(val)
        @size = val
        @size_el.text = val.to_s
        @slide.fraction = @size/@max
    end
    
    def text=(val)
        @text = val
        @label.text = val
    end
end


class CheckText < Shoes::Widget
    def initialize(text, options={})
        self.width = options[:ct_width] || 120
        activ = options[:active] || false

        @c = check checked: activ
        @p = para text, margin_left: 5
    end
    
    def checked?
        @c.checked?
    end
end

