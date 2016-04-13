# encoding: UTF-8

class Base
  attr_reader :myApp

  def initialize(app)
    @myApp = app
    @moving = false
  end
  
  def draw; end
  
end

