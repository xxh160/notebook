upload:
	git add .
	export CUR_TIME=$(date +"%Y-%m-%d_%H:%M:%S")
	git commit -m "current time: \$CUR_TIME"
	git push origin main
	unset CUR_TIME

maintain:
	git fetch origin main:tmp
	git merge tmp
	git branch -d tmp