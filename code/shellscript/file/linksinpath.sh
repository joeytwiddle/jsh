# Unfinished
while ! "$PWD" = "/"; do
  echo "$pwd=$PWD"
  ls -ld "$PWD"
  cd ..
done
