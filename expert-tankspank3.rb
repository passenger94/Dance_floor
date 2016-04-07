# Tankspank
# kevin conner
# connerk@gmail.com
# version 3, 13 March 2008
# this code is free, do what you like with it!
#
# version 4, 13 March 2016



module Collisions
	def contains? x, y
		not (x < west or x > east or y < north or y > south)
#		(west..east) === x && (north..south) === y # 3 times slower ! (ips benchmark)
	end
	
	def intersects? other
		not (other.east < west or other.west > east or
			other.south < north or other.north > south)
#        contains?(other.east, other.north) || contains?(other.west, other.south)
	end
end

class Building
	include Collisions
	
	attr_reader :west, :east, :north, :south
	
	def initialize(arr, opp)
        @opp = opp
		@west, @east, @north, @south = arr
		@top, @bottom = 1.1 + rand(3) * 0.15, 1.0
		
		@color = (1..3).collect { 0.2 + 0.4 * rand } << 0.9
	end
	
	def draw
        @opp.brush(:rgb, @color[0,3] << 0.3, @color)
		@opp.draw_opp_box(@west, @east, @north, @south, @top, @bottom)
	end
    
end

module Guidance
	def guidance_system x, y, dest_x, dest_y, angle
		vx, vy = dest_x - x, dest_y - y
		if vx.abs < 0.1 and vy.abs <= 0.1
			yield 0, 0
		else
			length = Math.sqrt(vx * vx + vy * vy)
			vx /= length
			vy /= length
			ax, ay = Math.cos(angle), Math.sin(angle)
			cos_between = vx * ax + vy * ay
			sin_between = vx * -ay + vy * ax
			yield sin_between, cos_between
		end
	end
end

module Life
	attr_reader :health
	def dead?
		@health == 0
	end
	def hurt damage
		@health = [@health - damage, 0].max
	end
end

class Tank
	include Collisions
	include Guidance
	include Life
	# ^ sounds like insurance
	
	COLLIDE_SIZE = 15
	def west; @x - COLLIDE_SIZE; end
	def east; @x + COLLIDE_SIZE; end
	def north; @y - COLLIDE_SIZE; end
	def south; @y + COLLIDE_SIZE; end
	
	attr_reader :x, :y, :shells
	
	def initialize(opp)
        @opp = opp
        
		@x, @y = 0, -125
		@last_x, @last_y = @x, @y
		@tank_angle = 0.0
		@dest_x, @dest_y = 0, 0
		@acceleration = 0.0
		@speed = 0.0
		@moving = false
		
		@aim_angle = 0.0
		@target_x, @target_y = 0, 0
		@aimed = false
		
		@health = 100
        @shells = []
	end
	
	def set_destination
		@dest_x, @dest_y = @target_x, @target_y
		@moving = true
	end
	
    def add_shell shell
		@shells << shell
		@shells.shift if @shells.size > 10
	end
    
	def fire
		add_shell Shell.new(@x + 30 * Math.cos(@aim_angle),
			@y + 30 * Math.sin(@aim_angle), @aim_angle, @opp)
	end
	
	def update button, mouse_x, mouse_y
		@target_x, @target_y = mouse_x, mouse_y
		
		if @moving
			guidance_system @x, @y, @dest_x, @dest_y, @tank_angle do |direction, on_target|
				turn direction
				@acceleration = on_target * 0.25
			end
			
			distance = Math.sqrt((@dest_x - @x) ** 2 + (@dest_y - @y) ** 2)
			@moving = false if distance < 50
		else
			@acceleration = 0.0
		end
		
		guidance_system @x, @y, @target_x, @target_y, @aim_angle do |direction, on_target|
			aim direction
			@aimed = on_target > 0.98
		end
		
		integrity = @health / 100.0 # the more hurt you are, the slower you go
		@speed = [[@speed + @acceleration, 5.0 * integrity].min, -3.0 * integrity].max
		@speed *= 0.9 unless @moving
		
		@last_x, @last_y = @x, @y
		@x += @speed * Math.cos(@tank_angle)
		@y += @speed * Math.sin(@tank_angle)
	end
	
	def collide_and_stop
		@x, @y = @last_x, @last_y
		hurt @speed.abs * 3 + 5
		@speed = 0
		@moving = false
	end
	
	def turn direction
		@tank_angle += [[-0.03, direction].max, 0.03].min
	end
	
	def aim direction
		@aim_angle += [[-0.1, direction].max, 0.1].min
	end
	
	def draw
        @opp.brush(:blue, [0.4])
		@opp.draw_opp_rect @x - 20, @x + 20, @y - 15, @y + 15, 1.05, @tank_angle
		#opp.draw_opp_box @x - 20, @x + 20, @y - 20, @y + 20, 1.03, 1.0
		@opp.draw_opp_rect @x - 10, @x + 10, @y - 7, @y + 7, 1.05, @aim_angle
		x, unused1, y, unused2 = @opp.project(@x, 0, @y, 0, 1.05)
		@opp.line x, y, x + 25 * Math.cos(@aim_angle), y + 25 * Math.sin(@aim_angle)
		
        @opp.brush(:red, [@aimed ? 0.4 : 0.1])
		@opp.draw_opp_oval @target_x - 10, @target_x + 10, @target_y - 10, @target_y + 10, 1.00
		
		if @moving
            @opp.brush(:green, [0.2])
			@opp.draw_opp_oval @dest_x - 20, @dest_x + 20, @dest_y - 20, @dest_y + 20, 1.00
		end
	end
end

class Shell
    attr_reader :x, :y
	
	def initialize x, y, angle, opp
        @opp = opp
		@x, @y, @angle = x, y, angle
		@speed = 10.0
	end
	
	def update
		@x += @speed * Math.cos(@angle)
		@y += @speed * Math.sin(@angle)
	end
	
	def draw
        @opp.brush(:red, [0.1])
		@opp.draw_opp_box @x - 2, @x + 2, @y - 2, @y + 2, 1.05, 1.04
	end
end


class Opp < Shoes
    Camera_tightness = 0.1
    attr_reader :tank
    
    url "/", :index
    
    def index
        
        new_game
        playing = true
        
        keypress do |key|
            if playing
                if key == "1" or key == "z"
                    tank.set_destination
                elsif key == "2" or key == "x" or key == " "
                    tank.fire
                elsif key ==  "s"
                    playing = false
                end
            else
                if key == "n"
                    index
                    playing = true
                end
            end
        end
        
        # !!! self is NOT the "active"" canvas !!!
        self.parent.click do |button, x, y|
#            info "button, x, y : #{button}, #{x}, #{y}"
            if playing
                if button == 1
                    tank.set_destination
                else
                    tank.fire
                end
            end
        end
        
        animate(60) do |fr|
            read_input if playing
            update_scene
            
            playing = false if tank.dead?
            unless playing
                stack do
                    banner "Game Over", :stroke => white, :margin => 10
                    caption "learn to drive!", :stroke => white, :margin => 20
                end
            end
        end
    end
    
	def new_game
        
        @center_x, @center_y = app.width / 2, app.height / 2
		@boundary = [-1250, 1500, -1250, 1250]
		@offset_x, @offset_y = 0, 0
		@buildings = [
			[-1000, -750, -750, -250],
			[-500, 250, -750, -250],
			[500, 1000, -750, -500],
			[750, 1250, -250, 0],
			[750, 1250, 250, 750],
			[250, 500, 0, 750],
			[-250, 0, 0, 500],
			[-500, 0, 750, 1000],
			[-1000, -500, 0, 500],
			[400, 600, -350, -150]
		].collect { |p| Building.new(p, self) }
		
		@tank = Tank.new(self)
	end
    
	def read_input
		@input = mouse
	end
	
	def update_scene
		button, x, y = @input
		x += @offset_x - @center_x
		y += @offset_y - @center_y
		
		tank.update(button, x, y) unless tank.dead?
		@buildings.each do |b|
			tank.collide_and_stop if b.intersects? tank
		end
		
		tank.shells.each { |s| s.update }
		@buildings.each do |b|
			tank.shells.reject! do |s|
				b.contains?(s.x, s.y)
			end
		end
		#collide shells with tanks -- don't need this until there are enemy tanks
		#tank.shells.reject! do |s|
		#	tank.contains?(s.x, s.y)
		#end
        
		@offset_x += Camera_tightness * (tank.x - @offset_x)
        @offset_y += Camera_tightness * (tank.y - @offset_y)
        @center_x, @center_y = app.width / 2, app.height / 2
        
		clear do
			background black
			stroke red(0.9)
			nofill
			draw_opp_box *(@boundary + [1.1, 1.0, false])
			
			tank.draw
			tank.shells.each { |s| s.draw }
			@buildings.each { |b| b.draw }
		end
	end
    
    # color_method is either :rgb, either one of :blue, :green, :yellow, etc...
    # 3..4 arguments are r,g,b(,a), 1 argument is alpha, no args is opaque white, red, etc...
    def brush(color_method, fill_args=[], stroke_args=[])
        fill send(color_method, *fill_args)
        stroke send(color_method, *stroke_args)
    end
	
	def project(left, right, top, bottom, depth)
		[left, right].collect { |x| @center_x + depth * (x - @offset_x) } +
			[top, bottom].collect { |y| @center_y + depth * (y - @offset_y) }
	end
	
	# here "front" and "back" push the rect into and out of the window.
	# 1.0 means your x and y units are pixels on the surface.
	# greater than that brings the box closer.  less pushes it back.  0.0 => infinity.
	# the front will be filled but the rest is wireframe only.
	def draw_opp_box(left, right, top, bottom, front, back, occlude = true)
		near_left, near_right, near_top, near_bottom = project(left, right, top, bottom, front)
		far_left, far_right, far_top, far_bottom = project(left, right, top, bottom, back)
		
		# determine which sides of the box are visible
		if occlude
			draw_left = @center_x < near_left
			draw_right = near_right < @center_x
			draw_top = @center_y < near_top
			draw_bottom = near_bottom < @center_y
		else
			draw_left, draw_right, draw_top, draw_bottom = [true] * 4
		end
		
		# draw lines for the back edges
		line far_left, far_top, far_right, far_top if draw_top
		line far_left, far_bottom, far_right, far_bottom if draw_bottom
		line far_left, far_top, far_left, far_bottom if draw_left
		line far_right, far_top, far_right, far_bottom if draw_right
		
		# draw lines to connect the front and back
		line near_left, near_top, far_left, far_top if draw_left or draw_top
		line near_right, near_top, far_right, far_top if draw_right or draw_top
		line near_left, near_bottom, far_left, far_bottom if draw_left or draw_bottom
		line near_right, near_bottom, far_right, far_bottom if draw_right or draw_bottom
		
		# draw the front, filled
		rect near_left, near_top, near_right - near_left, near_bottom - near_top
	end
	
	def draw_opp_rect(left, right, top, bottom, depth, angle, with_x = false)
		pl, pr, pt, pb = project(left, right, top, bottom, depth)
		cos = Math.cos(angle)
		sin = Math.sin(angle)
		cx, cy = (pr + pl) / 2.0, (pb + pt) / 2.0
		points = [[pl, pt], [pr, pt], [pr, pb], [pl, pb]].collect do |x, y|
			[cx + (x - cx) * cos - (y - cy) * sin,
				cy + (x - cx) * sin + (y - cy) * cos]
		end
		
		line *(points[0] + points[1])
		line *(points[1] + points[2])
		line *(points[2] + points[3])
		line *(points[3] + points[0])
	end
	
	def draw_opp_oval(left, right, top, bottom, depth)
		pl, pr, pt, pb = project(left, right, top, bottom, depth)
		oval(pl, pt, pr - pl, pb - pt)
	end
	
#	def draw_opp_plane x1, y1, x2, y2, front, back, stroke_color
#		near_x1, near_x2, near_y1, near_y2 = project(x1, x2, y1, y2, front)
#		far_x1, far_x2, far_y1, far_y2 = project(x1, x2, y1, y2, back)
#		
#		stroke stroke_color
#		
#		line far_x1, far_y1, far_x2, far_y2
#		line far_x1, far_y1, near_x1, near_y1
#		line far_x2, far_y2, near_x2, near_y2
#		line near_x1, near_y1, near_x2, near_y2
#	end
    
end

Shoes.app :width => 700, :height => 500, title: "Tank spank"

