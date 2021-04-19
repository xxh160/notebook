CUR_TIME:=$(shell date +"%Y-%m-%d_%H:%M:%S")

upload:
	git add .
	git commit -m "$(CUR_TIME)"
	git push origin main
	
maintain:
	git stash
	git fetch origin main:tmp
	git merge tmp
	git branch -d tmp
	git stash pop
	git add .
	git commit -m "$(CUR_TIME)"
