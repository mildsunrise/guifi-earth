# guifi-earth

guifi-earth is a simple tool which is able to represent the nodes, links and
zone structure of the [guifi.net](http://guifi.net/en) network in the [Keyhole
Markup Language][kml], for viewing in [Google Earth](google-earth), [Google
Maps][google-maps] or any other KML-capable program. You can customize it
easily, see the [Tweaking](#tweaking) section.


## Usage

You need to have [Node.JS][node] installed. Then, clone the repo and do:

```bash
$ npm install
```

This will install any dependencies for you. It only needs to be done once.  
Then, you need to download the following input data:

  - CNML export of the "World" zone, at the "Zones and Nodes" level:
    http://guifi.net/guifi/cnml/3671/nodes
  
  - GML export of the "World" zone, of the links:
    http://guifi.net/guifi/gml/3671/links

Now to produce the KML:

```bash
$ ./compile.coffee nodes.cnml links.gml > guifi.kml
```

Replace `nodes.cnml` and `links.gml` with the files you downloaded before.
The output will be stored in `guifi.kml`. Just open it in Google Earth.


## Tweaking

Want to customize your KML a bit? No worries, it's simple and straightforward.

The `model.jade` is the template which is used to produce the KML. It is
intuitive to read and modify, but you may want to learn the basics of
[KML][kml] and [Jade][jade] to do bigger things.

Once you have modified the template, just call `compile.coffee` again. And if
you made a nice change, I encourage you to contribute it so everyone can have
it too. :)


## Implementation

This is very **uneffective** at processing data, because it doesn't do
incremental processing. First, it loads all the data (~12MB) in memory and
parses it using [xml2js][xml2js]. Then, it's passed through a [Jade][jade] view
that produces the XML (buffered) and, finally, writes that to stdout.

guifi-earth was designed to be very **simple**, and **easy to understand and
tweak** (thanks to the Jade syntax). It wasn't designed to be lightweight, fast
nor effective.



kml: https://developers.google.com/kml/documentation "KML documentation"
google-earth: http://earth.google.com "Google Earth"
google-maps:  http://maps.google.com "Google Maps"

node: http://nodejs.org "The Node.JS platform"
xml2js: https://github.com/Leonidas-from-XIV/node-xml2js "xml2js Node.JS module"
jade: http://jade-lang.com "The Jade templating engine"
