CUR_TIME:=$(shell date +"%Y-%m-%d_%H:%M:%S")

upload:
	@git add .
	@git commit -m "$(CUR_TIME)"
	@git push origin main
	
maintain:
	@git add .
	@git commit -m "$(CUR_TIME)"
	@git fetch origin main:tmp
	@git merge tmp
	@git rebase tmp
	@git branch -d tmp