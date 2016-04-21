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



module ToolsCommon
    
    def initialize(tool, options={})
        @width = options[:width] ||= 40
        @height = options[:height] ||= 40
        @margin = options[:margin] ||= [0,0,0,0]
        
        self.width = @width + margin[0] + margin[2]
        self.height = @height + margin[1] + margin[3]
        self.margin = @margin
        
        @active = false
        
        @slt = flow width: @width, height: @height do
            @bkg = background gray(200)
            brd = border orange, hidden: true
            
            hover { brd.show }
            leave { brd.hide }
            click { 
                app.send "#{tool}_mode=", !active?
                active? ? deactivate : activate
            }
        end
    end
    
#    def plug_events(tool)
#        
#        click { 
#            app.send tool, !active?
#            active? ? deactivate : activate
#        }
#    end
    
    def activate
        @bkg.fill = red(0.3)
        @slt.refresh_slot
        @active = true
    end
    
    def deactivate
        @bkg.fill = gray(200)
        @slt.refresh_slot
        @active = false
    end
    
    def active?
        @active
    end
end

class SelectTool < Shoes::Widget
    include ToolsCommon
    
    def initialize(options={})
        super("select", options)
        
        @slt.after(@bkg) {
            shape fill: gray(25, 0.5) do
                move_to 7,7
                line_to 12,22; line_to 12,14; line_to 29,31; line_to 31,29
                line_to 14,12; line_to 22,12; line_to 7,7
            end
        }
        
    end

end

class MoveTool < Shoes::Widget
    include ToolsCommon
    
    def initialize(options={})
        super("move", options)
        
        @slt.after(@bkg) {
            shape fill: gray(25, 0.5) do
                move_to 20,5
                line_to 25,10; line_to 22,10; line_to 22,18; line_to 30,18; line_to 30,15
                line_to 35,20; line_to 30,25; line_to 30,22; line_to 22,22; line_to 22,30
                line_to 25,30; line_to 20,35; line_to 15,30; line_to 18,30; line_to 18,22
                line_to 10,22; line_to 10,25; line_to 5,20; line_to 10,15; line_to 10,18
                line_to 18,18; line_to 18,10; line_to 15,10; line_to 20,5
            end
        }
    end
    
end




