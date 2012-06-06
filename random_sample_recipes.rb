#!/usr/bin/env ruby

# ----------------------------------
# A script to randomly download recipes from online.
# To run, you will need a user account, and you must
# have foldit when executing the script.
# ----------------------------------

require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'

SITE_USER = ARGV[0]
SITE_PASS = ARGV[1]

FIRST_RECIPE_NODE  = 1749
NEWEST_RECIPE_NODE = 42140

include Capybara::DSL

Capybara.default_driver    = :selenium
Capybara.run_server        = false
Capybara.app_host          = "http://fold.it/portal"
Capybara.default_wait_time = 10

def login_as_user(user,pass)
  visit '/user/login'
  fill_in 'edit-name', :with => user
  fill_in 'edit-pass', :with => pass
  page.find('input[title="Log in"]').click
end

def get_recipe(node)
  visit "/recipe/#{node}"
  if page.has_content?('could not be found')
    puts "+++ Didn't find a recipe at node #{node}"
    return
  end
  within('.macro-right .panel .center') do
    begin
      page.find(:xpath, ".//div[contains(text(), 'Add to Cookbook')]").click
      alert = page.driver.browser.switch_to.alert
      alert.accept
    rescue Exception => e
      puts "Exception: #{e.inspect}"
    ensure
      page.driver.browser.switch_to.default_content
    end
  end
end

def random_array(length, start, finish)
  container = []
  (1..length).each do |i|
    container << rand(start..finish)
  end
  container.uniq
end

# +++>>> do it
login_as_user(SITE_USER, SITE_PASS)
random_array(100, FIRST_RECIPE_NODE, NEWEST_RECIPE_NODE).each do |rando|
  begin
    get_recipe(rando)
  rescue Exception => e
    puts "Got an exception: #{e.inspect}\n+++>>> Resetting, then proceeding..."
    Capybara.reset!
    login_as_user(SITE_USER, SITE_PASS)
    next
  end
end
exit(0)
