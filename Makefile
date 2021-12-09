all:
	docker build -t jsalort/py:3.9 .
	docker tag jsalort/py:3.9 jsalort/py:latest

push:
	docker push jsalort/py:3.9
	docker push jsalort/py:latest
