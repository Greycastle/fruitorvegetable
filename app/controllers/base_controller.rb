class BaseController < ApplicationController
  before_filter :setup

  def setup
    if cookies[:data].nil?
      data = { 'correct' => 0, 'answered' => [], 'total' => 0 }
    else
      # ensure original data is correct
      # this might be wrong in case we change something and someone
      # has a cookie stored already
      data = JSON.parse(cookies[:data])
      data['answered'] = data['answered'] ||= []
      data['total'] = data['total'] ||= 0
      data['correct'] = data['correct'] ||= 0
    end
    @answered = data['answered'].map(&:to_i)
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
    @answered = [] if @answered.length == @plants.length
    @plant = @plants.sample
    while (already_answered(@plant))
      puts "#{@plant['name']} already sample, trying again."
      @plant = @plants.sample
    end

    @url = url_for(controller: 'base',
            action: 'verify',
            plant: @plant['name'],
            only_path: true)
  end

  def already_answered(plant)
    puts "already answered: #{@answered}"
    @answered.include? @plant.find_index(plant)
  end

  private :already_answered

  def index
    generate_plant
  end

  def about
  end

  def verify
    generate_plant

    name = params[:plant].downcase
    index = @plants.find_index { |plant| plant['name'].to_s.downcase == name }
    @verify_plant = @plants[index]
    raise "what's a #{name}" if @verify_plant.nil?

    is = params[:is].downcase
    if is != 'fruit' && is != 'vegetable'
      raise "scuz me, wat is a '#{is}'"
    end

    @correct = is == @verify_plant['type'].downcase
    @total += 1
    @answered.push(index)
    @total_correct += 1 if @correct

    cookies[:data] = {
      :value => JSON.generate({
        'answered' => @answered,
        'total' => @total,
        'correct' => @total_correct
      }),
      :expires => 30.minutes.from_now
    }
  end
end
