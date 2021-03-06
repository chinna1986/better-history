Fixtures = require '../fixtures/search_sanitizer_fixtures'

describe "BH.Workers.SearchSanitizer", ->
  beforeEach ->
    @searchSanitizer = new BH.Workers.SearchSanitizer()

  it "returns a max of 1000 results when searching", ->
    visits = Fixtures.lotsOfVisits()
    sanitizedVisits = @searchSanitizer.run(visits, text: 'title')

    expect(sanitizedVisits.length).toEqual(1000)

  it "removes any script tags in the title or url", ->
    visits = Fixtures.visitsWithScriptTag()
    sanitizedVisits = @searchSanitizer.run(visits, text: 'test')

    expect(sanitizedVisits[0].title).toEqual("testalert(\"yo\")")
    expect(sanitizedVisits[1].location).toEqual("yahoo.comalert(\"yo\")")

  it "matches results by checking if the search term exists in the title, url, time, or date of the visit", ->
    visits = Fixtures.variousVisits()
    sanitizedVisits = @searchSanitizer.run(visits, text: 'september something 12:3')

    titles = _.pluck(sanitizedVisits, 'title')
    expect(titles).toEqual ['September something', 'something', 'Normal something']

  it "orders the matched results by lastVisitTime", ->
    visits = Fixtures.outOfOrderVisits()
    sanitizedVisits = @searchSanitizer.run(visits, text: 'camping')

    titles = _.pluck(sanitizedVisits, 'title')
    expect(titles).toEqual ['biking tips for camping', 'camping', 'Great camping']
