# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def import_items
  path = Rails.root.join('db', 'static', 'inventory', 'invTypes.csv')
  CSV.foreach(path, headers: true) do |row|
    row.each do |h, v|
      row[h] = nil if v == 'None'
    end
    Item.create(id: row['typeID'],
                groupID: row['groupID'],
                name: row['typeName'],
                volume: row['volume'],
                portionSize: row['portionSize'],
                basePrice: row['basePrice'],
                published: row['published'],
                marketGroupID: row['marketGroupID']
                )
    puts row['typeID']
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
  path = Rails.root.join('db', 'static', 'inventory', 'invMetaTypes.csv')
  CSV.foreach(path, headers: true) do |row|
    item = Item.find(row['typeID'])
    item.update(metaGroupID: row['metaGroupID'],
                parentTypeID: row['parentTypeID'])
    item.save
    puts item.name
  end
end

def add_meta_name_to_items
  path = Rails.root.join('db', 'static', 'inventory', 'invMetaGroups.csv')
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

def import_region_names
  path = Rails.root.join('db', 'static', 'map', 'mapRegions.csv')
  CSV.foreach(path, headers: true) do |row|
    Region.create(id: row['regionID'],
                  name: row['regionName']
                )
    puts row['regionName']
  end
end

def import_systems
  path = Rails.root.join('db', 'static', 'map', 'mapSolarSystems.csv')
  CSV.foreach(path, headers: true) do |row|
    System.create(id: row['solarSystemID'],
                  region_id: row['regionID'],
                  name: row['solarSystemName'],
                  security: row['security']
                )
    puts row['solarSystemName']
  end
end

def import_stations
  path = Rails.root.join('db', 'static', 'station', 'staStations.csv')
  CSV.foreach(path, headers: true) do |row|
    Station.create(id: row['stationID'],
                  system_id: row['solarSystemID'],
                  name: row['stationName']
                  )
    puts row['stationName']
  end
end

def add_group_and_category_to_items
  groups_path = Rails.root.join('db', 'static', 'inventory', 'invGroups.csv')
  categories_path = Rails.root.join('db', 'static', 'inventory', 'invCategories.csv')
  marketGroups_path = Rails.root.join('db', 'static', 'inventory', 'invMarketGroups.csv')
  marketGroups = Hash.new
  categories = Hash.new
  groupNames = Hash.new
  groupCategories = Hash.new

  CSV.foreach(groups_path, headers: true) do |row|
    groupNames[row['groupID'].to_i] = row['groupName']
    groupCategories[row['groupID'].to_i] = row['categoryID'].to_i
  end

  CSV.foreach(categories_path, headers: true) do |row|
    categories[row['categoryID'].to_i] = row['categoryName']
  end

  CSV.foreach(marketGroups_path, headers: true) do |row|
    marketGroups[row['marketGroupID'].to_i] = row['marketGroupName']
  end

  Item.all.each do |item|
    if item.groupID
      item.update(groupName: groupNames[item.groupID],
                  categoryID: groupCategories[item.groupID])
      item.save
    end
    if item.categoryID
      item.update(categoryName: categories[item.categoryID])
      item.save
    end
    if item.marketGroupID
      item.update(marketGroupName: marketGroups[item.marketGroupID])
    end
    puts "#{item.name}: #{item.groupName} - #{item.categoryName} - #{item.marketGroupName}"
  end
end

#import_items
#import_recipies
#import_blueprints
#add_time_to_blueprints
#add_production_limit_to_blueprints
#add_meta_id_to_items
#add_meta_name_to_items
#import_region_names
#import_systems
#import_stations
#add_group_and_category_to_items
