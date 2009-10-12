#This specs mainly describe the behaviour this plugin adds, only the glue to make the state_pattern gem work with AR.
#To get a complete idea of what you can do, check the state_pattern gem specs.

require 'test_helper'

class On < StatePattern::State
  def press
    transition_to(Off)
    "#{stateable.button_name} is off"
  end
end

class Off < StatePattern::State
  def press
    transition_to(On)
    "#{stateable.button_name} is on"
  end
end

class Button < ActiveRecord::Base
  include ActiveRecordStatePattern
  set_initial_state Off
  valid_transitions [On, :press] => Off, [Off, :press] => On

  def button_name
    "The button"
  end
end

class Button2 < Button
  set_state_attribute :state2
  set_initial_state Off
end

Expectations do
  expect "off" do
    Button.create.state
  end

  expect "The button is on" do
    button = Button.create
    button.press
  end

  expect "on" do
    button = Button.create
    button.press
    button.state
  end

  expect "The button is off" do
    button = Button.create
    button.state = "on"
    button.press
  end

  expect "The button is off" do
    button = Button.create
    button.press
    button.press
  end

  expect "on" do
    Button.create(:state => "on").state
  end

  expect nil do
    Button2.create.state
  end

  expect "off" do
    Button2.create.state2
  end
end
