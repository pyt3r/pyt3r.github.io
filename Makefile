install:
	bundle install

serve:
	bundle exec jekyll serve


git-merge: # if your changes are in develop...
	git checkout develop
	git pull
	git merge origin/master
	git push origin develop

.PHONY: install serve git-merge