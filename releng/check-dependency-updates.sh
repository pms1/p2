cd p2.parent && mvn versions:display-dependency-updates -Dtycho.mode=maven

# scans a project's dependencies and
# produces a report of those dependencies which have newer versions available.
# mvn versions:display-plugin-updates  -Dtycho.mode=maven