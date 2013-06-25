# guifi-earth

guifi-earth is a simple tool which is able to represent the nodes, links and
zone structure of the [guifi.net](http://guifi.net/en) network in the [Keyhole
Markup Language][kml], for viewing in [Google Earth](google-earth), [Google
Maps][google-maps] or any other KML-capable program. You can customize it
easily, see the [Tweaking](#tweaking) section.

To try it, you can download a standard, pre-built KML file from the
[downloads page][downloads] and open it in Google Earth. You can also
use it offline (but the links to the official site won't work, of course).

//TODO: screenshots, prebuilt files
- add icons (both world and link icons)
- fix visibility check off only
- add use recommendations


## Setting up

You need to have [Node.JS][node] installed. Then, clone the repo and do:

```bash
$ npm install
```

This will install any dependencies for you.


## Usage

#### Parsing

> You can download `data.pak` from the [downloads page][downloads] and
> skip to [the next section](#converting). (there's no guarantee that
> the data will be up-to-date, however)

First, you need to download the following input data:

  - CNML export of the "World" zone, at the "Zones and Nodes" level:
    http://guifi.net/guifi/cnml/3671/nodes
  
  - GML export of the "World" zone, of the links:
    http://guifi.net/guifi/gml/3671/links

Now you can parse those two files into an efficient MSGPack archive:

```bash
# Replace `nodes.cnml` and `links.gml` with the files you downloaded
$ ./compile.coffee nodes.cnml links.gml > data.pak
```

Now you can remove the original XML files, they are no longer needed.

#### Converting

To produce the final KML, just do:

```bash
# Adjust `data.pak` if you have downloaded it somewhere else.
$ ./compile.coffee data.pak > guifi.kml
```

The output will be stored in `guifi.kml`. Just open it in Google Earth.

**Tip:** you may want to keep or distribute `data.pak` to experiment with
your own KMLs. Keep reading.


## Tweaking

Want to customize your KML a bit? No worries, it's simple and straightforward.

The `model.jade` is the template which is used to produce the KML. It is
intuitive to read and modify, but you may want to learn the basics of
[KML][kml] and [Jade][jade] to do bigger things.

Once you have modified the template, just call `compile.coffee` again. And if
you made a nice change, I encourage you to contribute it so everyone can have
it too. :)


## Implementation

The two-step process is done to keep the processing operation fast, so you
can hack on the template and see your changes quickly. It also makes it easier
for others to build their own KML; just give them the `data.pak` which is a lot
smaller than its respective XML files.



downloads: sdfdsfdas "Downloads of this project"

kml: https://developers.google.com/kml/documentation "KML documentation"
google-earth: http://earth.google.com "Google Earth"
google-maps:  http://maps.google.com "Google Maps"

node: http://nodejs.org "The Node.JS platform"
xml2js: https://github.com/Leonidas-from-XIV/node-xml2js "xml2js Node.JS module"
jade: http://jade-lang.com "The Jade templating engine"
