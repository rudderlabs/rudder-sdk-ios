read -p "Are you sure to release? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  git tag -a $1 -m "Release $1"
  git push origin $1
fi

