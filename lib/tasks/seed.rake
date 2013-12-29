namespace :seed do
    
  #rake seed:db
  
  task :db => :environment do |t, args|
    puts "Seeding User"
    User.destroy_all
    u = User.new(email: "rp@pykih.com", password: "pykih123", name: "amdocs", username: "amdocs")
    u.skip_confirmation!
    u.save
    puts "Seeding GA Query"
    Data::Query.destroy_all
    Data::Query.create!(name: "Query 1", source: "GA", metrics: "ga:visitors,ga:newVisits,ga:visits,ga:bounces,ga:avgTimeOnSite,ga:pageviewsPerVisit,ga:pageviews,ga:avgTimeOnPage,ga:exits", dimensions: "ga:date,ga:country,ga:sourceMedium,ga:keyword,ga:deviceCategory,ga:pagePath,ga:landingPagePath", header_row:  "date,country,sourceMedium,keyword,deviceCategory,pagePath,LandingPagePath,visitors,newVisits,visits,bounces,avgTimeOnSite,pageviewsPerVisit,pageviews,avgTimeOnPage,exits,year,month,day,source,medium", description: "adnfldaknf adlfkn adlf nadfl adkfn")
    puts "Seeding Charts Reference Table"
    Viz::Chart.destroy_all
    #
    Viz::Chart.create(name: "Pie", genre: "1D", mapping: "[[\"Data\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"],[\"Color\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/1d/pie.png")
    Viz::Chart.create(name: "Donut", genre: "1D", mapping: "[[\"Data\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"],[\"Color\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/1d/donut.png")
    Viz::Chart.create(name: "Bubble", genre: "1D", mapping: "[[\"Data\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"],[\"Color\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/1d/bubble.png")
    #
    Viz::Chart.create(name: "Line", genre: "2D Charts", mapping: "[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Color\", \"string\"],[\"Tooltip\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/2d/line.png")
    Viz::Chart.create(name: "Column", genre: "2D Charts", mapping: "[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Color\", \"string\"],[\"Tooltip\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/2d/bar.png")
    Viz::Chart.create(name: "Area", genre: "2D Charts", mapping: "[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Color\", \"string\"],[\"Tooltip\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/2d/area.png")
    Viz::Chart.create(name: "Scatter", genre: "2D Charts", mapping: "[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Color\", \"string\"],[\"Tooltip\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/2d/scatter.png")
    Viz::Chart.create(name: "Circle Comparison", genre: "2D Charts", mapping: "[[\"X\", \"number\"],[\"Y\", \"number\"],[\"Size\", \"number\"],[\"Color\", \"string\"],[\"Tooltip\", \"string\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/2d/circle_comparison.png")
    #
    Viz::Chart.create(name: "Packed Circle", genre: "Weighted Tree", mapping: "[[\"Hierarchy\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"]]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/weighted_tree/packed_circle.png")
    Viz::Chart.create(name: "Tree Map", genre: "Weighted Tree", mapping: "[[\"Hierarchy\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"]]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/weighted_tree/tree_rect.png")
    Viz::Chart.create(name: "Sunburst", genre: "Weighted Tree", mapping: "[[\"Hierarchy\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"]]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/weighted_tree/sunburst.png")
    #
    Viz::Chart.create(name: "Circular Dendogram", genre: "Unweighted Tree", mapping: "[[\"Hierarchy\", \"string\"],\"Tooltip\", \"string\"]]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/unweighted_tree/circular_dendogram.png")
    Viz::Chart.create(name: "Dendogram", genre: "Unweighted Tree", mapping: "[[\"Hierarchy\", \"string\"],\"Tooltip\", \"string\"]]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/unweighted_tree/dendogram.png")
    #
    Viz::Chart.create(name: "Chord", genre: "Relationship Charts", mapping: "[[\"Dimensions\", \"string\"],[\"Link Value\", \"number\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/relations/chord.png")
    Viz::Chart.create(name: "Sankey", genre: "Relationship Charts", mapping: "[[\"Dimensions\", \"string\"],[\"Link Value\", \"number\"]]", img: "https://s3-ap-southeast-1.amazonaws.com/pykhub/chart_types/relations/sankey.png")
    #
    Viz::Chart.create(name: "India States", genre: "map", img: "")
    Viz::Chart.create(name: "India Districts", genre: "map", img: "")
    
  end
  
  #rake seed:update
  task :update => :environment do |t, args|
    Viz::Viz.destroy_all
    Viz::Chart.where(genre: "1D").update_all(mapping: "[[\"Dimension\", \"string\"],[\"Size\", \"number\"],[\"Tooltip\", \"string\"],[\"Color\", \"string\"]]")
    Viz::Chart.all.each do |viz|
      viz.update_attributes(description: viz.name + " " + viz.genre)
    end
  end
  
end