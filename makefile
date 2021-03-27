CUR_TIME:=$(shell date +"%Y-%m-%d_%H:%M:%S")

upload:
	@git add .
	@git commit -m "a$(CUR_TIME)"
	@git push origin main
	echo $(CUR_TIME)
	
maintain:
	@git fetch origin main:tmp
	@git merge tmp
	@git branch -d tmp