all:
	docker build -t jsalort/py:3.13 .
	docker tag jsalort/py:3.13 jsalort/py:latest

push:
	docker push jsalort/py:3.13
	docker push jsalort/py:latest
