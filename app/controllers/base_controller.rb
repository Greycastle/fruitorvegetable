class BaseController < ApplicationController
  before_filter :setup

  def setup
    if cookies[:data].nil?
      data = { total: 0, correct: 0 }
    else
      data = JSON.parse(cookies[:data])
    end
    puts data.to_s
    @total = data['total'].to_i
    @total_correct = data['correct'].to_i
  end

  def reset
    cookies.delete(:data)
    redirect_to action: 'index'
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

  def about
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

    cookies[:data] = {
      :value => JSON.generate({
        'total' => @total,
        'correct' => @total_correct
      }),
      :expires => 30.minutes.from_now
    }
  end
end
