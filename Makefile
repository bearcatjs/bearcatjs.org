all: update
	hexo generate
	cp -rf bearcat-examples public/examples

deploy:	all
	hexo deploy

update:
	cd bearcat-examples && git checkout master && git pull
