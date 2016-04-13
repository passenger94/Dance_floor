# encoding: UTF-8

$: << File.expand_path("lib", File.dirname(__FILE__))

require 'base'
require 'polyline'
require 'segment'
require 'curve'
require 'polygon'
require 'ellipse'
require 'rectangle'
require 'star'
require 'arrow'
require 'widgets'


Shoes.app title: 'Drawing Shapes', width: 910 do
    
    @polyline = Polyline.new(self)
    @segment = Segment.new(self)
    @curve = Curve.new(self)
    @polygon = Polygon.new(self)
    @ellipse = Ellipse.new(self)
    @rectangle = Rectangle.new(self)
    @star = Star.new(self)
    @arrow = Arrow.new(self)
    
    BUTTONS_WIDTH = 120
    CANVAS_TOP = 20
    
    
    background gray
    
    stack width: BUTTONS_WIDTH, margin: [5, CANVAS_TOP+5, 0, 0] do
        [ @polyline, @segment, @curve, @polygon, @ellipse, @rectangle, @star, @arrow
        ].each do |shp|
            button(shp.class.to_s, width: 100) { set_shape_params shp }
        end
        
        button("Clear", margin_top: 50) { @drawings.clear { background white } }
        button("Quit", margin_top: 50) { exit }
        
    end
    
    @drawings = flow(width: 640, height: 480, margin_top: CANVAS_TOP) { background white }
    
    @drawings.click do |button, left, top|
        @drawings.append {@current_shape.draw(button, left-BUTTONS_WIDTH, top-CANVAS_TOP) } if @current_shape
    end
    
    stack width: 120, margin: [10, CANVAS_TOP, 0, 0] do
        @keep_brush = check_text "keep brush"
        @stroke_dim = dim_widget text: "strokewidth", width: 130, el_width: 35
        @stroke_w = color_widget text: " stroke"
        @fill_w = color_widget text: " fill"
        @shape_dim_w = dim_widget text: "width", width: 130, el_width: 50, max: 1000.0
        @shape_dim_h = dim_widget text: "height", width: 130, max: 800.0
        @shape_dim_spikes = dim_widget text: "spikes", width: 130, max: 50.0
    end
    
    
    def buttons_width; BUTTONS_WIDTH end
    def canvas_top; CANVAS_TOP end
    
    def current_shape; @current_shape end
    def drawings; @drawings end
    
    def stroke_color; @stroke_w.color end
    def stroke_color=(val); @stroke_w.color = val end
    def fill_color; @fill_w.color end
    def fill_color=(val); @fill_w.color = val end
    def stroke_width; @stroke_dim.size end
    def stroke_width=(val); @stroke_dim.size = val end
    def shape_width; @shape_dim_w.size end
    def shape_width=(val); @shape_dim_w.size = val end
    def shape_height; @shape_dim_h.size end
    def shape_height=(val); @shape_dim_h.size = val end
    def shape_count; @shape_dim_spikes.size end
    def shape_count=(val); @shape_dim_spikes.size = val end
    
    def set_shape_params(current)
        @current_shape = current
        
        unless @keep_brush.checked?
            @stroke_w.color = black
            @stroke_dim.size = 1
            @fill_w.color = black
        end
        
        params = case current_shape
            when Ellipse, Rectangle
                [ @fill_w, @shape_dim_w, @shape_dim_h ].each &:show
                @shape_dim_spikes.hide
                {"width" => 100, "height" => 45}
            when Star
                [@fill_w, @shape_dim_w, @shape_dim_h, @shape_dim_spikes
                ].each &:show
                {"count" => 5, "outer" => 60, "inner" => 35}
            when Arrow
                [ @fill_w, @shape_dim_w].each &:show
                [@shape_dim_h, @shape_dim_spikes].each &:hide
                {"width" => 60}
            when Polyline, Segment, Curve
                [@fill_w, @shape_dim_w, @shape_dim_h, @shape_dim_spikes
                ].each &:hide
                {"blank" => nil}
            when Polygon
                [@shape_dim_w, @shape_dim_h, @shape_dim_spikes
                ].each &:hide
                @fill_w.show
                {"blank" => nil}
            else
                Shoes.show_log
                raise "Unknown Shape : #{current_shape.inspect}"
            end
        
        params.each do |param, value|
            case param
            when "outer"
                @shape_dim_w.size = value
                @shape_dim_w.text = "outer"
            when "inner"
                @shape_dim_h.size = value
                @shape_dim_h.text = "inner"
            when "blank"
                check_labels
            else
                send "shape_#{param}=", value
                check_labels
            end
        end
        
    end
    
    def check_labels
        @shape_dim_w.text = "width" if @shape_dim_w.text == "outer"
        @shape_dim_h.text = "height" if @shape_dim_h.text == "inner"
    end
end



