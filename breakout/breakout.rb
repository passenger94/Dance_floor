
# a little breakout game 
# Based on breakout_red from https://github.com/lljk/shoes-stuff

# use the mouse or left and right keys to move the paddle
# space bar or left click to launch ball
# space bar while ball is moving to pause game


class BreakoutBall < Shoes::Widget
    attr_reader :area
    attr_accessor :x, :y, :x_vec, :y_vec
    
    def initialize(stroke_color=lime, fill_color=silver)
        oval 0, 0, 10, stroke: stroke_color, fill: fill_color
    end
    
    def set_coords(x, y)
        @x = x; @y = y
        @area = [@x..(@x + 10), @y..(@y+10)]
        move(@x, @y)
    end
    
    def set_vectors(x, y)
        @x_vec = x
        @y_vec = y
    end
    
    def intersect?(range1, range2)
        range2.each { |n| return true if range1.include?(n) }
        false
    end
    
    def hit?(object)
        case object
        when BreakoutPaddle
            bing = intersect?(object.area[0], @area[0])
            if bing
                p_center = object.x + (object.width / 2)
                b_center = @x + 5
                @x_vec = ((b_center - p_center) / 3).round
                @y_vec *= -1
            end
            bing
        when BreakoutBrick
            boom = object.area[1].include?(@y) && intersect?(object.area[0], @area[0])
            @y_vec *= -1 if boom
            boom
        end
    end
    
    def slowdown
        @x_vec = (@x_vec * 0.5).round unless @x_vec.abs < 3
        @y_vec = (@y_vec * 0.5).round unless @y_vec.abs < 3
    end
end


class BreakoutBrick < Shoes::Widget
    VALUES = {
        10 => {stroke: rgb(47,79,79), fill: rgb(128,128,128)},
        25 => {stroke: rgb(75,0,130), fill: rgb(128,0,128)},
        50 => {stroke: rgb(47,79,79), fill: rgb(184,134,11)}
    }
    attr_reader :area
    attr_accessor :x, :y, :value, :special
    
    def initialize(value, special=false)
        @special = special
        @value = value
        
        strokewidth 2
        rect(0, 0, 40, 20, 3, VALUES[value])
    end
    
    def set_coords(x, y)
        @x = x; @y = y
        @area = [@x..(@x + 40), @y..(@y+20)]
        move(@x, @y)
        self
    end
    
end


class BreakoutPaddle < Shoes::Widget
    attr_reader :width, :area
    attr_accessor :x, :y
    
    def initialize(w=40)
        @width = w
        @shp = rect 0, 0, @width, 10, 3, stroke: lime, fill: green
    end
    
    def width=(w)
        @width = w
        @shp.width = w
    end
    
    def expand
        @x -= 10 unless @width == 60
        @shp.width = @width = 60
    end
    
    def set_coords(x, y)
        @x = x; @y = y
        @area = [@x..(@x + @width), @y..(@y+10)]
        move(@x, @y)
    end
    
end


class BreakoutBonusStar < Shoes::Widget
    TYPES = {
        "expand-paddle" => {stroke: rgb(205,215,0), fill: rgb(0,255,0)}, 
        "slow-down" => {stroke: rgb(220,20,60), fill: rgb(255,255,0)}, 
        "multi-ball" => {stroke: rgb(255,140,0), fill: rgb(255,0,0)}
    }
    attr_accessor :x, :y, :type
    
    def initialize
        @type = TYPES.keys[rand(3)]
        @bonus_star = star(0, 0, 5, 10, 5, TYPES[@type])
        @bonus_star.hide
    end
    
    def set_coords(x, y)
        @x = x; @y = y
        move(@x, @y)
        @bonus_star.show
    end
    
end



require 'shoes/videoffi'

Shoes.app height: 580, resizable: false do
    BG_COLORS = [midnightblue, blueviolet, darkblue, darkgoldenrod,
                darkslateblue, darkslategray, olive, indigo, maroon, orangered]
    Salutations = ["Hey There", "Woah", "Nice One", "Well Done", "Awesome"]
    Names = ["Dude", "Buddy", "Pal", "Friend", "Amigo"]
    Actions = ["Rocked", "Destroyed", "Annihilated", "Kicked Butt On", "Creamed"]
    BRICK_VALUES = [10, 10, 10, 25, 25, 50]
    SOUNDS = [
            "bd2.wav",
            "hit01.wav",
            "Hardbd.wav",
            "acid_wash_conflict.wav",
            "lost_ball.wav"
    ]
    
    stack do
        flow height: 30 do
            @status_bkgd = background(black)
            border(white)
            @status_bar = para "Lives, Level, Score", stroke: white, align: "center", top: 2
        end
        
        @main = flow height: 550
        
        @sound = audio '', autoplay: false, volume: 85, vlc_options: ["--play-and-pause"]
        
        start { SOUNDS.each { |snd| @sound.play_list_add(snd) } }
    end
    
    def init_game
        @lives = 3
        @score = 0
        @level = 1
        @bricks = []
        @wall_rows = 5
        @anims ||= []
        @bonus_anim_over = true
        
        @main.clear { set_background }
    end
    
    def set_background
        color = BG_COLORS[rand(BG_COLORS.length)]
        
        @status_bkgd.fill = black..color
        update_status_bar
        
        background color..black
    end
    
    def update_status_bar
        @status_bar.text = "Lives: #{@lives}     Level: #{@level}     Score: #{@score}"
    end
    
    def start_up
        @ball = nil
        @falling_stars = []
        
        @main.append do
            @ball = breakout_ball
            @paddle = breakout_paddle
        end
        @ball.set_coords(320, 459)
        @ball.set_vectors(1, -5)
        @paddle.set_coords(300, 470)
        
        @balls = [@ball]
    end
    
    def new_wall(height)
        @bricks.clear
        y = 50
        
        # to make the wall, first we make a random symmetrical array of  1's and 0's,
        # and randomly assign a value to each brick
        # then we draw a brick with a certain value wherever there's a 1 in our array
        height.times do
            half_row = []
            (rand(6) + 2).times { half_row << [rand(2), BRICK_VALUES[rand(6)]] }
            
            x = 300 - (42 * half_row.size)
            (half_row + half_row.reverse).each do |entry|
                @main.append do
                    @bricks << breakout_brick(entry[1]).set_coords(x, y)
                end if entry[0] == 1
                x += 42
            end
            y += 22
        end
        
        @low_y = @bricks[-1].area[1].end + 20
        
        # and now we make 3 of those bricks 'special'
        3.times { @bricks[rand(@bricks.length)].special = true }
    end
    
    
    def possible_hit?(ball)
        ball.y > 450 || ball.y < @low_y || ball.x > 580 || ball.x < 20
    end
    
    def check_hits(ball)
        return unless possible_hit?(ball)
        
        ball.x_vec = ball.x_vec.abs if ball.x < 1
        ball.x_vec = ball.x_vec.abs * -1 if ball.x > 589
        ball.y_vec = ball.y_vec.abs if ball.y < 11
        
        if ball.y > 465     # paddle's y coordinate - half ball : 5
            @sound.play_at ball.hit?(@paddle) ? 1 : 4
        else
            @bricks.each do |brick|
                if ball.hit? brick
                    @sound.play_at 0
                    @score += brick.value
                    special_brick(brick) if brick.special
                    brick.remove
                    @bricks.delete(brick)
                    @low_y = @bricks[-1].area[1].end + 20 unless @bricks.empty?
                    update_status_bar
                    
                    new_level if @bricks.empty?
                    
                    break
                end
            end
        end
    end
    
    def move_ball
        @sound.play_at 2
        @moving = true
        get_faster = 0
        
        if @anim
            @anim.start
        else
            @anim = animate(32) do |fr|
                @balls.each do |ball|
                    check_hits(ball)
                    
                    get_faster += 1 if fr % 16 == 0
                    if get_faster == 80
                        ball.x_vec += ball.x_vec < 0 ? -1 : 1
                        ball.y_vec += ball.y_vec < 0 ? -1 : 1 if (-28..28).include? ball.y_vec
                        get_faster = 0
                    end
                    
                    ball.set_coords(ball.x + ball.x_vec, ball.y + ball.y_vec)
                    
                    if ball.y > 480
                        ball.remove
                        @balls.delete(ball)
                        ball = nil
                        if @balls.empty?
                            @moving = false
                            @lives -= 1
                            update_status_bar
                            
                            @lives == 0 ? game_over : new_ball
                        end
                    end
                end
            end
            @anims << @anim
        end
    end
    
    def new_ball
        @anims.each &:stop
        @paddle.remove
        @falling_stars.each { |bonus_star| bonus_star.remove; bonus_star = nil }
        @falling_stars.clear
        
        start_up
    end
    
    def new_level
        @anims.each &:stop
        @moving = false
        @balls.clear
            
        @main.clear do
            background black
            title "#{Salutations[rand(5)]} #{Names[rand(5)]}, You #{Actions[rand(5)]} Level #{@level}!\n",
                  "On To Level #{@level + 1}...", align: "center", top: 70, stroke: white 
        end
        
        timer(3) do
            @wall_rows += 1 unless @wall_rows == 10
            @level += 1
            @main.clear { set_background }
            start_up
            new_wall(@wall_rows)
        end
    end
    
    def game_over
        @anims.each &:stop
        @game_over = true
        
        @main.append {
            banner "GAME OVER\n", span("press space to restart", size: 12), 
                    align: "center", stroke: lime, displace_top: -300
        }
    end
    
    def special_brick(brick)
        x = brick.x + 20; y = brick.y
        
        @main.append {
            bonus_star = breakout_bonus_star
            @falling_stars << bonus_star
            bonus_star.x = x; bonus_star.y = y
        }
        
        unless @bonus_anim
            @bonus_anim = animate(16) do 
                unless @moving
                    @bonus_anim.stop
                    @bonus_anim_over = true
                    @falling_stars.each { |bonus_star| bonus_star.remove; bonus_star = nil }
                    @falling_stars.clear
                else
                    @falling_stars.each do |bonus_star|
                        bonus_star.y += 2
                        bonus_star.set_coords(bonus_star.x, bonus_star.y)
                        
                        catched = (466...481).include?(bonus_star.y) && @paddle.area[0].include?(bonus_star.x)
                        if catched || bonus_star.y > 499
                            bonus_star.remove
                            @falling_stars.delete(bonus_star)
                            award_bonus(bonus_star) if catched
                            if @falling_stars.empty?
                                @bonus_anim.stop 
                                @bonus_anim_over = true
                            end
                        end
                    end
                end
            end 
            @anims << @bonus_anim
        else
            @bonus_anim.start
        end
        @bonus_anim_over = false
    end
    
    def award_bonus(bonus_star)
        @sound.play_at 3
        @score += 100
        update_status_bar

        case  bonus_star.type
            when "expand-paddle"
                @paddle.expand
            when "slow-down"
                @balls.each &:slowdown
            when "multi-ball"
                @main.append {
                    @balls << breakout_ball << breakout_ball
                    i = 1
                    [@balls[-2], @balls[-1]].each do |b|
                        b.set_coords(@balls[0].x - 5*i, @balls[0].y)
                        b.set_vectors(@balls[0].x_vec.abs * -1*i, @balls[0].y_vec.abs * -1)
                        i *= -1
                    end
                }
        end
    end
    
    
    keypress do |key|
        case key
            when :left; @paddle.x -= 5  
            when :right; @paddle.x += 5
            when " "
                if @game_over
                    init_game
                    start_up
                    new_wall(@wall_rows)
                    @game_over = false
                else
                    if @moving
                        @anim.toggle
                        @bonus_anim.toggle unless @bonus_anim_over
                    else
                        move_ball
                        @moving = true
                    end
                end
        end
        
        @paddle.set_coords(@paddle.x, 470)
        unless @moving
            @ball.x = @paddle.x + (@paddle.width / 2) + 2
            @ball.set_coords(@ball.x, 459)
        end
    end
    
    motion do |left, top|
        x = left - (@paddle.width / 2)
        @paddle.set_coords(x, 470)
        unless @moving
            @ball.x = left + 2
            @ball.set_coords(@ball.x, 459)
        end
    end
    
    click { |b| move_ball unless @moving }
        
    
    init_game
    start_up
    new_wall(@wall_rows)
    
end


