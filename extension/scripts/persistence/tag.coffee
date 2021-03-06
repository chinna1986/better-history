class BH.Persistence.Tag
  constructor: (options) ->
    throw "Localstore is not set" unless options.localStore?
    @localStore = options.localStore

  setSitesHash: (sitesHash) ->
    @localStore.set sitesHash: sitesHash, () ->

  getSitesHash: (callback) ->
    @localStore.get 'sitesHash', (data) ->
      callback(data)

  getCompletedMigrations: (callback) ->
    @localStore.get 'completedMigrations', (data) ->
      callback(data.completedMigrations || [])

  markMigrationAsComplete: (name, callback) ->
    @localStore.get 'completedMigrations', (data) =>
      data.completedMigrations ||= []
      data.completedMigrations.push name
      @localStore.set data, ->
        callback()

  cached: (callback) ->
    @localStore.get null, (data) ->
      callback
        siteTags: (url) ->
          matches = []
          for tag in data.tags
            result = _.where data[tag], {url: url}
            matches.push tag if result.length > 0
          matches
        sitesTags: (urls) ->
          siteTags = []
          for url in urls
            matches = []
            for tag in data.tags
              result = _.where data[tag], {url: url}
              matches.push tag if result.length > 0
            siteTags.push matches
          _.intersection.apply @, siteTags

  fetchTags: (callback) ->
    @localStore.get 'tags', (data) =>
      tags = data.tags || []

      @localStore.get tags, (data) =>
        foundTags = []
        compiledTags = for tag, sites of data
          {name: tag, sites: sites}
        callback(tags, compiledTags)

  fetchTagSites: (name, callback = ->) ->
    @localStore.get name, (data) =>
      data[name] ||= []
      sites = for site in data[name]
        {
          title: site.title
          url: site.url
          datetime: site.datetime
        }
      callback(sites)

  fetchSharedTag: (name, callback) ->
    @localStore.get 'sharedTags', (data) ->
      data.sharedTags ||= {}
      callback(data.sharedTags[name])

  fetchSiteTags: (url, callback = ->) ->
    @localStore.get 'tags', (data) =>
      tags = data.tags || []

      @localStore.get tags, (data) =>
        foundTags = []
        for tag, sites of data
          for site in sites
            foundTags.push tag if site.url == url

        callback(foundTags)

  shareTag: (tag, url, callback = ->) ->
    @localStore.get "sharedTags", (data) =>
      data = sharedTags: {} unless data.sharedTags?
      data.sharedTags[tag] = url
      @localStore.set data, ->
        callback()

  addSiteToTag: (site, tag, callback = ->) ->
    operations = tagCreated: false

    @localStore.get "tags", (data) =>
      data = tags: [] unless data.tags?
      if data.tags.indexOf(tag) == -1
        operations.tagCreated = true
        data.tags.unshift tag
      @localStore.set data, =>
        @localStore.get tag, (data) =>
          data[tag] ||= []
          data[tag].push site
          @localStore.set data, ->
            callback(operations)

    @expireSharedTag(tag)

  addSitesToTag: (sites, tag, callback = ->) ->
    operations = tagCreated: false

    @localStore.get "tags", (data) =>
      data = tags: [] unless data.tags?
      if data.tags.indexOf(tag) == -1
        operations.tagCreated = true
        data.tags.unshift tag
      @localStore.set data, =>
        @localStore.get tag, (data) =>
          for site in sites
            data[tag] ||= []
            data[tag].push site
          @localStore.set data, ->
            callback(operations)

    @expireSharedTag(tag)

  import: (data, callback) ->
    @localStore.set(data, callback)

  clearAll: ->
    @localStore.clear()

  removeSiteFromTag: (url, tag, callback = ->) ->
    @localStore.get tag, (data) =>
      data[tag] ||= []
      data[tag] = _.reject data[tag], (site) =>
        url == site.url
      @localStore.set data, =>
        callback(data[tag])

    @expireSharedTag(tag)

  removeSitesFromTag: (urls, tag, callback = ->) ->
    @localStore.get tag, (data) =>
      data[tag] ||= []
      data[tag] = _.reject data[tag], (site) =>
        _.find urls, (url) -> site.url == url
      @localStore.set data, =>
        callback(data[tag])

    @expireSharedTag(tag)

  removeTag: (tag, callback = ->) ->
    @localStore.get 'tags', (data) =>
      data.tags ||= []
      data.tags = _.without(data.tags, tag)
      @localStore.set data, =>
        @localStore.remove tag, ->
          callback()

    @expireSharedTag(tag)

  removeAllTags: (callback = ->) ->
    @localStore.get 'tags', (data) =>
      tags = data.tags || []

      @localStore.remove tags, =>
        @localStore.set tags: [], ->
          callback()

    @expireSharedTag()

  renameTag: (oldTag, newTag, callback = ->) ->
    @localStore.get 'tags', (data) =>
      data.tags ||= []

      newTagExists = true if data.tags.indexOf(newTag) != -1
      data.tags = _.without(data.tags, oldTag)
      data.tags = _.without(data.tags, newTag) if newTagExists
      data.tags.unshift(newTag)

      @localStore.set data, =>
        @localStore.get oldTag, (data) =>
          sites = data[oldTag]

          if newTagExists
            @localStore.get newTag, (data) =>
              @localStore.remove oldTag, =>
                for site in sites
                  data[newTag].push site

                @localStore.set data, ->
                  callback()
          else
            @localStore.remove oldTag, =>
              data = {}
              data[newTag] = sites
              @localStore.set data, ->
                callback()

    @expireSharedTag(oldTag)

  expireSharedTag: (tag = null, callback = ->) ->
    @localStore.get 'sharedTags', (data) =>
      data.sharedTags ||= {}

      if tag?
        delete data.sharedTags[tag]
      else
        data.sharedTags = {}

      @localStore.set data, ->
        callback()
