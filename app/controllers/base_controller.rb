class BaseController < ApplicationController
  def initialize
    @total = 0
    @total_correct = 0
  end

  def generate_plant
    contents = File.read('config/data/en.json')
    @plants = JSON.parse(contents)
    @plant = @plants.sample
    @url = url_for(controller: 'base',
            action: 'verify',
            plant: @plant['name'],
            only_path: true)
  end

  def index
    generate_plant
  end

  def verify
    generate_plant

    name = params[:plant].downcase
    @verify_plant = @plants.find { |plant| plant['name'].to_s.downcase == name }
    raise "what's a #{name}" if @verify_plant.nil?

    is = params[:is].downcase
    if is != 'fruit' && is != 'vegetable'
      raise "scuz me, wat is a '#{is}'"
    end

    @correct = is == @verify_plant['type'].downcase
    @total += 1
    @total_correct += 1 if @correct
  end
end
