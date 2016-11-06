# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def import_items
  path = Rails.root.join('db', 'static', 'invTypes.csv')
  CSV.foreach(path, headers: true) do |row|
    if row['marketGroupID'] != 'None'
      Item.create(id: row['typeID'],
                  groupID: row['groupID'],
                  typeName: row['typeName'],
                  volume: row['volume'],
                  portionSize: row['portionSize'],
                  basePrice: row['basePrice'],
                  published: row['published'],
                  marketGroupID: row['marketGroupID']
                  )
      puts row['typeID']

    end
  end
end

def import_recipies
  path = Rails.root.join('db', 'static', 'invTypeMaterials.csv')
  CSV.foreach(path, headers: true) do |row|
    Ingredient.create(item_id: row['typeID'],
                   materialTypeID: row['materialTypeID'],
                   quantity: row['quantity']
    )
    puts row['typeID']
  end

end

def import_blueprints
  path = Rails.root.join('db', 'static', 'industryActivityProducts.csv')
  CSV.foreach(path, headers: true) do |row|
    if row['activityID'] == '1'
      Blueprint.create(id: row['typeID'],
                     item_id: row['productTypeID'],
                     quantity: row['quantity']
      )
    end
    puts row['typeID']
  end
end

def add_time_to_blueprints
  path = Rails.root.join('db', 'static', 'industryActivity.csv')
  CSV.foreach(path, headers: true) do |row|
    if row['activityID'] == '1'
      blueprint = Blueprint.find_by(id: row['typeID'])
      blueprint.update(time: row['time']) if blueprint
      blueprint.save if blueprint
    end
    puts row['typeID']
  end
end

def add_production_limit_to_blueprints
  path = Rails.root.join('db', 'static', 'industryBlueprints.csv')
  CSV.foreach(path, headers: true) do |row|
    blueprint = Blueprint.find_by(id: row['typeID'])
    blueprint.update(maxProductionLimit: row['maxProductionLimit']) if blueprint
    blueprint.save if blueprint
    puts row['typeID']
  end
end

def add_meta_id_to_items
  path = Rails.root.join('db', 'static', 'invMetaTypes.csv')
  CSV.foreach(path, headers: true) do |row|
    item = Item.find_by(id: row['typeID'])
    item.update(metaGroupID: row['metaGroupID']) if item
    item.save if item
    puts row['typeID']
  end
end

def add_meta_name_to_items
  path = Rails.root.join('db', 'static', 'invMetaGroups.csv')
  groups = {}
  CSV.foreach(path, headers: true) do |row|
    groups[row['metaGroupID'].to_i] = row['metaGroupName']
  end
  puts groups
  Item.all.each do |item|
    if item.metaGroupID
      puts groups[item.metaGroupID]
      item.update(metaGroupName: groups[item.metaGroupID])
      item.save
    end
    puts item.id
  end
end

#import_items
#import_recipies
#import_blueprints
#add_time_to_blueprints
#add_production_limit_to_blueprints
#add_meta_id_to_items
#add_meta_name_to_items
