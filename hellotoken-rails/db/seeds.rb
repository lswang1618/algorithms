# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#=======CATEGORIES================
categories = ["IT", "Entertainment", "Business & Finance", 
              "Weddings", "Travel", "Gaming", "Sports", 
              "Style & Beauty", "Family & Parenting", "Food & Drink", 
              "Government & Politics", "Home & Architecture", 
              "Health", "Environment", "Technology"]
categories.sort! # get some alphabetical going
Category.destroy_all # clear the list first
categories.each do |category|
  Category.create(name: category)
end
#=================================


#========DEMOGRAPHICS=============
#=================================

