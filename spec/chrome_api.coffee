module.exports = ->
  i18n:
    getMessage: jasmine.createSpy("getMessage").andCallFake((key) ->
      "[translated " + key + "]"
    )

  history:
    search: jasmine.createSpy("search")
    deleteRange: jasmine.createSpy("deleteRange")
    deleteUrl: jasmine.createSpy("deleteUrl")
    deleteAll: jasmine.createSpy("deleteAll")

  browserAction:
    onClicked:
      addListener: jasmine.createSpy("addListener")

  contextMenus:
    create: jasmine.createSpy("create").andReturn(true)
    remove: jasmine.createSpy("remove")
    update: jasmine.createSpy("update")
    onClicked:
      addListener: jasmine.createSpy("addListener")

  tabs:
    create: jasmine.createSpy("create")
    query: jasmine.createSpy("query")
    update: jasmine.createSpy("update")
    get: jasmine.createSpy("get").andCallFake((id, callback) ->
      callback url: "http://code.google.com/projects"
    )
    onActivated:
      addListener: jasmine.createSpy("addListener")

    onUpdated:
      addListener: jasmine.createSpy("addListener")

  omnibox:
    onInputChanged:
      addListener: jasmine.createSpy("addListener")

    onInputEntered:
      addListener: jasmine.createSpy("addListener")

    setDefaultSuggestion: jasmine.createSpy("setDefaultSuggestion")

  storage:
    sync:
      set: jasmine.createSpy("set")
      get: jasmine.createSpy("get")
      remove: jasmine.createSpy("remove")
    local:
      set: jasmine.createSpy("set")
      get: jasmine.createSpy("get")
      remove: jasmine.createSpy("remove")
      clear: jasmine.createSpy('clear')

  runtime:
    sendMessage: jasmine.createSpy('sendMessage')
