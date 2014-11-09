#!/usr/bin/env node_modules/.bin/coffee

Q = require "q"
fs = require "fs"
path = require "path"
jade = require "jade"
msgpack = require "msgpack"
parseXml = Q.denodeify (require "xml2js").parseString
argv = process.argv

readFile = Q.denodeify fs.readFile
writeFile = Q.denodeify fs.writeFile

compileView = (file) ->
  Q.fcall ->
    file = path.join __dirname, file
    readFile file, "utf8"
  .then (view) ->
    jade.compile view,
      filename: file
      #debug: DEBUG
      compileDebug: DEBUG
      pretty: PRETTY



# Some variables

VIEW = "model/main.jade"
DEBUG =  on
PRETTY = off



# The actual work

parseData = (nodes, links) ->
  Q.fcall ->
    console.error "Reading files..."
    [readFile(nodes, 'utf8'),
     readFile(links, 'utf8')]
  .spread (nodes, links) ->
    console.error "Parsing XML..."
    Q.all [parseXml(nodes), parseXml(links)]
  .then (data) ->
    console.error "Packing..."
    msgpack.pack data
  .then (data) ->
    console.error "Done packing."
    process.stdout.write data
  .done()

useData = (data) ->
  Q.fcall ->
    console.error "Reading data..."
    readFile data
  .then (data) ->
    console.error "Loading data..."
    msgpack.unpack data
  .then (data) ->
    buildKml data
  .then (kml) ->
    console.error "Conversion done."
    process.stdout.write kml
  .done()

buildKml = (data) ->
  [nodes, links] = data
  
  # validate input
  console.error "Preprocessing data..."
  if nodes.cnml.class[0].$.network_description not in ["nodes", "detail"]
    throw new Error "The CNML should be at «node» or «detail» level."
  if nodes.cnml.network[0].zone.length != 1
    throw new Error "There should be exactly ONE zone."
  if nodes.cnml.network[0].node?
    throw new Error "Everything should be inside the dumped zone."
  
  # determine root hashes
  cnml = nodes.cnml
  network = cnml.network[0]
  dumpedZone = network.zone[0]
  
  # index every node
  nodesHash = {}
  indexZone = (zone) ->
    if zone.zone?
      for czone in zone.zone
        indexZone czone
    if zone.node?
      for cnode in zone.node
        nodesHash[cnode.$.id] = cnode
        cnode.links = []
  indexZone dumpedZone
  
  # index every link twice
  pushLink = (link, from, to) ->
    from.links.push
      type: link.LINK_TYPE[0]
      status: link.STATUS[0]
      node: to
      distance: link.KMS[0]
  for link in links["ogr:FeatureCollection"]["gml:featureMember"]
    link = link.dlinks[0]
    n1 = nodesHash[link.NODE1_ID[0]]
    n2 = nodesHash[link.NODE2_ID[0]]
    if n1 and n2
      pushLink link, n1, n2
      pushLink link, n2, n1

  # compile the view
  console.error "Preparing conversion..."
  compileView(VIEW)

  .then (view) ->
    # produce output
    console.error "Converting..."
    view cnml: cnml
       , net: network, dumpedZone: dumpedZone
       , api: earthApi


# Parse arguments

printUsage = ->
  cmd = path.basename module.filename
  console.error """
Usage:

  to parse input data:
  ./#{cmd} nodes.cnml links.cnml > data.pak
  
  then, to produce the KML:
  ./#{cmd} data.pak > guifi.kml

  """
  process.exit 1

switch argv.length
  when 4 then parseData argv[2], argv[3]
  when 3 then   useData argv[2]
  else printUsage()


# The API which is made available to the template

earthApi =
  # convert 'regular' color to Google Earth
  col: (col, a) ->
    if col[0] is '#'
       col = col.substr 1
    unless a? then a=1
    a = (a*255).toString 16
    if a.length is 1
      a = '0'+a
    r = col.substr 0,2
    g = col.substr 2,2
    b = col.substr 4,2
    a+b+g+r

