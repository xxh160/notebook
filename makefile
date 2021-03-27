upload:
	git add .
	time=`date +"%Y-%m-%d_%H:%M:%S"`
	git commit -m "$time"
	git push origin main

maintain:
	git fetch origin main:tmp
	git merge tmp
	git branch -d tmp