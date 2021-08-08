# GIT COMMIT
cd `dirname "${0}"`
test -e tmp/ && rm -fr tmp/
export HOGE='+"%Y/%m/%d_%R:%S"'
git add . 
git add -u
git commit -m "`date $HOGE` $1"
git push origin main
