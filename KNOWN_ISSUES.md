KNOWN ISSUES
============

- Some podcasters change their `feedUrl` rather than updating the `newFeedUrl`.
  Since `audiflow` uses `feedUrl` as the identifier for a podcast, any change to this
  URL is interpreted as a new podcast version. As a result, users may find that their
  podcast statistics have disappeared.
