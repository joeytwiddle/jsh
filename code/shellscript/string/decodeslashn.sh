# Not entirely working because not parsed concurrently:
# sed 's+\\n+\
# +g;s+\\\\+\\+g'

# Inelegant fudge:
UNIQUE="jadljfofjw90f02""4329r2934SFKSLFSL"
sed 's+\\\\+$UNIQUE+g;s+\\n+\
+g;s+$UNIQUE+\\+g'
