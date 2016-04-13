
module ShapesLife
    
    def delete 
        @current.remove
        @current = nil
    end

    def move(current_shape)
        @moving = !@moving
        
        anim = @myApp.animate(25) do |fr|
            b, l, t = @myApp.mouse
            current_shape.move l-@myApp.buttons_width, t-@myApp.canvas_top
            if not @moving
                anim.stop; anim.remove; anim = nil
            end
        end if @moving
    end
    
end

