CUR_TIME:=$(shell date +"%Y-%m-%d_%H:%M:%S")

upload:
	@git add .
	@git commit -m "$(CUR_TIME)"
	@git push origin main
	
maintain:
	@git stash
	@git fetch origin main:tmp
	@git checkout tmp
	@git rebase main
	@git checkout main
	@git merge tmp
	@git branch -d tmp
	@git stash pop
	@git add .
	@git commit -m "$(CUR_TIME)"

resolve:
	@git add .
	@git rebase --continue
	@git checkout main
	@git merge tmp
	@git branch -d tmp
